#!/bin/bash

# Script pour démarrer tous les services IoT en arrière-plan

echo "🚀 Démarrage de tous les services IoT..."
echo ""

# Créer un dossier pour les logs
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
echo "⏳ Attente du démarrage des services (30 secondes)..."
sleep 30

echo ""
echo "✅ Tous les services devraient être démarrés !"
echo ""
echo "📊 Vérification des services :"
echo "  - Gateway (8080):      http://localhost:8080/debug/time"
echo "  - Motion (8081):       http://localhost:8081/properties"
echo "  - LEDs (8082):         http://localhost:8082/properties"
echo "  - Speaker (8083):      http://localhost:8083/properties"
echo "  - Shutter (8084):      http://localhost:8084/action/getStatus"
echo ""
echo "🌐 Pour ouvrir le dashboard, ouvrez dans votre navigateur :"
echo "   file://$(pwd)/ambiance_chill_dashboard.html"
echo ""
echo "📝 Les logs sont disponibles dans le dossier 'logs/'"
echo "🛑 Pour arrêter tous les services, exécutez: ./stop_all_services.sh"
