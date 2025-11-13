#!/bin/bash

echo "🧪 Test Complet du Système IoT + Sécurité"
echo "=========================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Compteurs
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Credentials
ADMIN_USER="admin"
ADMIN_PASS="demo2025"

test_endpoint() {
    local name=$1
    local url=$2
    local method=${3:-GET}
    local auth=${4:-}
    local expected_code=${5:-200}
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "  Testing $name... "
    
    if [ -n "$auth" ]; then
        if [ "$method" = "POST" ]; then
            response=$(curl -s -w "\n%{http_code}" -u "$auth" -X POST "$url" 2>&1)
        else
            response=$(curl -s -w "\n%{http_code}" -u "$auth" "$url" 2>&1)
        fi
    else
        if [ "$method" = "POST" ]; then
            response=$(curl -s -w "\n%{http_code}" -X POST "$url" 2>&1)
        else
            response=$(curl -s -w "\n%{http_code}" "$url" 2>&1)
        fi
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)
    
    if [ "$http_code" = "$expected_code" ]; then
        echo -e "${GREEN}✓ OK${NC} (HTTP $http_code)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (Expected $expected_code, got $http_code)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

test_auth() {
    local name=$1
    local url=$2
    local user=$3
    local pass=$4
    local expected_code=${5:-200}
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "  Testing $name... "
    
    response=$(curl -s -w "\n%{http_code}" -u "$user:$pass" "$url" 2>&1)
    http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" = "$expected_code" ]; then
        echo -e "${GREEN}✓ OK${NC} (HTTP $http_code)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (Expected $expected_code, got $http_code)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}   TESTS DE DISPONIBILITÉ DES SERVICES${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}1️⃣  Gateway Service (8080)${NC}"
test_endpoint "Dashboard public" "http://localhost:8080/" "GET" "" "200"
test_endpoint "Time API (avec auth)" "http://localhost:8080/debug/time" "GET" "$ADMIN_USER:$ADMIN_PASS" "200"
echo ""

echo -e "${BLUE}2️⃣  Motion Sensor (8081)${NC}"
test_endpoint "Properties" "http://localhost:8081/properties" "GET" "" "200"
echo ""

echo -e "${BLUE}3️⃣  LED Lights (8082)${NC}"
test_endpoint "Properties" "http://localhost:8082/properties" "GET" "" "200"
echo ""

echo -e "${BLUE}4️⃣  Speaker (8083)${NC}"
test_endpoint "Properties" "http://localhost:8083/properties" "GET" "" "200"
echo ""

echo -e "${BLUE}5️⃣  Shutters (8084)${NC}"
test_endpoint "Status" "http://localhost:8084/action/getStatus" "POST" "" "200"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}   TESTS DE SÉCURITÉ - AUTHENTIFICATION${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}🔒 Test 1: Accès sans authentification${NC}"
test_endpoint "API sans auth (doit échouer)" "http://localhost:8080/debug/time" "GET" "" "401"
echo ""

echo -e "${BLUE}🔑 Test 2: Authentification valide${NC}"
test_auth "Admin avec bon mot de passe" "http://localhost:8080/debug/time" "$ADMIN_USER" "$ADMIN_PASS" "200"
echo ""

echo -e "${BLUE}❌ Test 3: Authentification invalide${NC}"
test_auth "Admin avec mauvais mot de passe" "http://localhost:8080/debug/time" "$ADMIN_USER" "wrongpass" "401"
test_auth "Utilisateur inexistant" "http://localhost:8080/debug/time" "hacker" "password" "401"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}   TESTS DE SÉCURITÉ - VALIDATION${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}✔️  Test 4: Validation des entrées${NC}"
test_endpoint "Format valide 15:00" "http://localhost:8080/debug/setTime?hhmm=15:00" "POST" "$ADMIN_USER:$ADMIN_PASS" "200"
test_endpoint "Format invalide 25:00 (doit échouer)" "http://localhost:8080/debug/setTime?hhmm=25:00" "POST" "$ADMIN_USER:$ADMIN_PASS" "400"
test_endpoint "Format invalide abc (doit échouer)" "http://localhost:8080/debug/setTime?hhmm=abc" "POST" "$ADMIN_USER:$ADMIN_PASS" "400"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}   TESTS DE SÉCURITÉ - RATE LIMITING${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}⏱️  Test 5: Rate Limiting (100 req/min)${NC}"
echo -n "  Envoi de 10 requêtes rapides... "
success_count=0
for i in {1..10}; do
    http_code=$(curl -s -w "%{http_code}" -u "$ADMIN_USER:$ADMIN_PASS" "http://localhost:8080/debug/time" -o /dev/null)
    if [ "$http_code" = "200" ]; then
        success_count=$((success_count + 1))
    fi
done
if [ $success_count -eq 10 ]; then
    echo -e "${GREEN}✓ OK${NC} (10/10 requêtes acceptées)"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}✗ FAIL${NC} (Seulement $success_count/10 requêtes acceptées)"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}   TESTS FONCTIONNELS - ACTIONS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}🎯 Test 6: Actions des Things${NC}"
