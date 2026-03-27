# Fonctionnement détaillé du projet FRLC - Architecture et Implémentation

## 1. Vue d'ensemble du système

Le projet FRLC (Frame Representation Language of Corsica) est un système de représentation de connaissances basé sur les frames (structures de données hiérarchiques) implémenté en Common Lisp (SBCL) avec une interface web locale. L'architecture suit un modèle client-serveur où le serveur HTTP intégré expose une API REST JSON permettant de manipuler les frames via un navigateur.

## 2. Architecture du Backend - Système de Frames

### 2.1 Stockage des données

Les frames sont stockés dans une table de hachage globale `*frames-table*` définie dans `frlc-system/globals.lisp` (ligne 4). Cette variable est déclarée avec `defvar` pour persister entre les sessions REPL. La structure d'un frame est une liste associative (alist) où chaque élément est un slot, et chaque slot contient des facettes.

Format interne d'un frame :
```lisp
; Exemple de frame JEAN stocké dans *frames-table*
((NOM (VALUE "Jean Dupont"))
 (AGE (VALUE 25) (DEFAULT 0))
 (AKO (VALUE PERSONNE))
 (CLASSIFICATION (VALUE INSTANCE)))
```

### 2.2 Fonctions principales du backend

Le fichier `frlc-system/core-functions.lisp` contient l'API fondamentale :

**Création de frames (ligne 105-118)**
La fonction `Fcreate` prend un parent (ou liste de parents), un nom, et une classification. Elle initialise le frame avec un slot AKO contenant le parent pour l'héritage. Si le nom est nil, elle génère un nom unique via `Fgename`.

**Manipulation des valeurs (ligne 40-58, 93-102)**
`Fput` ajoute une valeur à un slot.facette sans déclencher de démons. Elle utilise `find-slot-pair` et `find-facet-pair` pour localiser l'emplacement exact dans la structure alist, puis modifie directement le cdr avec `set-frame` pour persister.

`Fremove` supprime une valeur spécifique d'un slot.facette (ligne 93-102). Elle utilise `remove-value-from-facet!` qui modifie la liste en place.

**Démons (ligne 129-134, 145-162)**
`Fput+` et `Fremove+` sont les versions qui déclenchent les démons. Après la modification, elles appellent `call-demons` (ligne 119-127) qui exécute les fonctions stockées dans les facettes `if-added` ou `if-removed`. Les variables spéciales `*frame*`, `*slot*`, `*facet*`, `*value*` sont bindées pendant l'exécution des démons.

### 2.3 Système d'héritage

Le fichier `frlc-system/inheritance.lisp` implémente trois stratégies de recherche :

- `Fget-I` (ligne 25-42) : Recherche en profondeur d'abord (DFS) suivant les liens AKO
- `Fget-N` (ligne 44-54) : Recherche value → defaut → if-needed (avec exécution des démons if-needed)
- `Fget-Z` (ligne 56-67) : Recherche en largeur d'abord (BFS)

La fonction `parents-of` (ligne 16-23) récupère les parents via le slot AKO, permettant l'héritage multiple.

## 3. Interface Web - Serveur HTTP

### 3.1 Architecture réseau

Le fichier `frlc-system/web.lisp` implémente un serveur HTTP minimaliste utilisant `sb-bsd-sockets` (ligne 4-5). Le serveur écoute sur localhost:8080 par défaut et utilise des streams binaires pour gérer correctement l'encodage UTF-8.

**Gestion des connexions (ligne 201-224)**
La fonction `%handle-connection` accepte les connexions TCP, lit la ligne de requête HTTP caractère par caractère jusqu'à trouver CRLF (ligne 76-89), parse l'URL et route vers le handler approprié.

**Format des réponses (ligne 62-71)**
Les réponses HTTP sont construites manuellement avec headers corrects (Content-Type, Content-Length en octets, Connection: close). Le Content-Length est calculé sur les octets UTF-8, pas les caractères, pour éviter les problèmes de connexion qui reste ouverte.

### 3.2 Endpoints API

L'API REST est gérée par `%handle-api` (ligne 157-203) avec les routes suivantes :

