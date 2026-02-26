# FRLC - Frame Representation Language of Corsica

## 🎯 Qu'est-ce que FRLC ?

FRLC est un **langage de programmation orienté données** basé sur le concept de **frames** (structures de données hiérarchiques). Il permet de :
- Créer des objets (frames) avec des propriétés (slots)
- Gérer l'héritage entre objets (AKO = A-Kind-Of)
- Utiliser des démons (fonctions automatiques déclenchées par les changements)
- Sauvegarder et charger des données

---

## 📋 Prérequis

Avant de commencer, assure-toi d'avoir :

1. **SBCL (Steel Bank Common Lisp)** installé
   - Télécharge-le depuis : https://www.sbcl.org/
   - Installe-le dans `C:\Program Files\Steel Bank Common Lisp\`

2. **Ce projet FRLC** téléchargé et décompressé

---

## 🚀 Démarrage Rapide

### Option 1 : Utilisation en Ligne de Commande (CLI)

#### 1. Lancer les tests (pour vérifier que tout fonctionne)

Double-clique sur **`test.bat`** ou ouvre un terminal et tape :

```powershell
.\test.bat
```

Tu devrais voir :
```
Running FRLC tests...
✓ Test1: creation de base OK
✓ Test2: heritage simple OK
...
SUCCESS: All tests passed!
```

#### 2. Lancer la démonstration "Monde Tribal"

Double-clique sur **`tribal-demo.bat`** ou tape :

```powershell
.\tribal-demo.bat
```

Cette démo montre :
- La création de personnages (Homme/Femme)
- Le mariage (avec vérifications)
- L'apprentissage de métiers
- La naissance d'enfants
- Les règles métiers automatiques

---

### Option 2 : Interface Web (Plus conviviale)

#### 1. Démarrer le serveur Web

Double-clique sur **`run-web.bat`** ou tape :

```powershell
.\run-web.bat
```

Tu verras :
```
Starting FRLC Web on http://127.0.0.1:8080/
FRLC initialized. Root frame 'Objet' created.
FRLC Web: http://127.0.0.1:8080/
```

**Important** : Laisse cette fenêtre ouverte ! C'est le serveur qui tourne.

#### 2. Ouvrir dans le navigateur

Ouvre ton navigateur et va à l'adresse :
```
http://127.0.0.1:8080/
```

Tu verras l'interface FRLC Web avec :
- **Panneau gauche** : Liste des frames existants
- **Panneau droit** : Édition et détails

#### 3. Utiliser l'interface

**Voir les frames existants :**
- Clique sur "Rafraîchir" pour voir la liste
- Clique sur un frame (ex: OBJET) pour le sélectionner

**Charger un frame :**
- Le nom du frame s'affiche dans le champ "Frame"
- Clique "Charger" pour voir sa structure

**Créer un nouveau frame :**
1. Entre un nom dans "Frame" (ex: `JEAN`)
2. Clique "Fcreate"
3. Choisis un parent (ex: `Personne`) dans la boîte de dialogue
4. Le frame est créé !

**Ajouter une valeur :**
1. Sélectionne un frame
2. Entre le slot (ex: `nom`)
3. Entre la facette (ex: `value` ou `defaut`)
4. Entre la valeur (ex: `"Dupont"` ou un symbole)
5. Clique "Fput" (ajoute sans démon) ou "Fput+" (ajoute avec démons)

**Arrêter le serveur :**
- Ferme la fenêtre `run-web.bat` (ou fais Ctrl+C)

---

## 📚 Concepts FRLC de Base

### Les Frames
Un **frame** est un objet qui contient des informations. Exemple :
```
PERSONNE
├── nom (slot)
│   └── value: "Dupont" (facette)
├── age (slot)
│   └── value: 30
└── AKO (slot spécial)
    └── value: [Objet] (héritage)
```

### Les Slots
Un **slot** est une propriété d'un frame. Exemples : `nom`, `age`, `travail`.

### Les Facettes
Une **facette** décrit comment utiliser la valeur :
- **`value`** : La valeur actuelle
- **`defaut`** : Valeur par défaut (héritée si pas de value)
- **`if-added`** : Démons exécutés quand on ajoute une valeur
- **`if-removed`** : Démons exécutés quand on supprime
- **`if-needed`** : Démons exécutés quand on demande la valeur

### L'Héritage (AKO)
Un frame peut **hériter** d'autres frames via le slot `AKO` (A-Kind-Of).

Exemple :
```
Personne hérite de Objet
  Jean hérite de Personne
