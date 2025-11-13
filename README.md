# 🏠 Maison Ambiance Chill - Guide de Lancement

## 🚀 Démarrage du Système

### 1. Lancer tous les services

```bash
cd /home/paul/Master2/IOT3/Projet_3_IoT
./restart_all_services.sh
```

⏳ **Attendre 40 secondes** que tous les services démarrent.

### 2. Ouvrir le Dashboard

**Dans votre navigateur** :
```
http://localhost:8080/
```

✅ **C'est prêt !** Le dashboard affiche tous les contrôles.

---

## 🎯 Règles Automatiques du Système

Le système adapte automatiquement son comportement selon l'heure :

| Heure | Comportement |
|-------|-------------|
| **Avant 19h** | Mouvement → Lumière ON + Musique ON |
| **Après 19h** | Mouvement → Lumière ON + Musique OFF + Volets fermés |
| **22h-6h (Quiet Hours)** | Volume max 15% + LED max 20% |
| **Après minuit** | 15 min sans mouvement → Extinction automatique |

**Manual Override** : Vous pouvez toujours contrôler manuellement via le dashboard.

---

## 🎮 Utilisation du Dashboard

### Cartes disponibles :

**⏰ Heure Système**
- Voir l'heure actuelle
- Simuler différentes heures : 15:00, 20:00, 23:00
- Reset pour revenir à l'heure réelle

**🚶 Détecteur de Mouvement**
- Voir la dernière détection
- Simuler un mouvement

**💡 Éclairage LED**
- Allumer / Éteindre
- Régler l'intensité (0-100%)

**🔊 Enceinte**
- Play / Pause (Playlist "Chill")
- Régler le volume (0-100%)

**🪟 Volets Connectés**
- Voir l'état de chaque volet (Salon, Cuisine, Chambre)
- Tout ouvrir / Tout fermer

---

## 🛠️ Commandes Utiles

### Arrêter tous les services
```bash
pkill -f "spring-boot:run"
```

### Redémarrer un service spécifique
```bash
cd gateway && ./mvnw spring-boot:run        # Port 8080
cd thing-motion && ./mvnw spring-boot:run   # Port 8081
cd thing-leds && ./mvnw spring-boot:run     # Port 8082
cd thing-speaker && ./mvnw spring-boot:run  # Port 8083
cd thing-shutter && ./mvnw spring-boot:run  # Port 8084
```

### Vérifier qu'un service répond
```bash
curl http://localhost:8080/debug/time      # Gateway
curl http://localhost:8081/properties      # Motion
curl http://localhost:8082/properties      # LEDs
curl http://localhost:8083/properties      # Speaker
curl -X POST http://localhost:8084/action/getStatus  # Shutter
```

---

## 🐛 Dépannage

### Le dashboard ne charge pas
1. Vérifiez que le Gateway tourne :
   ```bash
   curl http://localhost:8080/debug/time
   ```
2. Si erreur, redémarrez :
   ```bash
   cd gateway && ./mvnw spring-boot:run
   ```

### Un service ne répond pas
Consultez les logs :
```bash
tail -f logs/gateway.log
tail -f logs/thing-motion.log
tail -f logs/thing-leds.log
tail -f logs/thing-speaker.log
tail -f logs/thing-shutter.log
```

### Erreur "Failed to fetch"
- Le dashboard doit être ouvert via `http://localhost:8080/` (pas en file://)
- Vérifiez que tous les services sont démarrés

---

## 📋 Architecture

5 services Spring Boot indépendants :

| Service | Port | Rôle |
|---------|------|------|
| Gateway | 8080 | Logique centrale + Dashboard web |
| Motion | 8081 | Détecteur de mouvement |
| LEDs | 8082 | Contrôle éclairage |
| Speaker | 8083 | Contrôle audio |
| Shutter | 8084 | Contrôle volets |

---

## ✅ Checklist Avant Utilisation

- [ ] Tous les services démarrés (`./restart_all_services.sh`)
- [ ] Dashboard accessible (`http://localhost:8080/`)
- [ ] Badge "✅ Tous les services OK" affiché en haut à droite
- [ ] Toutes les cartes affichent des données (pas d'erreurs)

---

**Le dashboard se rafraîchit automatiquement toutes les 2 secondes !**
