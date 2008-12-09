#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id: round.scm 5767 2008-11-17 13:48:59Z erich $
exec  mzscheme --require "$0" --main -- ${1+"$@"}
|#

#lang scheme

(require
 (planet schematics/schemeunit:3)
 (planet schematics/schemeunit:3/text-ui)
 "round.ss")

(provide main)
(define (main . args)
  (exit
   (run-tests
    (test-suite
     "The one and only suite"
     (check-equal? (my-round 1.234 2) #e1.2)
     (check-equal? (my-round 1234 2) 1200)
     (check-exn exn:fail:contract? (lambda () (my-round 1.234 'snord)))
     (check-exn exn:fail:contract? (lambda () (my-round 'snord 10))))
    )))