```

---

## 🔧 Commandes Principales

### En Ligne de Commande (REPL SBCL)

Charge FRLC dans SBCL :
```lisp
(load "frlc-system/frlc.lisp")
(in-package :frlc)
(initialize-frlc)
```

**Créer un frame :**
```lisp
(Fcreate 'Objet 'Personne)
(Fput 'Personne 'nom 'defaut "Inconnu")
```

**Créer une instance :**
```lisp
(Fcreate 'Personne 'Jean)
(Fput 'Jean 'nom 'value "Jean Dupont")
(Fput 'Jean 'age 'value 25)
```

**Récupérer une valeur :**
```lisp
(Fget 'Jean 'nom 'value)           ; Valeur directe
(Fget-I 'Jean 'nom 'value)         ; Avec héritage (profondeur)
(Fget-N 'Jean 'nom)                ; value → defaut → if-needed
```

**Sauvegarder / Charger :**
```lisp
(Fsave "mes-frames.frlc")          ; Sauvegarde
(Flood "mes-frames.frlc")          ; Chargement
```

**Menu interactif :**
```lisp
(Fmenu)                            ; Menu texte interactif
```

---

## 🎮 Exemple Complet : Monde Tribal

Le fichier `tribal-demo.bat` montre un cas concret :

### Ce qui se passe :
1. **Création des prototypes** : `Personne`, `Homme`, `Femme`
2. **Création d'individus** : Jean, Pierre, Marie, Julie
3. **Mariage** : Jean ↔ Marie, Pierre ↔ Julie
   - Vérification : pas déjà marié, même sexe impossible
4. **Apprentissage** : Jean devient forgeron, Pierre chasseur
   - Seuls les hommes peuvent apprendre un métier
5. **Naissances** : Marie et Julie ont des enfants
   - Une femme doit être mariée pour avoir un enfant
   - Maximum 10 enfants
6. **Travail** : 
   - Les hommes exercent leur métier
   - Les femmes mariées peuvent avoir des enfants (travail)

### Résultat attendu :
```
SUCCES: JEAN et MARIE sont maintenant maries.
SUCCES: JEAN a appris le metier de FORGERON.
SUCCES: MARIE a donne naissance a PETITJEAN (un garcon).
```

---

## 📁 Structure du Projet

```
frlc-project/
├── README.md                    # Ce fichier
├── test.bat                     # Lancer les tests
├── tribal-demo.bat              # Lancer la démo Monde Tribal
├── run-web.bat                  # Lancer l'interface Web
│
├── frlc-system/                 # Code source FRLC
│   ├── package.lisp             # Définition du package
│   ├── globals.lisp             # Variables globales
│   ├── data-structures.lisp     # Structures de données
│   ├── utilities.lisp           # Fonctions utilitaires
│   ├── core-functions.lisp      # Fonctions de base (Fget, Fput, Fcreate...)
│   ├── inheritance.lisp         # Système d'héritage (Fget-I, Fget-N...)
│   ├── demons.lisp              # Système de démons
│   ├── persistence.lisp         # Sauvegarde/chargement (Fsave, Flood)
│   ├── interface.lisp           # Interface utilisateur (Fmenu, prédicats)
│   ├── tribal-world.lisp        # Logique métier Monde Tribal
│   ├── web.lisp                 # Serveur Web HTTP
│   ├── web-ui.html              # Interface Web (HTML/JS/CSS)
│   └── tests.lisp               # Tests unitaires
│
├── run-all.lisp                 # Script de test
├── web-run.lisp                 # Script de démarrage Web
└── demo.lisp                    # Démonstration basique
```

---

## 🐛 Dépannage

### Problème : "Port déjà utilisé"
**Solution** : Ferme l'autre fenêtre `run-web.bat` ou change le port dans `web-run.lisp` :
```lisp
(start-web-server :port 8081)  ; Au lieu de 8080
```

### Problème : La page reste blanche
**Solution** : Vérifie que :
1. SBCL est bien installé dans `C:\Program Files\Steel Bank Common Lisp\`
2. La fenêtre `run-web.bat` est ouverte et affiche "FRLC Web: http://..."
3. Tu as attendu 2-3 secondes après l'ouverture du navigateur

### Problème : "SBCL not found"
**Solution** : Installe SBCL ou modifie les fichiers `.bat` pour pointer vers ton installation SBCL.

---

## 📝 Fonctions Disponibles

### Fonctions de base
- `(Fcreate parent name [classification])` - Créer un frame
- `(Fput frame slot facet value)` - Mettre une valeur
- `(Fget frame slot facet)` - Obtenir une valeur
- `(Finst parent [name])` - Créer une instance (déclenche les démons)
- `(Fremove frame slot facet value)` - Supprimer une valeur
- `(Fput+ ...)` et `(Fremove+ ...)` - Versions avec démons

### Recherches avec héritage
- `(Fget-I frame slot facet)` - Profondeur d'abord (depth-first)
- `(Fget-N frame slot)` - value → defaut → if-needed
- `(Fget-Z frame slot)` - Largeur d'abord (breadth-first)

### Prédicats
- `(Frame? name)` - Est-ce un frame existant ?
- `(Finstance? frame)` - Est-ce une instance ?
- `(Fgeneric? frame)` - Est-ce un prototype ?
- `(Fako? frame parent)` - Hérite-t-il de parent ?

### Interface
- `(Fmenu)` - Menu interactif terminal
- `(Fgetframes)` - Liste tous les frames
- `(Fslots frame)` - Liste les slots d'un frame
- `(Fwriteframe frame)` - Affiche la structure
- `(Fsave filename)` - Sauvegarde
- `(Flood filename)` - Chargement

### Web
- `(start-web-server :port 8080)` - Démarrer le serveur
- `(stop-web-server)` - Arrêter le serveur

---

## 🎓 Conseils pour Débutants

1. **Commence par la démo** : Lance `tribal-demo.bat` pour voir comment ça marche
2. **Utilise l'interface Web** : C'est plus visuel et intuitif que la ligne de commande
3. **Lis les erreurs** : FRLC donne des messages clairs (ex: "n'est pas mariee")
4. **Expérimente** : Crée tes propres frames et essaie les différentes fonctions

---

## ✅ Résumé des commandes rapides

| Action | Commande |
|--------|----------|
| Tests | `.\test.bat` |
| Démo Monde Tribal | `.\tribal-demo.bat` |
| Interface Web | `.\run-web.bat` puis http://127.0.0.1:8080/ |
| Arrêter le Web | Fermer la fenêtre run-web.bat |

---

**Bonne utilisation de FRLC ! 🎉**
