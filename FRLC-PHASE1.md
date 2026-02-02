# FRLC PHASE1

Ce document décrit la Phase 1: implémentation minimaliste du langage FRLC.

## Fichiers sources
- frlc-system/package.lisp
- frlc-system/globals.lisp
- frlc-system/data-structures.lisp
- frlc-system/utilities.lisp
- frlc-system/core-functions.lisp
- frlc-system/inheritance.lisp
- frlc-system/demons.lisp
- frlc-system/interface.lisp
- frlc-system/persistence.lisp
- frlc-system/tribal-world.lisp
- frlc-system/frlc.lisp
- frlc-system/tests.lisp

## Instructions d'utilisation (SBCL)
Dans le répertoire `d:/Projects/frlc-project` lancer:

```bash
sbcl --load frlc-system/frlc.lisp --eval "(initialize-frlc)" --eval "(load \"frlc-system/tests.lisp\")" --eval "(run-tests)" --quit
```

Ou depuis un REPL SBCL:

```lisp
(load "frlc-system/frlc.lisp")
(in-package :frlc)
(initialize-frlc)
(run-tests)
```

## Tests et sorties attendues
- Test1: Création de base -> `✓ Test1: creation de base OK`
- Test2: Héritage simple -> `✓ Test2: heritage simple OK`
- Test3: Démons -> `✓ Test3: demons OK`
- Test4: Fget-N -> `✓ Test4: Fget-N OK`

## Remarques et limitations
- Implémentation fidèle à la spécification Phase1, minimaliste mais fonctionnelle.
- `Finst` déclenche `if-needed` via les démons et si ces démons retournent une valeur, celle-ci est affectée.
- `Fsave`/`Flood` sérialisent l'alist complet des frames; les fonctions (démons) sont référencées par symbole et doivent exister lors du chargement pour fonctionner.
- Gestion des cycles AKO: pas de détection sophistiquée au-delà d'éviter les revisites pendant les parcours.

## Prochaines étapes recommandées
- Compléter l'interface interactive `Fmenu`.
- Ajouter plus de tests, y compris cas d'héritage multiple et cycles.
- Améliorer sérialisation pour inclure le listage des démons et rétablir les liaisons de fonctions si nécessaire.

