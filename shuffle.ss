#lang scheme

(define (shuffle thing)
  (cond
   ((vector? thing)
    (apply vector (shuffle (vector->list thing))))
   ((list? thing)

    ;; From Eli Barzilay.  This is essentially my old technique of
    ;; gluing a random number to each element, then sorting by those
    ;; numbers, then removing them.  But it's vastly shorter.
    (sort
     thing
     <
     #:key (lambda (_) (random))
     #:cache-keys? #t))
   (else
    (error 'shuffle "Don't know what to do with ~s" thing))))

(provide shuffle)
