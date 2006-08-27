#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
exec mzscheme -qu "$0" ${1+"$@"}
|#

(module histogram mzscheme
(require (lib "list.ss")
         (planet "test.ss"     ("schematics" "schemeunit.plt" 2))
         (planet "text-ui.ss"  ("schematics" "schemeunit.plt" 2)))
(provide list->histogram)
(define (list->histogram l)
  (let ((h (make-hash-table)))
    (for-each (lambda (elt)
                (let ((orig (hash-table-get h elt 0)))
                  (hash-table-put! h elt (add1 orig))))
              l)
    (sort (hash-table-map h cons) (lambda (a b)
                                    (< (car a)
                                       (car b))))))

(test/text-ui
 (test-suite
  "The one and only suite"
  (test-case "duh" (check-equal? (list->histogram '(1 2 3 2 0 1 1 1 1 1 1))
                                 '((0 . 1) (1 . 7) (2 . 2) (3 . 1))))
  ))

)