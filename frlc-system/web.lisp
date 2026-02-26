;;; web.lisp -- interface web locale FRLC (sans dependances externes)
(in-package :frlc)

 (eval-when (:compile-toplevel :load-toplevel :execute)
  (require :sb-bsd-sockets))

(defparameter *web-server-thread* nil)
(defparameter *web-server-socket* nil)
(defparameter *web-server-port* 8080)

(defun %string->utf8-octets (s)
  (sb-ext:string-to-octets (or s "") :external-format :utf-8))

(defun %octets->string (octets)
  (sb-ext:octets-to-string octets :external-format :utf-8))

(defun %http-write-octets (stream octets)
  (write-sequence octets stream)
  (finish-output stream))

(defun %json-escape (s)
  (with-output-to-string (out)
    (loop for ch across (princ-to-string s)
          do (case ch
               (#\" (write-string "\\\"" out))
               (#\\ (write-string "\\\\" out))
               (#\Newline (write-string "\\n" out))
               (#\Return (write-string "\\r" out))
               (#\Tab (write-string "\\t" out))
               (t (write-char ch out))))))

(defun %json-string (s)
  (format nil "\"~A\"" (%json-escape s)))

(defun %json-value (v)
  (cond
    ((null v) "null")
    ((eq v t) "true")
    ((numberp v) (princ-to-string v))
    ((symbolp v) (%json-string (symbol-name v)))
    ((stringp v) (%json-string v))
    ((listp v)
     (format nil "[~{~A~^,~}]" (mapcar #'%json-value v)))
    (t (%json-string (prin1-to-string v)))))

(defun %frames->json ()
  (format nil "{\"frames\":[~{~A~^,~}]}"
          (mapcar (lambda (f)
                    (format nil "{\"name\":~A,\"classification\":~A}"
                            (%json-value f)
                            (%json-value (first (Fget f 'CLASSIFICATION 'value)))))
                  (Fgetframes))))

(defun %frame->json (name)
  (let ((data (Fgetframe name)))
    (if data
        (format nil "{\"name\":~A,\"data\":~A}"
                (%json-value name)
                (%json-value data))
        "{\"error\":\"not_found\"}")))

(defun %http-response-bytes (stream status content-type body-octets)
  (let* ((b (or body-octets #()))
         (crlf (format nil "~C~C" #\Return #\Newline))
         (headers (concatenate 'string
                     "HTTP/1.1 " status crlf
                     "Content-Type: " content-type crlf
                     "Content-Length: " (princ-to-string (length b)) crlf
                     "Connection: close" crlf crlf)))
    (%http-write-octets stream (%string->utf8-octets headers))
    (%http-write-octets stream b)))

(defun %http-response (stream status content-type body)
  (%http-response-bytes stream status content-type (%string->utf8-octets body)))

(defun %read-request-line (stream)
  (handler-case
      (let ((buf (make-array 0 :element-type '(unsigned-byte 8) :adjustable t :fill-pointer 0)))
        (loop
          (let ((b (read-byte stream nil nil)))
            (when (null b) (return nil))
            (vector-push-extend b buf)
            (let ((n (length buf)))
              (when (and (>= n 2)
                         (= (aref buf (- n 2)) 13)
                         (= (aref buf (- n 1)) 10))
                (let ((line-bytes (subseq buf 0 (- n 2))))
                  (return (%octets->string line-bytes))))))))
    (error () nil)))

(defun %split-on-space (s)
  (let ((parts '())
        (current ""))
    (labels ((emit ()
               (when (> (length current) 0)
                 (push current parts)
                 (setf current ""))))
      (loop for ch across s
            do (if (char= ch #\Space)
                   (emit)
                   (setf current (concatenate 'string current (string ch)))))
      (emit)
      (nreverse parts))))

(defun %starts-with (s prefix)
  (and (<= (length prefix) (length s))
       (string= prefix s :end2 (length prefix))))

(defun %url-decode (s)
  (with-output-to-string (out)
    (let ((i 0)
          (n (length s)))
      (loop while (< i n)
            do (let ((ch (char s i)))
                 (cond
                   ((char= ch #\+)
                    (write-char #\Space out)
                    (incf i 1))
                   ((and (char= ch #\%) (<= (+ i 2) (1- n)))
                    (let* ((hex (subseq s (1+ i) (+ i 3)))
                           (code (parse-integer hex :radix 16 :junk-allowed t)))
                      (when code (write-char (code-char code) out)))
                    (incf i 3))
                   (t
                    (write-char ch out)
                    (incf i 1))))))))

(defun %parse-query (path)
  (let ((qpos (position #\? path)))
    (when qpos
      (let ((q (subseq path (1+ qpos))))
        (remove nil
                (mapcar (lambda (pair)
                          (let ((eqpos (position #\= pair)))
                            (when eqpos
                              (cons (string-downcase (%url-decode (subseq pair 0 eqpos)))
                                    (%url-decode (subseq pair (1+ eqpos)))))))
                        (loop with start = 0
                              for pos = (position #\& q :start start)
                              collect (if pos (subseq q start pos) (subseq q start))
                              while pos
                              do (setf start (1+ pos)))))))))

(defun %read-file-octets (path)
  (with-open-file (in path :direction :input :element-type '(unsigned-byte 8))
    (let ((out (make-array (file-length in) :element-type '(unsigned-byte 8))))
      (read-sequence out in)
      out)))

(defun %web-ui-path ()
  (let ((dir (make-pathname :name nil :type nil :defaults *load-pathname*)))
    (merge-pathnames #P"web-ui.html" dir)))

(defparameter *web-index-html-bytes*
  (load-time-value (%read-file-octets (%web-ui-path)) t))

(defun %handle-api (stream path)
  (cond
    ((string= path "/api/frames")
     (%http-response-bytes stream "200 OK" "application/json; charset=utf-8" (%string->utf8-octets (%frames->json))))
    ((%starts-with path "/api/frame")
     (let* ((query (%parse-query path))
            (name (cdr (assoc "name" query :test #'string=))))
       (if name
           (%http-response-bytes stream "200 OK" "application/json; charset=utf-8"
                                (%string->utf8-octets (%frame->json (intern (string-upcase name) :cl-user))))
           (%http-response-bytes stream "400 Bad Request" "application/json; charset=utf-8"
                                (%string->utf8-octets "{\"error\":\"missing_name\"}")))))
    ((%starts-with path "/api/create")
     (let* ((query (%parse-query path))
            (p (cdr (assoc "parent" query :test #'string=)))
            (n (cdr (assoc "name" query :test #'string=))))
       (if (and n (> (length n) 0))
           (progn
             (let* ((parent (and p (> (length p) 0) (intern (string-upcase p) :cl-user)))
                    (name (intern (string-upcase n) :cl-user)))
               (Fcreate parent name 'instance)
               (%http-response-bytes stream "200 OK" "application/json; charset=utf-8" (%string->utf8-octets "{\"ok\":true}"))))
           (%http-response-bytes stream "400 Bad Request" "application/json; charset=utf-8" (%string->utf8-octets "{\"error\":\"missing_name\"}")))))
    ((or (%starts-with path "/api/put") (%starts-with path "/api/putplus"))
     (let* ((is-plus (%starts-with path "/api/putplus"))
            (query (%parse-query path))
            (f (cdr (assoc "frame" query :test #'string=)))
            (s (cdr (assoc "slot" query :test #'string=)))
            (fac (cdr (assoc "facet" query :test #'string=)))
            (v (cdr (assoc "value" query :test #'string=))))
       (if (and f s fac)
           (handler-case
               (let* ((frame (intern (string-upcase f) :cl-user))
                      (slot (intern (string-upcase s) :cl-user))
                      (facet (intern (string-upcase fac) :cl-user))
                      (value (if (and v (> (length v) 0))
                                 (read-from-string v)
                                 nil)))
                 (if is-plus
                     (Fput+ frame slot facet value)
                     (Fput frame slot facet value))
                 (%http-response-bytes stream "200 OK" "application/json; charset=utf-8" (%string->utf8-octets "{\"ok\":true}")))
             (error (e)
               (%http-response-bytes stream "400 Bad Request" "application/json; charset=utf-8"
                                    (%string->utf8-octets (format nil "{\"ok\":false,\"error\":~A}" (%json-string (princ-to-string e)))))))
           (%http-response-bytes stream "400 Bad Request" "application/json; charset=utf-8" (%string->utf8-octets "{\"ok\":false,\"error\":\"missing_params\"}")))))
    (t (%http-response-bytes stream "404 Not Found" "application/json; charset=utf-8" (%string->utf8-octets "{\"error\":\"not_found\"}")))))

(defun %handle-connection (socket)
  (let* ((client (sb-bsd-sockets:socket-accept socket))
         (stream (sb-bsd-sockets:socket-make-stream client :input t :output t :element-type '(unsigned-byte 8) :buffering :full)))
    (unwind-protect
         (let ((line (%read-request-line stream)))
           (when line
             (let* ((parts (%split-on-space line))
                    (method (first parts))
                    (path (second parts)))
               ;; read headers until blank line
               (loop for h = (%read-request-line stream)
                     while (and h (> (length h) 0)))
               (cond
                 ((and path (%starts-with path "/api/"))
                  (%handle-api stream path))
                 ((and (string= method "GET") (or (string= path "/") (%starts-with path "/index")))
                 (%http-response-bytes stream "200 OK" "text/html; charset=utf-8" *web-index-html-bytes*))
                 (t (%http-response-bytes stream "404 Not Found" "text/plain; charset=utf-8" (%string->utf8-octets "Not found")))))))
      (ignore-errors (close stream))
      (ignore-errors (sb-bsd-sockets:socket-close client)))))

(defun start-web-server (&key (port 8080))
  "Demarre le serveur web FRLC sur PORT. Ne modifie pas l'etat FRLC." 
  (when *web-server-thread*
    (error "Web server already running"))
  (setf *web-server-port* port)
  (let ((sock (make-instance 'sb-bsd-sockets:inet-socket :type :stream :protocol :tcp)))
    (setf *web-server-socket* sock)
    (ignore-errors (setf (sb-bsd-sockets:sockopt-reuse-address sock) 1))
    (handler-case
        (sb-bsd-sockets:socket-bind sock #(127 0 0 1) port)
      (sb-bsd-sockets:address-in-use-error ()
        (setf *web-server-socket* nil)
        (ignore-errors (sb-bsd-sockets:socket-close sock))
        (error "Port ~A deja utilise. Ferme l'autre serveur (fenetre run-web.bat) ou lance sur un autre port." port)))
    (sb-bsd-sockets:socket-listen sock 50)
    (setf *web-server-thread*
          (sb-thread:make-thread
           (lambda ()
             (format t "FRLC Web: http://127.0.0.1:~A/~%" port)
             (loop
               (handler-case
                   (%handle-connection sock)
                 (error () (return)))))
           :name "frlc-web")))
  t)

(defun stop-web-server ()
  "Arrete le serveur web FRLC." 
  (when *web-server-socket*
    (ignore-errors (sb-bsd-sockets:socket-close *web-server-socket*))
    (setf *web-server-socket* nil))
  (when *web-server-thread*
    (ignore-errors (sb-thread:terminate-thread *web-server-thread*))
    (setf *web-server-thread* nil))
  t)

;;; Fin web.lisp
