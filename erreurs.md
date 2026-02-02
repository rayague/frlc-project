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
While evaluating the form starting at line 7, column 0
  of #P"D:/CORSE/semestre2/frlc-project/frlc-system/frlc.lisp":

debugger invoked on a SB-C::INPUT-ERROR-IN-LOAD in thread
#<THREAD tid=656 "main thread" RUNNING {1100030003}>:
  READ error during LOAD:

    unmatched close parenthesis

      Line: 27, Column: 35, File-Position: 1002

      Stream: #<SB-INT:FORM-TRACKING-STREAM for "file D:\\CORSE\\semestre2\\frlc-project\\frlc-system\\interface.lisp" {110123E723}>

Type HELP for debugger help, or (SB-EXT:EXIT) to exit from SBCL.

restarts (invokable by number or by possibly-abbreviated name):
  0: [ABORT   ] Abort loading file "D:\\CORSE\\semestre2\\frlc-project\\frlc-system\\interface.lisp".
  1: [RETRY   ] Retry EVAL of current toplevel form.
  2: [CONTINUE] Ignore error and continue loading file "D:\\CORSE\\semestre2\\frlc-project\\frlc-system\\frlc.lisp".
  3:            Abort loading file "D:\\CORSE\\semestre2\\frlc-project\\frlc-system\\frlc.lisp".
  4:            Ignore runtime option --load "frlc-system/frlc.lisp".
  5:            Skip rest of --eval and --load options.
  6:            Skip to toplevel READ/EVAL/PRINT loop.
  7: [EXIT    ] Exit SBCL (calling #'EXIT, killing the process).

(SB-C:COMPILER-ERROR SB-C::INPUT-ERROR-IN-LOAD :CONDITION #<SB-INT:SIMPLE-READER-ERROR "unmatched close parenthesis" {1101371853}> :STREAM #<SB-INT:FORM-TRACKING-STREAM for "file D:\\CORSE\\semestre2\\frlc-project\\frlc-system\\interface.lisp" {110123E723}>)
0]