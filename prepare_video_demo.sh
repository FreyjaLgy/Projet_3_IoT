#!/bin/bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║          PRÉPARATION POUR LA VIDÉO DE DÉMONSTRATION       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}[ÉTAPE 1]${NC} Vérification des services"
echo "───────────────────────────────────────────────────────────"

# Vérifier que tous les services tournent
SERVICES=("8080:Gateway" "8081:Motion" "8082:LEDs" "8083:Speaker" "8084:Shutter")
ALL_OK=true

for service in "${SERVICES[@]}"; do
    PORT="${service%%:*}"
    NAME="${service##*:}"
    
    if netstat -tlnp 2>/dev/null | grep -q ":$PORT " || ss -tlnp 2>/dev/null | grep -q ":$PORT "; then
        echo -e "${GREEN}✅ $NAME ($PORT)${NC}"
    else
        echo -e "${RED}❌ $NAME ($PORT) - SERVICE NON DÉMARRÉ${NC}"
        ALL_OK=false
    fi
done

if [ "$ALL_OK" = false ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Certains services ne sont pas démarrés${NC}"
    echo "   Exécutez : ./restart_all_services.sh"
    echo ""
    exit 1
fi

echo ""
echo -e "${BLUE}[ÉTAPE 2]${NC} Configuration de l'état initial"
echo "───────────────────────────────────────────────────────────"

# Attendre que les services soient prêts
sleep 2

# 1. Éteindre les LEDs
echo -e "${YELLOW}→${NC} Extinction des LEDs..."
curl -s -X POST http://localhost:8082/actions/turnOff > /dev/null 2>&1
sleep 1

# 2. Mettre le speaker en pause
echo -e "${YELLOW}→${NC} Mise en pause du speaker..."
curl -s -X POST http://localhost:8083/actions/pause > /dev/null 2>&1
sleep 1

# 3. Régler le volume à 25
echo -e "${YELLOW}→${NC} Réglage du volume à 25..."
curl -s -X POST http://localhost:8083/actions/setVolume \
  -H "Content-Type: application/json" \
  -d '{"value": 25}' > /dev/null 2>&1
sleep 1

# 4. Ouvrir tous les volets
echo -e "${YELLOW}→${NC} Ouverture des volets..."
curl -s -X POST http://localhost:8084/action/openall > /dev/null 2>&1
sleep 1

# 5. Régler l'heure à 15:00
echo -e "${YELLOW}→${NC} Réglage de l'heure à 15:00..."
curl -s -X POST http://localhost:8080/debug/setTime \
  -H "Content-Type: application/json" \
  -d '{"time": "15:00"}' > /dev/null 2>&1
sleep 1

echo -e "${GREEN}✅ Configuration initiale terminée${NC}"
echo ""

echo -e "${BLUE}[ÉTAPE 3]${NC} Vérification de l'état initial"
echo "───────────────────────────────────────────────────────────"

# Vérifier LEDs
LEDS_STATE=$(curl -s http://localhost:8082/properties)
if echo "$LEDS_STATE" | grep -q '"on":false'; then
    echo -e "${GREEN}✅ LEDs : OFF${NC}"
else
    echo -e "${YELLOW}⚠️  LEDs : ON (les éteindre manuellement)${NC}"
fi

# Vérifier Speaker
SPEAKER_STATE=$(curl -s http://localhost:8083/properties)
if echo "$SPEAKER_STATE" | grep -q '"playing":false'; then
    echo -e "${GREEN}✅ Speaker : Paused${NC}"
else
    echo -e "${YELLOW}⚠️  Speaker : Playing (le mettre en pause manuellement)${NC}"
fi

# Vérifier Volume
if echo "$SPEAKER_STATE" | grep -q '"volume":25'; then
    echo -e "${GREEN}✅ Volume : 25${NC}"
else
    VOL=$(echo "$SPEAKER_STATE" | grep -o '"volume":[0-9]*' | cut -d: -f2)
    echo -e "${YELLOW}⚠️  Volume : $VOL (ajuster à 25)${NC}"
fi

# Vérifier Shutters
SHUTTER_STATE=$(curl -s http://localhost:8084/action/getStatus)
if echo "$SHUTTER_STATE" | grep -q '"open":true'; then
    echo -e "${GREEN}✅ Volets : Ouverts${NC}"
else
    echo -e "${YELLOW}⚠️  Volets : Fermés (les ouvrir manuellement)${NC}"
fi

# Vérifier l'heure
TIME_STATE=$(curl -s http://localhost:8080/debug/time)
if echo "$TIME_STATE" | grep -q '"now":"15:'; then
    echo -e "${GREEN}✅ Heure : 15:00${NC}"
else
    CURRENT_TIME=$(echo "$TIME_STATE" | grep -o '"now":"[^"]*' | cut -d'"' -f4)
    echo -e "${YELLOW}⚠️  Heure : $CURRENT_TIME (ajuster à 15:00 dans le dashboard)${NC}"
fi

echo ""
echo -e "${BLUE}[ÉTAPE 4]${NC} URLs à ouvrir"
echo "───────────────────────────────────────────────────────────"
echo ""
echo "  🌐 Dashboard : http://localhost:8080/"
echo "     Login    : admin / demo2025"
echo ""
echo "  📊 Endpoints de test :"
echo "     Gateway  : http://localhost:8080/debug/time"
echo "     Motion   : http://localhost:8081/properties"
echo "     LEDs     : http://localhost:8082/properties"
echo "     Speaker  : http://localhost:8083/properties"
echo "     Shutter  : http://localhost:8084/action/getStatus"
echo ""

echo -e "${BLUE}[ÉTAPE 5]${NC} Commandes curl pour la vidéo"
echo "───────────────────────────────────────────────────────────"
echo ""
echo "# Discovery (montrer dans le terminal)"
echo "curl -s http://localhost:8082/properties | jq ."
echo ""
echo "# Write operation (changer brightness)"
echo "curl -X POST http://localhost:8082/actions/setBrightness \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{\"value\": 80}'"
echo ""
echo "# Action (lancer musique)"
echo "curl -X POST http://localhost:8083/actions/play \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{\"playlist\": \"Chill\"}'"
echo ""
echo "# Automation (déclencher mouvement)"
echo "curl -X POST http://localhost:8080/hooks/motion \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{\"thingId\":\"motion-1\"}'"
echo ""

echo -e "${BLUE}[ÉTAPE 6]${NC} Scénarios de démonstration"
echo "───────────────────────────────────────────────────────────"
echo ""
echo "📍 SCÉNARIO 1 : Règle de mouvement (15:00)"
echo "   1. S'assurer : LEDs OFF, Speaker Paused, Heure 15:00"
echo "   2. Cliquer sur '🚶 Simuler Mouvement'"
echo "   3. Observer : LEDs ON (brightness 35), Music ON (volume 25)"
echo ""
echo "📍 SCÉNARIO 2 : Quiet Hours (23:00)"
echo "   1. Changer l'heure à 23:00"
echo "   2. Éteindre LEDs et mettre en pause"
echo "   3. Cliquer sur '🚶 Simuler Mouvement'"
echo "   4. Observer : LEDs ON (brightness 20), Music ON (volume 15)"
echo ""
echo "📍 SCÉNARIO 3 : Volets automatiques (20:00)"
echo "   1. Changer l'heure à 20:00"
echo "   2. Ouvrir les volets manuellement"
echo "   3. Attendre 70 secondes"
echo "   4. Observer : Volets se ferment automatiquement"
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    ✅ PRÊT POUR L'ENREGISTREMENT            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Tous les services sont prêts !${NC}"
echo -e "${GREEN}État initial configuré !${NC}"
echo ""
echo -e "${YELLOW}Consultez SCRIPT_VIDEO_DEMO.md pour le script détaillé de la vidéo${NC}"
echo ""
echo "🎬 Bonne chance pour votre vidéo de démonstration ! 🎬"
echo ""
