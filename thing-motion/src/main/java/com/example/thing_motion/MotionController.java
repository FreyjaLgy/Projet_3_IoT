package com.example.thing_motion;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestClient;

import java.time.Instant;
import java.util.Map;

@RestController
public class MotionController {

  private final RestClient http = RestClient.create();

  @Value("${gateway.url}")
  private String gatewayUrl;

  @GetMapping("/properties")
  public Map<String,Object> props() {
    return Map.of(
      "id","motion-1",
      "type","motion",
      "lastDetectedAt", Instant.now().toString() // simulé
    );
  }

  // Simule un mouvement et appelle le webhook du gateway
  @PostMapping(path="/actions/simulate", produces=MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Map<String,Object>> simulate() {
    var payload = Map.of("thingId","motion-1");
    try {
      http.post()
        .uri(gatewayUrl + "/hooks/motion")
        .contentType(MediaType.APPLICATION_JSON)
        .body(payload)
        .retrieve()
        .toBodilessEntity();
      return ResponseEntity.ok(Map.of("status","MOTION_SENT_TO_GATEWAY"));
    } catch (Exception e) {
      return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
    }
  }
}
