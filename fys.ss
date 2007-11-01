#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id$
exec mzscheme -M errortrace --no-init-file --mute-banner --version --require "$0" -p "text-ui.ss" "schematics" "schemeunit.plt" -e "(exit (test/text-ui fys-tests 'verbose))"
|#
(module fys mzscheme

(define (fisher-yates-shuffle! v)
  (define (swap! a b)
    (let ((tmp (vector-ref v a)))
      (vector-set! v a (vector-ref v b))
      (vector-set! v b tmp)))
  (do ((i 0 (add1 i)))
      ((= i (vector-length v))
       v)
    (let ((j (+ i (random (- (vector-length v) i)))))
      (swap! i j))))

(provide (all-defined))
)
