package com.example.gateway;

import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/debug")
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
  public Map<String,Object> setTime(@RequestParam String hhmm) {
    time.overrideTime(hhmm);
    return Map.of("simulatedTimeSetTo", hhmm);
  }
}
