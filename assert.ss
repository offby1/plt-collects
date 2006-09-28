#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id$
exec mzscheme -qu "$0" ${1+"$@"}
|#

(module assert mzscheme
(provide assert)
(define-syntax assert
  (syntax-rules ()
    ((assert _expr)
     (or _expr
         (error "failed assertion: " '_expr))))))