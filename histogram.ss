#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
exec mzscheme -qu "$0" ${1+"$@"}
|#

(module histogram mzscheme
(require (lib "list.ss")
         (planet "test.ss"     ("schematics" "schemeunit.plt" 2))
         (planet "text-ui.ss"  ("schematics" "schemeunit.plt" 2)))

(provide list->histogram cdr-sort)

(define (list->histogram l)
  (let ((h (make-hash-table 'equal)))
    (for-each (lambda (elt)
                (let ((orig (hash-table-get h elt 0)))
                  (hash-table-put! h elt (add1 orig))))
              l)
    (hash-table-map h cons)))

;; makes it easier to test, if we know the order in which the pairs
;; appear.  Note that the mzlib "sort" function, happily, is stable.
(define (cdr-sort l)
  (sort l (lambda (a b)
            (< (cdr a)
               (cdr b)))))


(test/text-ui
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
      ((1 . 2) . 2))))))


)