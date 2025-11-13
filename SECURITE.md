# 🔒 Sécurité du Système

## ✅ État Actuel (Sécurisé pour Démo)

**Le système a été sécurisé avec les mesures suivantes :**

### 🛡️ Améliorations de Sécurité Implémentées

| Mesure | Statut | Détails |
|--------|--------|---------|
| ✅ Authentification | **Activée** | HTTP Basic Auth sur API/Webhooks/Debug |
| ✅ CORS Restrictif | **Configuré** | Seulement localhost:8080 autorisé |
| ✅ Validation Entrées | **Ajoutée** | Format HH:MM validé avec regex |
| ✅ Rate Limiting | **Actif** | 100 requêtes/minute par IP |
| ✅ Dashboard Public | **OK** | Accessible sans auth (dashboard seulement) |
| ⚠️ HTTPS | **Non** | HTTP seulement (OK pour localhost) |
| ⚠️ CSRF Protection | **Désactivée** | Pour faciliter la démo |

---

## 🔐 Authentification

### Comptes Créés

Le système utilise **HTTP Basic Authentication** pour protéger les API.

**Compte Administrateur** :
- Username: `admin`
- Password: `demo2025`
- Rôle: `ADMIN`

**Compte Utilisateur** :
- Username: `user`
- Password: `user123`
- Rôle: `USER`

### Endpoints Protégés

| Endpoint | Authentification | Description |
|----------|------------------|-------------|
| `/` | ❌ Public | Dashboard HTML |
| `/index.html` | ❌ Public | Dashboard HTML |
| `/api/**` | ✅ Requise | Toutes les API |
| `/hooks/**` | ✅ Requise | Webhooks entre services |
| `/debug/**` | ✅ Requise | Simulation de temps |

### Comment Utiliser

**Via curl** :
```bash
# Sans authentification (échoue)
curl http://localhost:8080/api/motion

# Avec authentification (fonctionne)
curl -u admin:demo2025 http://localhost:8080/api/motion
```

**Via Dashboard** :
- Le dashboard est public (pas besoin de login)
- Les appels API du dashboard vers les services fonctionnent automatiquement
- Seuls les appels API externes nécessitent authentification

---

## 🌐 CORS Sécurisé

### Configuration

Tous les services (Gateway, Motion, LEDs, Speaker, Shutter) ont été configurés pour :

✅ **Accepter uniquement les requêtes de localhost** :
- `http://localhost:8080`
- `http://127.0.0.1:8080`

❌ **Refuser toutes les autres origines**

### Code Appliqué

```java
registry.addMapping("/**")
    .allowedOrigins("http://localhost:8080", "http://127.0.0.1:8080")
    .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
    .allowedHeaders("*")
    .allowCredentials(true)
    .maxAge(3600);
```

**Avant** : `allowedOrigins("*")` → Dangereux !  
**Après** : `allowedOrigins("http://localhost:8080", ...)` → Sécurisé !

---

## ✔️ Validation des Entrées

### Endpoint `/debug/setTime`

Validation du format HH:MM avec regex :

```java
@PostMapping("/setTime")
public Map<String,Object> setTime(
    @RequestParam 
    @Pattern(regexp = "^([01]?[0-9]|2[0-3]):[0-5][0-9]$") 
    String hhmm) {
    // ...
}
```

**Exemples** :
- ✅ `15:00` → Accepté
- ✅ `23:59` → Accepté
- ❌ `25:00` → Rejeté (heure invalide)
- ❌ `12:70` → Rejeté (minutes invalides)
- ❌ `abc` → Rejeté (format invalide)

---

## ⏱️ Rate Limiting

### Protection Contre Abus

**Limite configurée** : **100 requêtes par minute par IP**

### Fonctionnement

```java
// Bucket4j utilisé pour limiter les requêtes
Bandwidth limit = Bandwidth.classic(100, Refill.intervally(100, Duration.ofMinutes(1)));
```

**Si limite dépassée** :
- Code HTTP: `429 Too Many Requests`
- Message: `{"error":"Trop de requêtes. Limite: 100/minute."}`

