FRLC - Frame Representation Language of Corsica

Ce dépôt contient une implémentation minimale du noyau FRLC en Common Lisp.
Fichiers principaux:
- frlc-core.lsp: noyau (variables globales, stockage, Fget, Fput, Fcreate...)
- frlc-demos.lsp: démons exemples
- frlc-interface.lsp: interface placeholder
- frlc-tribal.lsp: exemples Monde Tribal
- tests/: tests unitaires minimaux

Pour tester dans SBCL:

sbcl --load frlc-core.lsp --load tests/test-frames.lsp
