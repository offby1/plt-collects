#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id$
exec mzscheme -qu "$0" ${1+"$@"}
|#

(module round mzscheme
(provide my-round)
(require
 (lib "assert.ss" "offby1")
 (planet "test.ss"     ("schematics" "schemeunit.plt" 2))
 (planet "text-ui.ss"  ("schematics" "schemeunit.plt" 2))
 (planet "util.ss"     ("schematics" "schemeunit.plt" 2)))
;; returns the closest number to X that has exactly DIGITS significant
;; figures.
(define (my-round x digits)

  ;; Returns a representation of x in scientific notation.  The result
  ;; is a pair whose car is the mantissa, and whose cdr is the
  ;; exponent.  So, for example, (scientific 27) => (2.7 . 1), meaning
  ;; that 27 is equal to 2.7 times 10 ^ 1.

  (define (scientific x)
    (if (zero? x)
        (cons 0 0)

      (let loop ((mantissa x)
                 (exponent 0))
        (if (and (>= (abs mantissa) 1)
                 (< (abs mantissa) 10))
            (cons mantissa exponent)
          (if (>= (abs mantissa) 10)
              (loop (/ mantissa 10)
                    (+ exponent 1))
            (loop (* mantissa 10)
                  (- exponent 1)))))))

  (define (eggzackly x)
    (if (exact? x)
        x
      (inexact->exact x)))

  (if (not (and
            (integer? digits)
            (positive? digits)))
      (error "Digits must be a positive integer, but is" digits))

  (let* ((s (scientific x))
         (mantissa (car s))
         (exponent (cdr s))
         (scale-factor (expt 10 (- digits 1))))

    (* (eggzackly (round
                   (* mantissa scale-factor)))

       ;; You might be tempted to call `inexact->exact' on the return
       ;; from `expt' here, but that would be a mistake, because some
       ;; Schemes (such as Guile 1.3) don't have exact non-integers --
       ;; so that if, for example, `expt' returned 0.01,
       ;; `inexact->exact' on that value would yield zero instead of
       ;; 1/100.
       (expt 10 (+ exponent 1 (- digits)))

       )))
(exit-if-failed
 (test/text-ui
  (test-equal?
   "yow"
   (my-round 1.234 2)
   #e1.2)

  ))
)