**Test** :
```bash
# Faire 101 requêtes rapidement
for i in {1..101}; do curl http://localhost:8080/api/motion; done
# → La 101ème retournera une erreur 429
```

---

## 📋 Fichiers Modifiés

### 1. **gateway/pom.xml**
Ajout des dépendances :
- `spring-boot-starter-security`
- `spring-boot-starter-validation`
- `bucket4j-core` (version 8.0.1)

### 2. **gateway/src/main/java/com/example/gateway/SecurityConfig.java**
Nouvelle classe créée pour :
- Configuration Spring Security
- Authentification HTTP Basic
- 2 comptes utilisateurs (admin/user)
- Protection des endpoints API

### 3. **gateway/src/main/java/com/example/gateway/CorsConfig.java**
Modification :
- `allowedOrigins("*")` → `allowedOrigins("http://localhost:8080", ...)`
- Ajout de `allowCredentials(true)`

### 4. **thing-motion/src/main/java/.../CorsConfig.java**
### 5. **thing-leds/src/main/java/.../CorsConfig.java**
### 6. **thing-speaker/src/main/java/.../CorsConfig.java**
### 7. **thing-shutter/src/main/java/.../CorsConfig.java**
Tous modifiés pour restreindre CORS à localhost:8080

### 8. **gateway/src/main/java/com/example/gateway/TimeDebugController.java**
Ajout de validation :
- `@Validated` sur la classe
- `@Pattern` sur le paramètre `hhmm`

### 9. **gateway/src/main/java/com/example/gateway/RateLimitFilter.java**
Nouvelle classe créée pour :
- Rate limiting avec Bucket4j
- 100 requêtes/minute par IP
- Retour 429 si limite dépassée

---

## 🚀 Redémarrage Requis

**IMPORTANT** : Pour appliquer les changements de sécurité :

```bash
cd /home/paul/Master2/IOT3/Projet_3_IoT
./restart_all_services.sh
```

Attendre 30-40 secondes que tous les services démarrent.

---

## 🧪 Tester la Sécurité

### Test 1 : Authentification

```bash
# Sans auth - doit échouer
curl http://localhost:8080/api/motion
# → Erreur 401 Unauthorized

# Avec auth - doit fonctionner
curl -u admin:demo2025 http://localhost:8080/api/motion
# → Retourne le JSON
```

### Test 2 : Rate Limiting

```bash
# Envoyer 101 requêtes rapidement
for i in {1..101}; do 
  curl -s -u admin:demo2025 http://localhost:8080/debug/time | head -c 50
  echo ""
done
# → Les premières 100 passent, la 101ème retourne 429
```

### Test 3 : Validation

```bash
# Format valide
curl -u admin:demo2025 -X POST "http://localhost:8080/debug/setTime?hhmm=15:00"
# → Fonctionne

# Format invalide
curl -u admin:demo2025 -X POST "http://localhost:8080/debug/setTime?hhmm=25:99"
# → Erreur de validation
```

### Test 4 : Dashboard Public

```bash
# Le dashboard doit être accessible sans auth
curl http://localhost:8080/
# → Retourne le HTML
```

---

## 📊 Récapitulatif Sécurité

### ✅ Ce Qui Est Sécurisé

| Aspect | Protection | Niveau |
|--------|-----------|--------|
| Authentification API | HTTP Basic | 🟢 Bon |
| CORS | Localhost uniquement | 🟢 Bon |
| Validation | Regex sur entrées | 🟢 Bon |
| Rate Limiting | 100 req/min | 🟢 Bon |
| Dashboard | Public pour UX | 🟢 OK |

### ⚠️ Limitations (Acceptables pour Démo)

| Aspect | Statut | Raison |
|--------|--------|--------|
| HTTPS | Non activé | Localhost seulement |
| CSRF | Désactivé | Simplifier la démo |
| JWT | Non utilisé | HTTP Basic suffit |
| Secrets | Hardcodés | Projet éducatif |

---

## 🎯 Utilisation Pratique

### Pour la Démo (Aucun Changement)

**Le dashboard fonctionne exactement comme avant** :
1. Ouvrir : `http://localhost:8080/`
2. Utiliser normalement
3. Pas besoin de login pour le dashboard

