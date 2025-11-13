package com.example.thing_leds;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
public class LedsController {
  private boolean on = false;
  private int brightness = 0; // 0..100
  private String color = "warm";

  @GetMapping("/properties")
  public Map<String,Object> props() {
    return Map.of("id","leds-1","type","leds","on",on,"brightness",brightness,"color",color);
  }

  @PostMapping("/actions/turnOn")
  public Map<String,Object> on() { on = true; return props(); }

  @PostMapping("/actions/turnOff")
  public Map<String,Object> off() { on = false; return props(); }

  record IntBody(int value) {}
  record ColorBody(String value) {}

  @PostMapping("/actions/setBrightness")
  public ResponseEntity<?> setBrightness(
      @RequestBody(required=false) IntBody body,
      @RequestParam(required=false) Integer value) {
    
    // Support both JSON body and query parameter
    int newBrightness = 0;
    if (body != null) {
      newBrightness = body.value();
    } else if (value != null) {
      newBrightness = value;
    } else {
      // If no value provided, keep current brightness
      return ResponseEntity.ok(props());
    }
    
    on = true;
    brightness = Math.max(0, Math.min(100, newBrightness));
    return ResponseEntity.ok(props());
  }

  @PostMapping("/actions/setColor")
  public ResponseEntity<?> setColor(@RequestBody ColorBody body) {
    color = body.value();
    return ResponseEntity.ok(props());
  }
}
