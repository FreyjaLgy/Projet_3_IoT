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

  @Value("${speaker.baseUrl:}")
  private String speakerBaseUrl;

  public NightSchedulers(TimeHelpers time, MotionService motion) {
    this.time = time; this.motion = motion;
  }

  // Toutes les 60s : cap volume à 15 en heures calmes
  @Scheduled(fixedDelay = 60000, initialDelay = 10000)
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

  // Toutes les 60s : après minuit, si 15 min sans mouvement -> LEDs OFF
  @Scheduled(fixedDelay = 60000, initialDelay = 15000)
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
}
