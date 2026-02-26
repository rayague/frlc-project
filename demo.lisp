;;; demo.lisp -- demonstration de FRLC en action
(load "frlc-system/frlc.lisp")
(in-package :frlc)
(initialize-frlc)

(format t "~%=== DEMONSTRATION FRLC ===~%~%")

;; 1. Creation d'une hierarchie de frames
(format t "1. Creation des frames:~%")
(Fcreate 'Objet 'Vehicule)
(Fcreate 'Vehicule 'Voiture)
(Fcreate 'Voiture 'MaVoiture)
(format t "   - Vehicule cree (parent: Objet)~%")
(format t "   - Voiture cree (parent: Vehicule)~%")
(format t "   - MaVoiture cree (parent: Voiture)~%~%")

;; 2. Definition de slots et valeurs
(format t "2. Definition des proprietes:~%")
(Fput 'Vehicule 'type 'value "vehicule a moteur")
(Fput 'Voiture 'roues 'value 4)
(Fput 'Voiture 'portes 'defaut 4)
(Fput 'MaVoiture 'marque 'value "Toyota")
(Fput 'MaVoiture 'couleur 'value "rouge")
(format t "   - Vehicule.type = ~a~%" (Fget 'Vehicule 'type 'value))
(format t "   - Voiture.roues = ~a~%" (Fget 'Voiture 'roues 'value))
(format t "   - MaVoiture.marque = ~a~%" (Fget 'MaVoiture 'marque 'value))
(format t "   - MaVoiture.couleur = ~a~%~%" (Fget 'MaVoiture 'couleur 'value))

;; 3. Heritage (Fget-I - heritage en profondeur)
(format t "3. Heritage (Fget-I recherche recursive):~%")
(format t "   - MaVoiture herite de Voiture.roues: ~a~%" (Fget-I 'MaVoiture 'roues 'value))
(format t "   - MaVoiture herite de Vehicule.type: ~a~%" (Fget-I 'MaVoiture 'type 'value))
(format t "   - MaVoiture utilise defaut Voiture.portes: ~a~%~%" (Fget-I 'MaVoiture 'portes 'defaut))

;; 4. Demons (calcul automatique)
(format t "4. Demons (comportement automatique):~%")
(defun calcul-prix ()
  (format t "     [DEMON] Calcul du prix demande!~%")
  25000)
(Fput 'Voiture 'prix 'if-needed 'calcul-prix)
(format t "   - Premier acces au prix de MaVoiture:~%")
(let ((prix (Fget-N 'MaVoiture 'prix)))
  (format t "   - Prix calcule: ~a euros~%~%" prix))

;; 5. Visualisation des frames
(format t "5. Structure des frames creees:~%")
(format t "   - Objet: ~a~%" (Fgetframe 'Objet))
(format t "   - Vehicule: ~a~%" (Fgetframe 'Vehicule))
(format t "   - MaVoiture: ~a~%~%" (Fgetframe 'MaVoiture))

(format t "=== DEMONSTRATION TERMINEE ===~%")
