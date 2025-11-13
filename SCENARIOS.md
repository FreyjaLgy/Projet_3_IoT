# 🎬 Scénarios de Démonstration

## État Initial Recommandé

Avant de commencer les scénarios :
1. Ouvrir le dashboard : `http://localhost:8080/`
2. Cliquer sur "☀️ 15:00"
3. Cliquer sur "🔅 Éteindre" (LEDs OFF)
4. Cliquer sur "⏸️ Pause" (Enceinte OFF)
5. Cliquer sur "🔓 Tout Ouvrir" (Volets ouverts)

---

## 📋 Scénario 1 : Détection Après-midi (Jour Normal)

**Ce qu'on veut montrer** : Détection de mouvement l'après-midi → Lumière + Musique

### Actions :
1. Vérifier que l'heure est à **15:00** (carte "⏰ Heure Système")
2. Cliquer sur **"👋 Simuler Mouvement"** (carte "🚶 Mouvement")
3. Attendre 2 secondes

### Résultat attendu :
- ✅ LEDs : **État = 🟢 ON**
- ✅ Enceinte : **Lecture = ▶️ En lecture**
- ✅ Enceinte : **Playlist = Chill**
- ✅ Quiet Hours : **Non**

**Message** : "L'après-midi, quand on détecte un mouvement, la lumière s'allume et la playlist chill démarre automatiquement."

---

## 📋 Scénario 2 : Détection Soirée (Après 19h)

**Ce qu'on veut montrer** : Après 19h → Pas de musique automatique + Volets fermés

### Actions :
1. Cliquer sur **"🌆 20:00"** (carte "⏰ Heure Système")
2. Attendre 2 secondes (observer les volets)
3. Cliquer sur **"👋 Simuler Mouvement"**
4. Attendre 2 secondes

### Résultat attendu :
- ✅ Volets : **Tous 🔒 Fermés** (automatiquement après 19h)
- ✅ LEDs : **État = 🟢 ON**
- ❌ Enceinte : **Lecture = ⏸️ Pause** (pas de musique)
- ✅ Quiet Hours : **Non**

**Message** : "Après 19h, le système respecte le calme du soir : lumière oui, mais pas de musique automatique. Les volets se ferment aussi pour l'intimité."

---

## 📋 Scénario 3 : Quiet Hours (Nuit 22h-6h)

**Ce qu'on veut montrer** : Limitations automatiques la nuit

### Actions :
1. Cliquer sur **"🌙 23:00"** (carte "⏰ Heure Système")
2. Attendre 2 secondes
3. **Observer** l'indication : **"Quiet Hours: Oui (22h-6h)"**

#### Test du volume :
4. Aller à la carte "🔊 Enceinte"
5. Déplacer le slider de volume à **100%**
6. Cliquer sur **"🔉 Volume"**
7. Attendre 2 secondes

#### Test de l'intensité LED :
8. Cliquer sur **"👋 Simuler Mouvement"** (carte "🚶 Mouvement")
9. Attendre 2 secondes
10. Observer l'intensité des LEDs

### Résultat attendu :
- ✅ Quiet Hours : **Oui (22h-6h)**
- ✅ Volume : **Max 15%** (même si vous mettez 100%, limité à 15%)
- ✅ LEDs : **Intensité = 20%** (maximum en quiet hours)
- ✅ Volets : **🔒 Fermés**

**Message** : "Entre 22h et 6h, le système entre en mode Quiet Hours. Le volume est limité à 15% et la lumière à 20% pour ne pas déranger le sommeil."

---

## 📋 Scénario 4 : Contrôle Manuel (Override)

**Ce qu'on veut montrer** : L'utilisateur garde toujours le contrôle

### Actions (peu importe l'heure) :

#### LEDs :
1. Cliquer sur **"🔆 Allumer"** → ✅ Fonctionne
2. Mettre le slider à **80%**
3. Cliquer sur **"✨ Appliquer"** → ✅ Intensité à 80%
4. Cliquer sur **"🔅 Éteindre"** → ✅ Fonctionne

