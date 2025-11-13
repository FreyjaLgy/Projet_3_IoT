package com.example.gateway;

import com.example.gateway.MotionService;
import com.example.gateway.TimeHelpers;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestClient;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/hooks")
public class HooksController {

  private static final Logger log = LoggerFactory.getLogger(HooksController.class);

  public record MotionPayload(String thingId) {}

  private final RestClient http = RestClient.create();
  private final TimeHelpers time;
  private final MotionService motion;

  @Value("${leds.baseUrl:http://localhost:8082}")
  private String ledsBaseUrl;

  @Value("${speaker.baseUrl:http://localhost:8083}")
  private String speakerBaseUrl;

  //@Value("${shutter.baseUrl:http://localhost:8084}")
  //private String shutterBaseUrl;

  public HooksController(TimeHelpers time, MotionService motion) {
    this.time = time; this.motion = motion;
  }

  @PostMapping(path = "/motion", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Map<String, Object>> onMotion(@RequestBody MotionPayload payload) {
    var out = new HashMap<String, Object>();
    out.put("thingId", payload.thingId());
    out.put("status", "MOTION_RULES_APPLYING");

    try {
      // Enregistrer l'heure du dernier mouvement
      motion.markNow();

      // LEDs ON + brightness selon l'heure
      post(ledsBaseUrl + "/actions/turnOn", null);
      int targetBrightness = time.inQuietHours() ? 20 : 35;
      post(ledsBaseUrl + "/actions/setBrightness", jsonNum("value", targetBrightness));
      out.put("leds.brightness", targetBrightness);

      // Musique : volume adapté selon l'heure
      if (!speakerBaseUrl.isBlank()) {
        int targetVolume;
        if (time.inQuietHours()) {
          targetVolume = 15; // Max 15% en heures calmes (22h-06h)
        } else if (time.hourLt("19:00")) {
          targetVolume = 25; // Volume normal avant 19h
        } else {
          targetVolume = 15; // Volume réduit après 19h
        }
        post(speakerBaseUrl + "/actions/setVolume", jsonNum("value", targetVolume));
        post(speakerBaseUrl + "/actions/play", "{\"playlist\":\"Chill\"}");
        out.put("speaker.action", "play@" + targetVolume);
      } else {
        out.put("speaker.action", "none");
      }

      out.put("status", "MOTION_RULES_APPLIED");
      return ResponseEntity.ok(out);

    } catch (Exception e) {
      log.error("Error in motion hook", e);
      out.put("error", e.getMessage());
      return ResponseEntity.internalServerError().body(out);
    }
  }

  /* utils */
  private void post(String url, String bodyJson) {
    var req = http.post().uri(url);
    if (bodyJson != null && !bodyJson.isBlank()) {
      req = req.contentType(MediaType.APPLICATION_JSON).body(bodyJson);
    }
    req.retrieve().toBodilessEntity();
  }
  private String jsonNum(String k, Number v) { return "{\"" + k + "\":" + v + "}"; }
}
