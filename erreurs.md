PS D:\CORSE\semestre2\frlc-project> .\run-frlc-tests.ps1
Running FRLC tests with sbcl...

; file: D:/CORSE/semestre2/frlc-project/frlc-system/core-functions.lisp
; in: DEFUN FREMOVE => DEFUN CALL-DEMONS => DEFUN FINST
;     (FRLC::FSLOTS FRLC::ANCESTOR)
;
; caught STYLE-WARNING:
;   undefined function: FRLC::FSLOTS

;     (FRLC::INHERITANCE-LEVELS FRLC::INSTANCE)
;
; caught STYLE-WARNING:
;   undefined function: FRLC::INHERITANCE-LEVELS
;
; compilation unit finished
;   Undefined functions:
;     FSLOTS INHERITANCE-LEVELS
;   caught 2 STYLE-WARNING conditions

; file: D:/CORSE/semestre2/frlc-project/frlc-system/inheritance.lisp
; in: DEFUN FGET-I
;     ((FRLC::DFS (FRLC::F FRLC::VISITED)
;       (WHEN (AND FRLC::F (NOT #))
;         (LET (#)
;           (IF FRLC::RES
;               FRLC::RES
;               #))))
;      (FRLC::DFS FRLC::FRAME NIL))
;
; caught WARNING:
;   Duplicate definitions in ((DFS (F VISITED)
;                              (WHEN (AND F (NOT (FIND F VISITED :TEST #'EQUAL)))
;                                (LET ((RES (FGET F SLOT FACET)))
;                                  (IF RES
;                                      RES
;                                      (LET ((PS (PARENTS-OF F)))
;                                        (DOLIST (P PS)
;                                          (LET ((R (DFS P (CONS F VISITED))))
;                                            (WHEN R (RETURN R)))))))))
;                             (DFS FRAME NIL))

;     (FRLC::DFS FRLC::FRAME NIL)
;
; caught ERROR:
;   The lambda expression has a missing or non-list lambda list:
;     (LAMBDA FRAME (BLOCK DFS NIL))

;     (DEFUN FRLC::FGET-I (FRLC::FRAME FRLC::SLOT FRLC::FACET)
;       "Recherche profondeur d'abord: FRAME puis parents (AKO) gauche->droite.
;   Retourne la première liste de valeurs trouvée (non-nil)."
;       (LABELS ((FRLC::DFS (FRLC::F FRLC::VISITED) (WHEN # #))
;                (FRLC::DFS FRLC::FRAME NIL)))
;       (DEFUN FRLC::FGET-N (FRLC::FRAME FRLC::SLOT)
;         "Recherche depth-first value -> defaut -> if-needed (profondeur).
;   Si if-needed donne une valeur, retourne cette valeur (et ne la met pas automatiquement)."
;         (OR (FRLC::FGET-I FRLC::FRAME FRLC::SLOT 'FRLC::VALUE)
;             (FRLC::FGET-I FRLC::FRAME FRLC::SLOT 'FRLC::DEFAUT)
;             (LET (#)
;               (WHEN FRLC::RES #))))
;       (DEFUN FRLC::FGET-Z (FRLC::FRAME FRLC::SLOT)
;         "Recherche largeur d'abord; à chaque niveau: value, defaut, if-needed.
;   Retourne la première liste/valeur trouvée."
;         (LET ((FRLC::SEEN #) (FRLC::LEVEL #))
;           (LOOP FRLC::WHILE FRLC::LEVEL
;                 DO (PROGN # # # #))))
;       (DEFUN FRLC::FGETCLASSES (FRLC::FRAME)
;         "Liste des ascendants (AKO) sans doublon, profondeur-first order."
;         (LET ((FRLC::OUT 'NIL) (FRLC::SEEN 'NIL))
;           (LABELS (#)
;             (FRLC::DFS FRLC::FRAME)
;             (NREVERSE FRLC::OUT)))
;         (DEFUN FRLC::INHERITANCE-LEVELS (FRLC::FRAME)
;           "Retourne une liste de niveaux (listes) pour BFS: [[frame], [parents...], [parents-parents...]]"
;           (LET (# # #)
;             (FRLC::WHILE FRLC::CURRENT # #)
;             (NREVERSE FRLC::LEVELS)))))
;
; caught STYLE-WARNING:
;   The variable FRAME is defined but never used.

; file: D:/CORSE/semestre2/frlc-project/frlc-system/inheritance.lisp
; in: DEFUN FGET-I => DEFUN FGET-Z
;     (FRLC::CALL-DEMONS FRLC::F FRLC::SLOT 'FRLC::IF-NEEDED)
;
; caught STYLE-WARNING:
;   undefined function: FRLC::CALL-DEMONS

; in: DEFUN FGET-I => DEFUN FGETCLASSES => DEFUN INHERITANCE-LEVELS
;     (FRLC::WHILE FRLC::CURRENT (PUSH FRLC::CURRENT FRLC::LEVELS)
;      (LET ((FRLC::NEXT 'NIL))
;        (DOLIST (FRLC::F FRLC::CURRENT) (DOLIST (FRLC::P #) (UNLESS # # #)))
;        (SETF FRLC::CURRENT (NREVERSE FRLC::NEXT))))
;
; caught STYLE-WARNING:
;   undefined function: FRLC::WHILE
;
; compilation unit finished
;   Undefined functions:
;     CALL-DEMONS WHILE
;   caught 1 ERROR condition
;   caught 1 WARNING condition
;   caught 3 STYLE-WARNING conditions

; file: D:/CORSE/semestre2/frlc-project/frlc-system/demons.lisp
; in: DEFUN FAKO?
;     (FRLC::FGETCLASSES FRLC::A)
;
; caught STYLE-WARNING:
;   undefined function: FRLC::FGETCLASSES
;
; compilation unit finished
;   Undefined function:
;     FGETCLASSES
;   caught 1 STYLE-WARNING condition

; file: D:/CORSE/semestre2/frlc-project/frlc-system/interface.lisp
; in: DEFUN FCHILDREN
;     (LAMBDA (FRLC::K FRLC::V)
;       (WHEN
;           (FIND FRLC::PARENT (FRLC::FGET FRLC::K 'FRLC::AKO 'FRLC::VALUE) :TEST
;                 #'EQUAL)
;         (PUSH FRLC::K FRLC::OUT)))
;
; caught STYLE-WARNING:
;   The variable V is defined but never used.
;
; compilation unit finished
;   caught 1 STYLE-WARNING condition

; file: D:/CORSE/semestre2/frlc-project/frlc-system/interface.lisp
; in: DEFUN FWRITEFRAME
;     (DEFUN FRLC::FWRITEFRAME (FRLC::FRAME &OPTIONAL STREAM)
;       "Écrit la structure du FRAME sur STREAM (par défaut *standard-output*)."
;       (WITH-OUTPUT-TO-STRING (FRLC::S)
;         (PPRINT (FRLC::GET-FRAME FRLC::FRAME) FRLC::S)))
;
; caught STYLE-WARNING:
;   The variable STREAM is defined but never used.
;
; compilation unit finished
;   caught 1 STYLE-WARNING condition

; file: D:/CORSE/semestre2/frlc-project/frlc-system/tribal-world.lisp
; in: DEFUN SETUP-TRIBAL
;     (FRLC::FCREATE 'FRLC::OBJET 'FRLC::PERSONNE 'FRLC::PROTOTYPE)
;
; caught STYLE-WARNING:
;   undefined function: FRLC::FCREATE
;
; compilation unit finished
;   Undefined function:
;     FCREATE
;   caught 1 STYLE-WARNING condition

; file: D:/CORSE/semestre2/frlc-project/frlc-system/tribal-world.lisp
; in: DEFUN TRIBAL-CREATE-CHILD
;     (FRLC::FPUT+ FRLC::MOTHER 'FRLC::ENFANTS 'FRLC::VALUE FRLC::CHILD-NAME)
;
; caught STYLE-WARNING:
;   undefined function: FRLC::FPUT+
;
; compilation unit finished
;   Undefined function:
;     FPUT+
;   caught 1 STYLE-WARNING condition

; file: D:/CORSE/semestre2/frlc-project/frlc-system/frlc.lisp
; in: DEFUN INITIALIZE-FRLC
;     (FRLC::ROOT
;      (OR (FRLC::GET-FRAME 'FRLC::OBJET)
;          (FRLC::SET-FRAME 'FRLC::OBJET (FRLC::MAKE-EMPTY-FRAME))))
;
; caught STYLE-WARNING:
;   The variable ROOT is defined but never used.
;
; compilation unit finished
;   caught 1 STYLE-WARNING condition
FRLC initialized. Root frame 'Objet' created.

debugger invoked on a END-OF-FILE in thread
#<THREAD tid=4684 "main thread" RUNNING {1100030003}>:
  end of file on #<dynamic-extent STRING-INPUT-STREAM (unavailable) from "(load \" ...">

Type HELP for debugger help, or (SB-EXT:EXIT) to exit from SBCL.

restarts (invokable by number or by possibly-abbreviated name):
  0: [CONTINUE] Ignore runtime option --eval "(load \" frlc-system/tests.lisp\\) --eval (run-tests) --quit".
  1: [ABORT   ] Skip rest of --eval and --load options.
  2:            Skip to toplevel READ/EVAL/PRINT loop.
  3: [EXIT    ] Exit SBCL (calling #'EXIT, killing the process).

((FLET SB-IMPL::BASE-CHAR-IN :IN SB-IMPL::%INIT-STRING-INPUT-STREAM) #<SB-IMPL::STRING-INPUT-STREAM {5FF4B3}> T NIL)
0]