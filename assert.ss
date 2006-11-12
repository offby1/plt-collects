#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id$
exec mzscheme -qu "$0" ${1+"$@"}
|#

(module assert mzscheme
(provide (all-defined))

(define-syntax assert
  (syntax-rules ()
    ((assert _expr)
     (or _expr
         (error "failed assertion: " '_expr)))))

(define-syntax check-type
  (syntax-rules ()
    ((check-type _name-symbol _predicate _value)
     (or (_predicate _value)
         (raise-type-error _name-symbol (format "~a" _predicate) _value)))
    ((check-type _name-symbol _predicate _explanatory-string _value)
     (or (_predicate _value)
         (raise-type-error _name-symbol _explanatory-string _value)))))

(define (exit-if-failed thing)
  (if (not (zero? thing))
      (exit thing)))
)