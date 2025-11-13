#!/bin/bash

# Script pour arrêter tous les services IoT

echo "🛑 Arrêt de tous les services IoT..."
echo ""

# Fonction pour arrêter un service
stop_service() {
    local service_name=$1
    local pid_file="logs/${service_name}.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if ps -p $pid > /dev/null 2>&1; then
            echo "  ➤ Arrêt de $service_name (PID: $pid)..."
            kill $pid
            rm "$pid_file"
        else
            echo "  ⚠ $service_name n'est pas en cours d'exécution"
            rm "$pid_file"
        fi
    else
        echo "  ⚠ Fichier PID introuvable pour $service_name"
    fi
}

# Arrêter tous les services
stop_service "gateway"
stop_service "thing-motion"
stop_service "thing-leds"
stop_service "thing-speaker"
stop_service "thing-shutter"

echo ""
echo "✅ Tous les services ont été arrêtés !"

# Optionnel : tuer tous les processus Maven Spring Boot restants
echo ""
read -p "❓ Voulez-vous forcer l'arrêt de tous les processus Maven/Java restants ? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    pkill -f "mvnw spring-boot:run"
    echo "✅ Tous les processus Maven ont été tués"
fi
