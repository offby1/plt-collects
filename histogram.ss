#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id: v4-script-template.ss 5748 2008-11-17 01:57:34Z erich $
exec  mzscheme --require "$0" --main -- ${1+"$@"}
|#

#lang scheme

(require (planet schematics/schemeunit:3)
         (planet schematics/schemeunit:3/text-ui))

(provide list->histogram main)

(define (list->histogram l)
  (let ((h (make-hash)))
    (for-each (lambda (elt)
                (let ((orig (hash-ref h elt 0)))
                  (hash-set! h elt (add1 orig))))
              l)
    (hash-map h cons)))

;; makes it easier to test, if we know the order in which the pairs
;; appear.  Note that the mzlib "sort" function, happily, is stable.
(define (cdr-sort l)
  (sort l < #:key cdr))


(define (main . args)
  (exit
   (run-tests
    (test-suite
     "The one and only suite"
     (test-case "duh" (check-equal? (cdr-sort (list->histogram '(1 2 3 2 0 1 1 1 1 1 1)))
                                    '((0 . 1) (3 . 1) (2 . 2) (1 . 7))))
     (test-case
      "non-numbers"
      (check-equal?
       (cdr-sort (list->histogram '((1 . 2)
                                    (2 . 1)
                                    (1 . 2))))

       '(((2 . 1) . 1)
         ((1 . 2) . 2))))))))
