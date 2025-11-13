package com.example.thing_speaker;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
public class SpeakerController {
  private boolean playing = false;
  private int volume = 30;       // 0..100
  private String playlist = "none";

  @GetMapping("/properties")
  public Map<String,Object> props() {
    return Map.of(
      "id","speaker-1",
      "type","speaker",
      "playing",playing,
      "volume",volume,
      "playlist",playlist
    );
  }

  record IntBody(int value) {}
  record PlayBody(String playlist) {}

  @PostMapping("/actions/setVolume")
  public ResponseEntity<?> setVolume(
      @RequestBody(required=false) IntBody body,
      @RequestParam(required=false) Integer value) {
    
    // Support both JSON body and query parameter
    int newVolume = 0;
    if (body != null) {
      newVolume = body.value();
    } else if (value != null) {
      newVolume = value;
    } else {
      // If no value provided, keep current volume
      return ResponseEntity.ok(props());
    }
    
    volume = Math.max(0, Math.min(100, newVolume));
    return ResponseEntity.ok(props());
  }

  @PostMapping("/actions/play")
  public ResponseEntity<?> play(@RequestBody(required=false) PlayBody body) {
    playing = true;
    if (body != null && body.playlist() != null && !body.playlist().isBlank()) {
      playlist = body.playlist();
    }
    return ResponseEntity.ok(props());
  }

  @PostMapping("/actions/pause")
  public ResponseEntity<?> pause() {
    playing = false;
    return ResponseEntity.ok(props());
  }
}
