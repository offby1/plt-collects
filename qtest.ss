#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id$
exec  mzscheme --require "$0" --main -- ${1+"$@"}
|#

#lang scheme
(require (planet schematics/schemeunit:3)
         (planet schematics/schemeunit:3/text-ui)
         "q.ss")

(define q-tests

  (test-suite
   "ya"
   (let ((q (make-queue (list 1 2 3))))
     (check-equal? 1 (front-queue q))

     (delete-queue! q)
     (check-equal? 2 (front-queue q))
     (delete-queue! q)
     (delete-queue! q)
     (check-exn exn:fail:contract? (lambda () (front-queue q) ))
     (insert-queue! q 'yow)
     (check-equal? 'yow (front-queue q)))

   (check-exn exn:fail:contract? (lambda () (delete-queue! (make-queue '()))))))

(define (main . args)
  (exit (run-tests q-tests)))

(provide q-tests main)
