package com.example.gateway;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/hooks")
public class HooksController {

  public record MotionPayload(String thingId) {}

  @PostMapping("/motion")
  public ResponseEntity<Map<String,Object>> motion(@RequestBody MotionPayload payload) {
    // plus tard on ajoutera: mémoriser l'heure et déclencher les règles
    return ResponseEntity.ok(Map.of(
      "status", "MOTION_RECEIVED",
      "thingId", payload.thingId()
    ));
  }
}