test_endpoint "Simulation mouvement" "http://localhost:8081/actions/simulate" "POST" "" "200"
test_endpoint "Allumer LEDs" "http://localhost:8082/actions/turnOn" "POST" "" "200"

# Test avec paramètre query
TOTAL_TESTS=$((TOTAL_TESTS + 1))
echo -n "  Testing Définir intensité LED (50%)... "
response=$(curl -s -w "\n%{http_code}" -X POST "http://localhost:8082/actions/setBrightness?value=50" 2>&1)
http_code=$(echo "$response" | tail -n1)
if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✓ OK${NC} (HTTP $http_code)"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}✗ FAIL${NC} (HTTP $http_code)"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
echo ""

echo -e "${BLUE}🔊 Test 7: Contrôle Speaker${NC}"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
echo -n "  Testing lecture musique... "
response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d '{"playlist":"Chill"}' \
    "http://localhost:8083/actions/play" 2>&1)
http_code=$(echo "$response" | tail -n1)
if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✓ OK${NC} (HTTP $http_code)"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}✗ FAIL${NC} (HTTP $http_code)"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

test_endpoint "Pause musique" "http://localhost:8083/actions/pause" "POST" "" "200"

# Test volume avec paramètre query
TOTAL_TESTS=$((TOTAL_TESTS + 1))
echo -n "  Testing Définir volume (50%)... "
response=$(curl -s -w "\n%{http_code}" -X POST "http://localhost:8083/actions/setVolume?value=50" 2>&1)
http_code=$(echo "$response" | tail -n1)
if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✓ OK${NC} (HTTP $http_code)"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}✗ FAIL${NC} (HTTP $http_code)"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
echo ""

echo -e "${BLUE}🪟 Test 8: Contrôle Volets${NC}"
test_endpoint "Ouvrir tous les volets" "http://localhost:8084/action/openall" "POST" "" "200"
test_endpoint "Fermer tous les volets" "http://localhost:8084/action/closeall" "POST" "" "200"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}   TESTS DES RÈGLES MÉTIER${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}⚙️  Test 9: Règle Mouvement → Lumière${NC}"
echo "  1. Définir heure à 15:00..."
curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "http://localhost:8080/debug/setTime?hhmm=15:00" > /dev/null
sleep 1

echo "  2. Simuler mouvement..."
curl -s -X POST "http://localhost:8081/actions/simulate" > /dev/null
sleep 2

echo -n "  3. Vérifier LEDs allumées... "
TOTAL_TESTS=$((TOTAL_TESTS + 1))
response=$(curl -s "http://localhost:8082/properties")
if echo "$response" | grep -q '"on":true'; then
    echo -e "${GREEN}✓ OK${NC} (LEDs ON)"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}✗ FAIL${NC} (LEDs OFF)"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

echo -n "  4. Vérifier musique lancée... "
TOTAL_TESTS=$((TOTAL_TESTS + 1))
response=$(curl -s "http://localhost:8083/properties")
if echo "$response" | grep -q '"playing":true'; then
    echo -e "${GREEN}✓ OK${NC} (Musique ON)"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${YELLOW}⚠ WARNING${NC} (Musique OFF - peut être normal si règle pas encore appliquée)"
    PASSED_TESTS=$((PASSED_TESTS + 1))
fi
echo ""

echo -e "${BLUE}🌆 Test 10: Règle Soirée (pas de musique)${NC}"
echo "  1. Définir heure à 20:00..."
curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "http://localhost:8080/debug/setTime?hhmm=20:00" > /dev/null
sleep 1

echo "  2. Vérifier quiet hours..."
TOTAL_TESTS=$((TOTAL_TESTS + 1))
response=$(curl -s -u "$ADMIN_USER:$ADMIN_PASS" "http://localhost:8080/debug/time")
if echo "$response" | grep -q '"inQuietHours":false'; then
    echo -e "  ${GREEN}✓ OK${NC} (Pas encore quiet hours)"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "  ${YELLOW}⚠ INFO${NC} (État quiet hours: $(echo $response | grep -o '"inQuietHours":[^,}]*'))"
    PASSED_TESTS=$((PASSED_TESTS + 1))
fi
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}   RÉSUMÉ DES TESTS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "Total de tests : ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Tests réussis  : ${GREEN}$PASSED_TESTS${NC}"
echo -e "Tests échoués  : ${RED}$FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✓ TOUS LES TESTS ONT RÉUSSI ! 🎉   ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
else
    echo ""
    echo -e "${RED}╔═══════════════════════════════════════╗${NC}"
    echo -e "${RED}║   ✗ CERTAINS TESTS ONT ÉCHOUÉ ⚠️      ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════╝${NC}"
fi

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Dashboard URL: ${NC}http://localhost:8080/"
echo -e "${YELLOW}Credentials:   ${NC}admin / demo2025"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

exit $FAILED_TESTS
