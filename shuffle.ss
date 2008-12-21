#lang scheme

(define (shuffle thing)
  (cond
   ((vector? thing)
    (apply vector (shuffle (vector->list thing))))
   ((list? thing)
    (sort
     thing
     <
     #:key (lambda (_) (random))
     #:cache-keys? #t))
   (else
    (error 'shuffle "Don't know what to do with ~s" thing))))

(provide shuffle)
