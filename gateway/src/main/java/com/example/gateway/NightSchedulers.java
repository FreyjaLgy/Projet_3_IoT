package com.example.gateway;

import com.example.gateway.MotionService;
import com.example.gateway.TimeHelpers;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.time.Duration;

@Component
public class NightSchedulers {
  private static final Logger log = LoggerFactory.getLogger(NightSchedulers.class);

  private final RestClient http = RestClient.create();
  private final TimeHelpers time;
  private final MotionService motion;

  @Value("${leds.baseUrl:http://localhost:8082}")
  private String ledsBaseUrl;

  @Value("${speaker.baseUrl:http://localhost:8083}")
  private String speakerBaseUrl;

  @Value("${shutter.baseUrl:http://localhost:8084}")
  private String shutterBaseUrl;

  public NightSchedulers(TimeHelpers time, MotionService motion) {
    this.time = time; this.motion = motion;
  }

  // Toutes les 2s : cap volume à 15 en heures calmes
  @Scheduled(fixedDelay = 2000, initialDelay = 10000)
  public void capSpeakerInQuietHours() {
    if (speakerBaseUrl.isBlank()) return;
    if (!time.inQuietHours()) return;
    try {
      // récupère les props
      var props = http.get().uri(speakerBaseUrl + "/properties")
        .retrieve().body(String.class);
      // check très simple pour éviter JSON parsing; à améliorer si besoin
      if (props != null && props.contains("\"volume\":")) {
        int idx = props.indexOf("\"volume\":");
        int vol = Integer.parseInt(props.substring(idx + 9).replaceAll("[^0-9].*$", ""));
        if (vol > 15) {
          http.post().uri(speakerBaseUrl + "/actions/setVolume")
            .body("{\"value\":15}")
            .retrieve().toBodilessEntity();
          log.info("QuietHours: capped speaker volume to 15");
        }
      }
    } catch (Exception e) {
      log.warn("capSpeakerInQuietHours failed: {}", e.toString());
    }
  }

  // Toutes les 2s : après minuit, si 15 min sans mouvement -> LEDs OFF
  @Scheduled(fixedDelay = 2000, initialDelay = 15000)
  public void nightIdleTurnOffLeds() {
    // après minuit = >= 00:00 (toujours vrai), mais on le garde pour lisibilité
    try {
      if (motion.noMotionFor(Duration.ofMinutes(1))) {
        http.post().uri(ledsBaseUrl + "/actions/turnOff")
          .retrieve().toBodilessEntity();
        log.info("Night idle: no motion for 15min -> LEDs OFF");
      }
    } catch (Exception e) {
      log.warn("nightIdleTurnOffLeds failed: {}", e.toString());
    }
  }

  // Toutes les 2s : après 19h00, fermer automatiquement tous les volets
  @Scheduled(fixedDelay = 2000, initialDelay = 20000)
  public void autoCloseShuttersAfter19h() {
    if (shutterBaseUrl.isBlank()) return;
    if (!time.hourGte("19:00")) return; // Seulement après 19h00
    
    try {
      // Vérifier l'état des volets
      var status = http.post().uri(shutterBaseUrl + "/action/getStatus")
        .retrieve().body(String.class);
      
      // Si au moins un volet est ouvert (contains "open":true), les fermer tous
      if (status != null && status.contains("\"open\":true")) {
        http.post().uri(shutterBaseUrl + "/action/closeall")
          .retrieve().toBodilessEntity();
        log.info("Evening rule: closed all shutters after 19:00");
      }
    } catch (Exception e) {
      log.warn("autoCloseShuttersAfter19h failed: {}", e.toString());
    }
  }

  // Toutes les heures : ouvrir automatiquement tous les volets le matin à 6h00
  @Scheduled(fixedDelay = 2000, initialDelay = 25000) // 1 heure
  public void autoOpenShuttersAt6h() {
    if (shutterBaseUrl.isBlank()) return;
    
    try {
      var currentTime = time.getCurrentTime();
      // Ouvrir entre 6h00 et 6h59
      if (currentTime.startsWith("06:")) {
        var status = http.post().uri(shutterBaseUrl + "/action/getStatus")
          .retrieve().body(String.class);
        
        // Si au moins un volet est fermé, les ouvrir tous
        if (status != null && status.contains("\"open\":false")) {
          http.post().uri(shutterBaseUrl + "/action/openall")
            .retrieve().toBodilessEntity();
          log.info("Morning rule: opened all shutters at 6:00");
        }
      }
    } catch (Exception e) {
      log.warn("autoOpenShuttersAt6h failed: {}", e.toString());
    }
  }
}
