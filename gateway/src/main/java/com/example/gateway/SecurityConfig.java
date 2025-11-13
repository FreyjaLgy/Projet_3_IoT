package com.example.gateway;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // Pour démo - En production, activer CSRF
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/", "/index.html", "/css/**", "/js/**", "/images/**").permitAll() // Dashboard public
                .requestMatchers("/hooks/**").permitAll() // Webhooks publics (pour IoT devices)
                .requestMatchers("/api/**").authenticated() // API nécessite authentification
                .requestMatchers("/debug/**").permitAll() // Endpoints debug publics pour démo
                .anyRequest().authenticated()
            )
            .httpBasic(basic -> {}); // Authentification HTTP Basic
        
        return http.build();
    }

    @Bean
    public UserDetailsService userDetailsService() {
        UserDetails user = User.builder()
            .username("admin")
            .password(passwordEncoder().encode("demo2025")) // Mot de passe: demo2025
            .roles("ADMIN")
            .build();
        
        UserDetails viewer = User.builder()
            .username("user")
            .password(passwordEncoder().encode("user123")) // Mot de passe: user123
            .roles("USER")
            .build();
        
        return new InMemoryUserDetailsManager(user, viewer);
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
