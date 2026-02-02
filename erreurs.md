PS D:\CORSE\semestre2\frlc-project> .\run-frlc-tests.ps1
Running FRLC tests with sbcl...
While evaluating the form starting at line 5, column 0
  of #P"D:/CORSE/semestre2/frlc-project/frlc-system/frlc.lisp":

debugger invoked on a SB-C::INPUT-ERROR-IN-LOAD in thread
#<THREAD tid=13232 "main thread" RUNNING {1100030003}>:
  READ error during LOAD:

    end of file on #<SB-INT:FORM-TRACKING-STREAM for "file D:\\CORSE\\semestre2\\frlc-project\\frlc-system\\utilities.lisp" {1100D341A3}>

    (in form starting at line: 14, column: 0, position: 364)

Type HELP for debugger help, or (SB-EXT:EXIT) to exit from SBCL.

restarts (invokable by number or by possibly-abbreviated name):
  0: [ABORT   ] Abort loading file "D:\\CORSE\\semestre2\\frlc-project\\frlc-system\\utilities.lisp".
  1: [RETRY   ] Retry EVAL of current toplevel form.
  2: [CONTINUE] Ignore error and continue loading file "D:\\CORSE\\semestre2\\frlc-project\\frlc-system\\frlc.lisp".
  3:            Abort loading file "D:\\CORSE\\semestre2\\frlc-project\\frlc-system\\frlc.lisp".
  4:            Ignore runtime option --load "frlc-system/frlc.lisp".
  5:            Skip rest of --eval and --load options.
  6:            Skip to toplevel READ/EVAL/PRINT loop.
  7: [EXIT    ] Exit SBCL (calling #'EXIT, killing the process).

(SB-C:COMPILER-ERROR SB-C::INPUT-ERROR-IN-LOAD :CONDITION #<END-OF-FILE {1100DA14B3}> :POSITION 364 :LINE/COL (14 . 0) :STREAM #<SB-INT:FORM-TRACKING-STREAM for "file D:\\CORSE\\semestre2\\frlc-project\\frlc-system\\utilities.lisp" {1100D341A3}>)        
0]