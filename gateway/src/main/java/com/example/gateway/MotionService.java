package com.example.gateway;

import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.atomic.AtomicReference;

@Service
public class MotionService {
  private final AtomicReference<Instant> lastMotion = new AtomicReference<>(Instant.EPOCH);

  public void markNow() { lastMotion.set(Instant.now()); }

  public boolean noMotionFor(Duration d) {
    return Duration.between(lastMotion.get(), Instant.now()).compareTo(d) >= 0;
  }
}
