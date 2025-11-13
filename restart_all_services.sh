#!/bin/bash

echo "🔄 Redémarrage de tous les services avec CORS..."
echo ""

# Arrêter tous les processus Maven/Java
echo "🛑 Arrêt des services existants..."
pkill -f "mvnw spring-boot:run"
sleep 5

# Créer le dossier logs
mkdir -p logs

# Fonction pour démarrer un service
start_service() {
    local service_name=$1
    local service_port=$2
    local service_dir=$3
    
    echo "  ➤ Démarrage de $service_name sur le port $service_port..."
    cd "$service_dir"
    chmod +x mvnw
    nohup ./mvnw spring-boot:run > "../logs/${service_name}.log" 2>&1 &
    echo $! > "../logs/${service_name}.pid"
    cd ..
}

# Démarrer tous les services
start_service "gateway" "8080" "gateway"
sleep 3
start_service "thing-motion" "8081" "thing-motion"
sleep 2
start_service "thing-leds" "8082" "thing-leds"
sleep 2
start_service "thing-speaker" "8083" "thing-speaker"
sleep 2
start_service "thing-shutter" "8084" "thing-shutter"

echo ""
echo "⏳ Attente du démarrage complet (40 secondes)..."
sleep 40

echo ""
echo "✅ Services redémarrés avec support CORS !"
echo ""
echo "🌐 Ouvrez dans votre navigateur:"
echo "   http://localhost:8090/ambiance_chill_dashboard.html"
echo ""
echo "📊 URLs de test :"
echo "  - Gateway:  http://localhost:8080/debug/time"
echo "  - Motion:   http://localhost:8081/properties"
echo "  - LEDs:     http://localhost:8082/properties"
echo "  - Speaker:  http://localhost:8083/properties"
echo "  - Shutter:  http://localhost:8084/action/getStatus"
