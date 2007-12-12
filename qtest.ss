#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id$
exec mzscheme -M errortrace --no-init-file --mute-banner --version --require "$0" -p "text-ui.ss" "schematics" "schemeunit.plt" -e "(exit (test/text-ui q-tests 'verbose))"
|#
(module qtest mzscheme
(require (lib "trace.ss")
         (planet "test.ss"    ("schematics" "schemeunit.plt" 2))
         (planet "util.ss"    ("schematics" "schemeunit.plt" 2))
         "q.ss")

(define q-tests

  (test-suite
   "ya"
   (test-case
    "yow"
    (let ((q (make-queue (list 1 2 3))))
      (check-equal? 1 (front-queue q))

      (delete-queue! q)
      (check-equal? 2 (front-queue q))
      (delete-queue! q)
      (delete-queue! q)
      (check-exn
       exn:fail?
       (lambda () (front-queue q) ))
      (insert-queue! q 'yow)
      (check-equal? 'yow (front-queue q))
      ))))

(provide q-tests)
)