- `GET /api/frames` : Liste tous les frames avec leur classification (ligne 159)
- `GET /api/frame?name=XXX` : Retourne la structure complète d'un frame en JSON (ligne 161-168)
- `GET /api/create?parent=X&name=Y` : Crée un nouveau frame (ligne 169-179)
- `GET /api/put?frame=X&slot=Y&facet=Z&value=W` : Ajoute une valeur (ligne 180-202)
- `GET /api/putplus` : Idem avec démons
- `GET /api/remove` et `/api/removeplus` : Suppriment des valeurs (ajoutés récemment)

Le parsing des query strings est fait par `%parse-query` (ligne 128-142) qui décode les URL encodées avec `%url-decode` (ligne 109-126).

### 3.3 Sérialisation JSON

Les fonctions `%json-value`, `%json-string`, `%json-escape` (ligne 21-44) convertissent les structures Lisp en JSON. Les symboles sont convertis en chaînes, les listes en tableaux JSON, et les caractères spéciaux sont échappés.

## 4. Interface Web - Frontend

### 4.1 Structure HTML

Le fichier `frlc-system/web-ui.html` contient une single-page application avec :
- Panneau gauche : Liste des frames avec bouton Rafraîchir
- Panneau droit : Formulaire d'édition avec champs Frame, slot, facet, value
- Boutons d'action : Fput, Fput+, Fcreate, Fremove, Fremove+

### 4.2 Logique JavaScript

La fonction `api(path)` (ligne 89-93) fait des requêtes fetch vers le serveur local. Les fonctions `doPut()`, `doRemove()`, `doCreate()` (ligne 116-148) récupèrent les valeurs des champs, appellent l'API appropriée, puis rafraîchissent l'affichage.

Le rafraîchissement (`refresh`, ligne 94-106) récupère la liste des frames via `/api/frames` et reconstruit dynamiquement le DOM avec les badges de classification.

## 5. Flux de données complet

### Exemple : Création d'un frame via l'interface web

1. **Action utilisateur** : Remplit "Frame: JEAN", clique "Fcreate", entre "PERSONNE" dans le prompt parent
2. **JavaScript** : `doCreate()` appelle `fetch('/api/create?parent=PERSONNE&name=JEAN')`
3. **Serveur Lisp** : `%handle-api` route vers la clause `/api/create`
4. **Traitement** : 
   - `%parse-query` extrait parent=PERSONNE, name=JEAN
   - `Fcreate` est appelé avec (intern 'PERSONNE) (intern 'JEAN)
   - Un nouveau frame est créé dans `*frames-table*`
   - Slot AKO est peuplé avec PERSONNE
5. **Réponse** : JSON `{"ok":true}` retourné avec headers HTTP corrects
6. **JavaScript** : `refresh()` est appelé pour recharger la liste
7. **Affichage** : JEAN apparaît dans la liste avec badge INSTANCE

### Exemple : Ajout d'une valeur avec démons

1. **Action** : Frame=JEAN, slot=nom, facet=value, value="Dupont", clique Fput+
2. **JavaScript** : `doPut(true)` appelle `/api/putplus?...`
3. **Serveur** : Appelle `Fput+ 'JEAN 'nom 'value "Dupont"`
4. **Fput+** : 
   - Modifie la structure du frame dans `*frames-table*`
   - Appelle `call-demons` pour exécuter les if-added
   - Un démon pourrait créer d'autres slots automatiquement
5. **Réponse** : Succès retourné

## 6. Points d'extension et modularité

Le système est conçu pour être extensible :
- Nouveaux types de facettes peuvent être ajoutés dans `core-functions.lisp`
- Nouveaux endpoints API dans `%handle-api` dans `web.lisp`
- Nouveaux boutons dans `web-ui.html` avec handlers JavaScript correspondants
- Le système de démons permet d'ajouter des comportements automatiques sans modifier le code core

## 7. Fichiers d'entrée et scripts

- `frlc-system/frlc.lisp` : Point d'entrée qui charge tous les modules dans l'ordre correct
- `web-run.lisp` : Script de démarrage qui charge FRLC puis démarre le serveur web
- `run-web.bat` : Wrapper Windows pour lancer le serveur
- `test.bat` et `tribal-demo.bat` : Scripts de validation CLI

L'ordre de chargement dans `frlc.lisp` est critique : package → globals → data-structures → utilities → core-functions → inheritance → demons → persistence → interface → tribal-world. Cet ordre garantit que les dépendances sont résolues avant compilation.
