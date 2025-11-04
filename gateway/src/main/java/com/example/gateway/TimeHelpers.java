package com.example.gateway;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

@Component
public class TimeHelpers {

  // valeur optionnelle (hh:mm) injectée depuis application.properties ou /debug/setTime
  private static String simulatedTime = null;

  @Value("${simulated.time:}")
  public void setSimulatedTime(String value) {
    if (value != null && !value.isBlank()) simulatedTime = value;
  }

  private LocalTime now() {
    if (simulatedTime != null && !simulatedTime.isBlank()) {
      try {
        return LocalTime.parse(simulatedTime, DateTimeFormatter.ofPattern("HH:mm"));
      } catch (Exception e) {
        System.err.println("[TimeHelpers] simulated.time mal formaté : " + simulatedTime);
      }
    }
    return LocalTime.now();
  }

  public boolean hourLt(String hhmm) {
    return now().isBefore(LocalTime.parse(hhmm));
  }

  public boolean hourGte(String hhmm) {
    return !hourLt(hhmm);
  }

  public boolean inQuietHours() { // 22h–06h
    var t = now();
    return t.isAfter(LocalTime.of(22, 0)) || t.isBefore(LocalTime.of(6, 0));
  }

  public String getCurrentTime() {
    return now().toString();
  }

  public void overrideTime(String newTime) {
    simulatedTime = newTime;
  }
}
