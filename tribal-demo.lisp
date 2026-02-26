;;; tribal-demo.lisp -- demonstration du Monde Tribal complet
(load "frlc-system/frlc.lisp")
(in-package :frlc)

(format t "~%##############################################~%")
(format t "### DEMONSTRATION DU MONDE TRIBAL COMPLET ###~%")
(format t "##############################################~%")

;; Initialisation
(initialize-frlc)
(setup-tribal)

;; Creation d'individus
(format t "~%--- Creation des individus ---~%")
(Fcreate 'Homme 'Jean)
(Fput 'Jean 'vivant 'value t)
(format t "Cree: Jean (Homme, vivant)~%")

(Fcreate 'Homme 'Pierre)
(Fput 'Pierre 'vivant 'value t)
(format t "Cree: Pierre (Homme, vivant)~%")

(Fcreate 'Femme 'Marie)
(Fput 'Marie 'vivant 'value t)
(format t "Cree: Marie (Femme, vivante)~%")

(Fcreate 'Femme 'Julie)
(Fput 'Julie 'vivant 'value t)
(format t "Cree: Julie (Femme, vivante)~%")

;; Tentative de mariage
(format t "~%--- Tentatives de mariage ---~%")
(tribal-mariage 'Jean 'Marie)  ; Devrait reussir
(tribal-mariage 'Pierre 'Julie)  ; Devrait reussir
(tribal-mariage 'Jean 'Julie)  ; Devrait echouer (Jean deja marie)

;; Apprentissage des metiers
(format t "~%--- Apprentissage des metiers ---~%")
(tribal-apprendre-metier 'Jean 'forgeron)
(tribal-apprendre-metier 'Pierre 'chasseur)
(tribal-apprendre-metier 'Marie 'couturiere)  ; Devrait echouer (c'est une femme)

;; Travail des hommes
(format t "~%--- Travail des hommes ---~%")
(tribal-travailler 'Jean)
(tribal-travailler 'Pierre)

;; Naissances (via le travail des femmes ou directement)
(format t "~%--- Naissances ---~%")
(tribal-naissance 'Marie 'PetitJean)  ; Devrait reussir
(tribal-naissance 'Marie 'PetiteMarie)  ; Devrait reussir
(tribal-naissance 'Julie 'PetitPierre)  ; Devrait reussir

;; Tentative erronee: mere non mariee
(format t "~%--- Test de securite: femme non mariee ---~%")
(let ((celibataire (Fcreate 'Femme 'Celibataire)))
  (declare (ignore celibataire))
  (Fput 'Celibataire 'vivant 'value t)
  (tribal-naissance 'Celibataire 'EnfantIllegitime))  ; Devrait echouer

;; Tentative erronee: mere inexistante
(format t "~%--- Test de securite: mere inexistante ---~%")
(tribal-naissance 'Inconnue 'EnfantOrphelin)  ; Devrait echouer

;; Travail des femmes (declenche naissances si mariees)
(format t "~%--- Travail des femmes ---~%")
(tribal-travailler 'Marie)  ; Devrait faire naitre un enfant
(tribal-travailler 'Julie)  ; Devrait faire naitre un enfant

;; Resume final
(format t "~%--- Resume de la tribu ---~%")
(format t "Frames crees: ~A~%" (Fgetframes))
(format t "Enfants de Marie: ~A~%" (get-enfants 'Marie))
(format t "Enfants de Julie: ~A~%" (get-enfants 'Julie))
(format t "~%##############################################~%")
(format t "### FIN DE LA DEMONSTRATION ###~%")
(format t "##############################################~%~%")