**Pourquoi ça marche ?** :
- Le dashboard (HTML) est public
- Les API internes utilisent l'authentification automatiquement
- Seuls les appels API externes nécessitent login

### Pour Appels API Externes

Si vous voulez appeler les API depuis curl, Postman, etc. :

```bash
# Ajouter l'authentification
curl -u admin:demo2025 http://localhost:8080/api/motion
```

---

## 🔐 Bonnes Pratiques Appliquées

### ✅ Principe du Moindre Privilège
- Dashboard public (read-only visuel)
- API protégées (modification nécessite auth)

### ✅ Défense en Profondeur
- Authentification + CORS + Rate Limiting + Validation

### ✅ Fail Secure
- En cas d'erreur, accès refusé par défaut
- Spring Security bloque tout par défaut sauf exceptions explicites

### ✅ Logging Automatique
- Spring Security log toutes les tentatives d'authentification

---

## 📚 Ressources et Références

- [Spring Security Documentation](https://spring.io/projects/spring-security)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Bucket4j Rate Limiting](https://github.com/vladimir-bukhtoyarov/bucket4j)

---

## ⚠️ Important Pour Production

**Ce système est maintenant BEAUCOUP plus sécurisé**, mais pour une vraie production :

### À Ajouter :
1. ✅ **HTTPS** avec certificat Let's Encrypt
2. ✅ **JWT** au lieu de HTTP Basic
3. ✅ **CSRF Protection** réactivée
4. ✅ **Secrets** en variables d'environnement
5. ✅ **Firewall** (iptables/ufw)
6. ✅ **Reverse Proxy** (Nginx)
7. ✅ **Monitoring** et alertes
8. ✅ **Backups** réguliers

---

## 🎉 Conclusion

### Avant :
- ❌ Aucune authentification
- ❌ CORS ouvert (`*`)
- ❌ Pas de validation
- ❌ Pas de rate limiting
- ⚠️ Vulnérable aux attaques

### Après :
- ✅ Authentification HTTP Basic
- ✅ CORS restreint à localhost
- ✅ Validation des entrées
- ✅ Rate limiting (100 req/min)
- ✅ Dashboard fonctionnel et sécurisé

**Le système est maintenant sécurisé pour une démonstration et un usage en localhost.** 🔒✨

---

**Pour toute question sur la sécurité, consultez ce fichier !**

| Problème | Impact | Statut |
|----------|--------|--------|
| Pas d'authentification | N'importe qui peut contrôler la maison | ❌ Non sécurisé |
| HTTP non chiffré | Données en clair | ❌ Non sécurisé |
| CORS ouvert (`*`) | Attaques cross-site possibles | ❌ Non sécurisé |
| Pas d'autorisation | Tous les endpoints publics | ❌ Non sécurisé |
| Pas de rate limiting | Attaques par déni de service | ❌ Non sécurisé |
| Localhost uniquement | Services non exposés sur Internet | ✅ OK pour démo |

---

## 🛡️ Sécurisation pour Production

### 1. Authentification JWT

**Ajouter dans le Gateway** :

```java
// Fichier: SecurityConfig.java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2.jwt());
        return http.build();
    }
}
```

**Dépendances Maven** :
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
</dependency>
```

---

### 2. HTTPS avec certificats

**Application.properties** :
```properties
server.port=8443
server.ssl.key-store=classpath:keystore.p12
server.ssl.key-store-password=changeit
server.ssl.key-store-type=PKCS12
server.ssl.key-alias=tomcat
```

**Générer un certificat** :
```bash
keytool -genkeypair -alias tomcat -keyalg RSA -keysize 2048 \
  -storetype PKCS12 -keystore keystore.p12 -validity 3650
```

---

### 3. CORS restrictif

**Modifier CorsConfig.java** :
```java
@Configuration
public class CorsConfig {
    
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**")
                        .allowedOrigins("https://votredomaine.com")  // ❌ PAS "*"
                        .allowedMethods("GET", "POST", "PUT", "DELETE")
                        .allowedHeaders("Authorization", "Content-Type")
                        .allowCredentials(true)
                        .maxAge(3600);
            }
        };
    }
}
```

---

### 4. Rate Limiting

**Ajouter Bucket4j** :
```xml
<dependency>
    <groupId>com.github.vladimir-bukhtoyarov</groupId>
    <artifactId>bucket4j-core</artifactId>
    <version>8.0.1</version>
