# 🔐 GUIDE DE DÉMONSTRATION - SÉCURITÉ

## 🎯 Objectif
Démontrer que le dashboard est maintenant protégé par authentification avec Spring Security.

## 📋 Comptes Utilisateurs

### 1. Administrateur
- **Username:** `admin`
- **Password:** `demo2025`
- **Rôle:** ADMIN
- **Accès:** Complet

### 2. Utilisateur Standard
- **Username:** `user`
- **Password:** `user123`
- **Rôle:** USER
- **Accès:** Standard

## 🚀 Scénario de Démonstration

### Étape 1 : Accès au Dashboard Sans Authentification
```
1. Ouvrez votre navigateur
2. Allez sur : http://localhost:8080/
3. Résultat : Vous êtes automatiquement redirigé vers /login
4. ❌ Impossible d'accéder au dashboard sans se connecter
```

### Étape 2 : Page de Login
```
✅ Page de login sécurisée affichée
✅ Design professionnel avec gradient violet
✅ Formulaire d'authentification
✅ Affichage des comptes de démo disponibles
```

### Étape 3 : Tentative de Connexion avec Mauvais Identifiants
```
1. Username : test
2. Password : wrong
3. Cliquer sur "Se connecter"
4. Résultat : ❌ Message d'erreur "Identifiants incorrects"
5. Vous restez sur la page de login
```

### Étape 4 : Connexion Réussie (Admin)
```
1. Username : admin
2. Password : demo2025
3. Cliquer sur "Se connecter"
4. Résultat : ✅ Redirection vers le dashboard
5. Vous pouvez maintenant contrôler tous les devices
```

### Étape 5 : Navigation dans le Dashboard
```
✅ Header affiche "🏠 Maison Ambiance Chill"
✅ Bouton "🔓 Déconnexion" visible en haut à droite
✅ Toutes les fonctionnalités disponibles :
   - Contrôle LEDs
   - Contrôle Speaker
   - Simulation de mouvement
   - Contrôle des volets
   - Changement d'heure
```

### Étape 6 : Déconnexion
```
1. Cliquer sur le bouton "🔓 Déconnexion"
2. Confirmer dans la popup
3. Résultat : ✅ Redirection vers /login?logout
4. Message de succès : "✅ Vous avez été déconnecté avec succès"
5. Impossible de revenir sur le dashboard sans se reconnecter
```

### Étape 7 : Connexion avec Compte Utilisateur
```
1. Username : user
2. Password : user123
3. Cliquer sur "Se connecter"
4. Résultat : ✅ Accès au dashboard (mêmes droits pour la démo)
```

## 🔒 Points de Sécurité Démontrés

### 1. ✅ Authentification Obligatoire
- Le dashboard n'est plus accessible publiquement
- Redirection automatique vers la page de login
- Sessions sécurisées avec Spring Security

### 2. ✅ Protection par Mot de Passe
- Mots de passe hashés avec BCrypt
- Pas de stockage en clair
- Validation côté serveur

### 3. ✅ Gestion des Sessions
- Cookie de session sécurisé
- Déconnexion propre
- Timeout de session automatique

### 4. ✅ Protection des Endpoints
- Dashboard protégé : `/`, `/index.html`
- API protégée : `/api/**`
- Webhooks publics : `/hooks/**` (pour les devices IoT)
- Debug public : `/debug/**` (pour la démo seulement)

### 5. ✅ Interface Utilisateur
- Page de login professionnelle
- Messages d'erreur clairs
- Confirmation de déconnexion
- Feedback visuel (succès/erreur)

## 🎬 Script de Démonstration (5 minutes)

### Introduction (30 secondes)
> "Je vais vous montrer comment le système est sécurisé avec une authentification 
> obligatoire pour accéder au dashboard."

### Démonstration 1 : Accès Non Autorisé (1 minute)
1. Ouvrir http://localhost:8080/
2. Montrer la redirection automatique vers /login
3. Expliquer : "Sans authentification, impossible d'accéder au dashboard"

### Démonstration 2 : Authentification Échouée (1 minute)
1. Entrer des identifiants incorrects (test/wrong)
2. Montrer le message d'erreur
3. Expliquer : "Les mauvais identifiants sont rejetés"

### Démonstration 3 : Authentification Réussie (2 minutes)
1. Se connecter avec admin/demo2025
2. Naviguer dans le dashboard
3. Montrer toutes les fonctionnalités
4. Montrer le bouton de déconnexion

### Démonstration 4 : Déconnexion Sécurisée (30 secondes)
1. Cliquer sur "Déconnexion"
2. Confirmer
3. Montrer la redirection et le message de succès
4. Essayer d'accéder au dashboard → Redirection vers login

### Conclusion (30 secondes)
> "Le système est maintenant protégé avec Spring Security. Seuls les utilisateurs
> authentifiés peuvent accéder au dashboard et contrôler les devices IoT."

## 🧪 Tests Complémentaires

### Test 1 : URL Direct
```bash
# Sans authentification
curl http://localhost:8080/

# Résultat : Redirection 302 vers /login
```

### Test 2 : API avec Authentification
```bash
# Sans auth
curl http://localhost:8080/api/test

# Avec auth
curl -u admin:demo2025 http://localhost:8080/api/test
```

### Test 3 : Webhook Public
```bash
# Devrait fonctionner sans auth (pour les devices IoT)
curl -X POST http://localhost:8080/hooks/motion \
  -H "Content-Type: application/json" \
  -d '{"thingId":"motion-1"}'
```

## 📊 Configuration de Sécurité

### Fichier : SecurityConfig.java
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    // Dashboard protégé
    .requestMatchers("/", "/index.html").authenticated()
    
    // API protégée
    .requestMatchers("/api/**").authenticated()
    
    // Webhooks publics (IoT devices)
    .requestMatchers("/hooks/**").permitAll()
    
    // Debug public (démo uniquement)
    .requestMatchers("/debug/**").permitAll()
    
    // Login form
    .formLogin(form -> form
        .loginPage("/login")
        .defaultSuccessUrl("/", true)
    )
    
    // Logout
    .logout(logout -> logout
        .logoutUrl("/logout")
        .logoutSuccessUrl("/login?logout")
    )
}
```

### Utilisateurs Configurés
```java
// Admin avec droits complets
User.builder()
    .username("admin")
    .password(passwordEncoder().encode("demo2025"))
    .roles("ADMIN")
    .build()

// Utilisateur standard
User.builder()
    .username("user")
    .password(passwordEncoder().encode("user123"))
    .roles("USER")
    .build()
```

## ✅ Checklist de Démonstration

- [ ] Services démarrés (./restart_all_services.sh)
- [ ] Navigateur prêt sur http://localhost:8080/
- [ ] Notes avec identifiants visibles
- [ ] Page de login s'affiche correctement
- [ ] Authentification échouée fonctionne
- [ ] Authentification réussie fonctionne
- [ ] Dashboard accessible après login
- [ ] Bouton de déconnexion visible
- [ ] Déconnexion fonctionne correctement
- [ ] Redirection après déconnexion OK

## 🎉 Résultat Attendu

À la fin de la démonstration, l'audience doit comprendre que :

1. ✅ Le système n'est plus accessible publiquement
2. ✅ Une authentification est obligatoire
3. ✅ Les mots de passe sont sécurisés (hashés)
4. ✅ Les sessions sont gérées correctement
5. ✅ La déconnexion est propre et sécurisée
6. ✅ L'interface est professionnelle

**Votre système IoT est maintenant sécurisé ! 🔐**
