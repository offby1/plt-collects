#lang scheme

;; returns the closest number to X that has exactly DIGITS significant
;; figures.
(define (my-round x digits)

  ;; Returns a representation of x in scientific notation.  The result
  ;; is a pair whose car is the mantissa, and whose cdr is the
  ;; exponent.  So, for example, (scientific 27) => (2.7 . 1), meaning
  ;; that 27 is equal to 2.7 times 10 ^ 1.

  (define (scientific x)
    (if (zero? x)
        (values 0 0)

      (let loop ((mantissa x)
                 (exponent 0))
        (if (and (>= (abs mantissa) 1)
                 (< (abs mantissa) 10))
            (values mantissa exponent)
          (if (>= (abs mantissa) 10)
              (loop (/ mantissa 10)
                    (+ exponent 1))
            (loop (* mantissa 10)
                  (- exponent 1)))))))

  (define (eggzackly x)
    (if (exact? x)
        x
      (inexact->exact x)))

  (let-values ([(mantissa exponent) (scientific x)])
    (* (eggzackly (round
                   (* mantissa (expt 10 (- digits 1)))))

       ;; You might be tempted to call `inexact->exact' on the return
       ;; from `expt' here, but that would be a mistake, because some
       ;; Schemes (such as Guile 1.3) don't have exact non-integers --
       ;; so that if, for example, `expt' returned 0.01,
       ;; `inexact->exact' on that value would yield zero instead of
       ;; 1/100.
       (expt 10 (+ exponent 1 (- digits))))))

(provide/contract [my-round (-> number? (and/c integer? positive? exact?) number?)])