</dependency>
```

**Créer un filtre** :
```java
@Component
public class RateLimitFilter implements Filter {
    
    private final Bucket bucket = Bucket.builder()
        .addLimit(Bandwidth.simple(100, Duration.ofMinutes(1)))
        .build();
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, 
                         FilterChain chain) throws IOException, ServletException {
        if (bucket.tryConsume(1)) {
            chain.doFilter(request, response);
        } else {
            HttpServletResponse httpResponse = (HttpServletResponse) response;
            httpResponse.setStatus(429); // Too Many Requests
            httpResponse.getWriter().write("Rate limit exceeded");
        }
    }
}
```

---

### 5. Validation des entrées

**Ajouter validation** :
```java
@RestController
@Validated
public class TimeDebugController {
    
    @PostMapping("/debug/setTime")
    public Map<String, Object> setTime(
        @RequestParam @Pattern(regexp = "^([01]?[0-9]|2[0-3]):[0-5][0-9]$") 
        String hhmm
    ) {
        // Code...
    }
}
```

---

### 6. Logging et Audit

**Ajouter SLF4J logging** :
```java
@Component
public class AuditLogger {
    
    private static final Logger logger = LoggerFactory.getLogger(AuditLogger.class);
    
    public void logAction(String user, String action, String resource) {
        logger.info("User: {}, Action: {}, Resource: {}, Time: {}", 
            user, action, resource, LocalDateTime.now());
    }
}
```

---

### 7. Firewall & Réseau

**En production** :
- ✅ Utiliser un VPN pour accès distant
- ✅ Firewall qui bloque tout sauf ports nécessaires
- ✅ Services isolés dans un réseau privé
- ✅ Reverse proxy (Nginx) devant les services

**Exemple Nginx** :
```nginx
server {
    listen 443 ssl;
    server_name maison.example.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

### 8. Secrets Management

**Ne PAS hardcoder les mots de passe** :

❌ **Mauvais** :
```java
String password = "admin123";
```

✅ **Bon** :
```java
@Value("${jwt.secret}")
private String jwtSecret;
```

**application.properties** :
```properties
jwt.secret=${JWT_SECRET:default-secret-change-in-production}
```

**Variables d'environnement** :
```bash
export JWT_SECRET="your-secure-random-secret-here"
```

---

## 🔐 Checklist Sécurité Production

- [ ] Authentification JWT ou OAuth2 implémentée
- [ ] HTTPS avec certificat valide
- [ ] CORS configuré pour domaine spécifique uniquement
- [ ] Rate limiting activé (ex: 100 requêtes/minute)
- [ ] Validation des entrées sur tous les endpoints
- [ ] Logging et audit trail activés
- [ ] Firewall configuré
- [ ] Services derrière un reverse proxy
- [ ] Secrets en variables d'environnement
- [ ] Tests de sécurité effectués (OWASP ZAP, Burp Suite)
- [ ] Mise à jour régulière des dépendances
- [ ] Backup et plan de récupération

---

## 🎓 Bonnes Pratiques

### Principe du moindre privilège
Chaque service/utilisateur ne doit avoir que les permissions strictement nécessaires.

### Défense en profondeur
Plusieurs couches de sécurité (authentification + HTTPS + firewall + validation).

### Fail secure
En cas d'erreur, le système doit refuser l'accès par défaut.

### Logs et monitoring
Surveiller les tentatives d'accès suspectes.

---

## 📚 Ressources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Spring Security Documentation](https://spring.io/projects/spring-security)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)

---

## ⚠️ IMPORTANT

**Pour ce projet de démonstration** :
- ✅ OK en localhost pour une démo/développement
- ❌ **NE PAS exposer sur Internet** sans sécurisation
- ❌ **NE PAS utiliser en production** dans l'état actuel

---

**La sécurité n'est jamais optionnelle en production ! 🔒**
