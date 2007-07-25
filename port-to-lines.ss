#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id$
exec mzscheme -M errortrace -qu "$0" ${1+"$@"}
|#

(module port-to-lines mzscheme

(require (only (lib "1.ss" "srfi")
               unfold))

;; just an example of using "unfold"
(define (port->lines ip)
  (unfold (lambda (ip)
            (eof-object? (peek-char ip)))
          read-line
          values
          ip))

(define (file->lines fn)
  (call-with-input-file fn port->lines))

(provide (all-defined))
)