#### Enceinte :
5. Cliquer sur **"▶️ Play"** → ✅ Démarre la musique
6. Mettre le volume à **50%**
7. Cliquer sur **"🔉 Volume"** → ✅ Volume à 50%
8. Cliquer sur **"⏸️ Pause"** → ✅ Fonctionne

#### Volets :
9. Cliquer sur **"🔓 Tout Ouvrir"** → ✅ Tous ouverts
10. Cliquer sur **"🔒 Tout Fermer"** → ✅ Tous fermés

### Résultat attendu :
- ✅ Tous les contrôles manuels fonctionnent
- ✅ Les règles automatiques peuvent être outrepassées

**Message** : "Toutes les automatisations peuvent être outrepassées manuellement. L'utilisateur garde toujours le contrôle total via le dashboard."

---

## 📋 Scénario 5 : Comparaison Jour/Nuit (Rapide)

**Ce qu'on veut montrer** : Les différences selon l'heure

### Actions :
1. **15:00** → Simuler mouvement → Observer : Lumière 100% + Musique
2. **20:00** → Simuler mouvement → Observer : Lumière 100% + Pas de musique + Volets fermés
3. **23:00** → Simuler mouvement → Observer : Lumière 20% + Quiet Hours

### Résultat attendu :
Le comportement change automatiquement selon l'heure.

**Message** : "Le système s'adapte intelligemment à l'heure de la journée pour créer l'ambiance appropriée."

---

## 📋 Scénario 6 : Temps Réel (Dashboard Dynamique)

**Ce qu'on veut montrer** : Rafraîchissement automatique

### Actions :
1. Laisser le dashboard visible
2. Changer rapidement entre : **15:00 → 20:00 → 23:00 → Reset**
3. Observer les mises à jour

### Résultat attendu :
- ✅ Les valeurs se mettent à jour toutes les 2 secondes
- ✅ Le badge de statut reste vert "✅ Tous les services OK"
- ✅ Pas besoin de recharger la page

**Message** : "Le dashboard se rafraîchit automatiquement toutes les 2 secondes. Tout est en temps réel !"

---

## 💡 Conseils pour la Démo

### ✅ À FAIRE :
- Attendre 2 secondes entre chaque action (temps de rafraîchissement)
- Raconter une histoire : "Imaginez que vous rentrez chez vous à 15h..."
- Montrer le badge vert "✅ Tous les services OK"
- Expliquer POURQUOI chaque règle existe

### ❌ À ÉVITER :
- Ne pas cliquer trop vite
- Ne pas passer trop de temps sur les détails techniques
- Ne pas oublier de réinitialiser entre les scénarios

---

## 🎤 Script Ultra-Rapide (2 minutes)

### [Introduction - 15s]
> "Je vais vous montrer une maison intelligente qui adapte automatiquement l'éclairage, la musique et les volets selon l'heure et la détection de mouvement."

### [Démo 1 - Après-midi - 30s]
- 15:00 → Mouvement → Lumière + Musique
> "L'après-midi, ambiance chill automatique."

### [Démo 2 - Soirée - 30s]
- 20:00 → Mouvement → Lumière uniquement
> "Le soir, respect du calme : lumière mais pas de musique."

### [Démo 3 - Nuit - 40s]
- 23:00 → Quiet Hours → Limites automatiques
> "La nuit, protection du sommeil : volume et lumière limités."

### [Démo 4 - Manuel - 20s]
- Montrer les contrôles manuels
> "L'utilisateur garde toujours le contrôle."

### [Conclusion - 5s]
> "Confort automatique avec contrôle total. Questions ?"

---

## 📊 Récapitulatif des Résultats Attendus

| Heure | Mouvement | LED | Enceinte | Volets | Volume Max | LED Max |
|-------|-----------|-----|----------|--------|------------|---------|
| 15:00 | Oui | ON | Play | Ouverts | 100% | 100% |
| 20:00 | Oui | ON | Pause | Fermés | 100% | 100% |
| 23:00 | Oui | ON | Pause | Fermés | 15% | 20% |

---

**Bonne démonstration ! 🎉**
