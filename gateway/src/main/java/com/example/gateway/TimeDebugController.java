package com.example.gateway;

import org.springframework.web.bind.annotation.*;
import org.springframework.validation.annotation.Validated;
import jakarta.validation.constraints.Pattern;
import java.util.Map;

@RestController
@RequestMapping("/debug")
@Validated
public class TimeDebugController {
  private final TimeHelpers time;

  public TimeDebugController(TimeHelpers t) { this.time = t; }

  @GetMapping("/time")
  public Map<String,Object> getTime() {
    return Map.of(
      "now", time.getCurrentTime(),
      "inQuietHours", time.inQuietHours(),
      "hourLt19", time.hourLt("19:00")
    );
  }

  @PostMapping("/setTime")
  public Map<String,Object> setTime(
      @RequestParam 
      @Pattern(regexp = "^([01]?[0-9]|2[0-3]):[0-5][0-9]$", message = "Format doit être HH:MM") 
      String hhmm) {
    time.overrideTime(hhmm);
    return Map.of("simulatedTimeSetTo", hhmm);
  }
}
