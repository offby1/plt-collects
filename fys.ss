#lang scheme

(define (fisher-yates-shuffle thing)
  (cond
   ((vector? thing)
    (apply vector (fisher-yates-shuffle (vector->list thing))))
   ((list? thing)
    (sort
     thing
     <
     #:key (lambda (_) (random))
     #:cache-keys? #t))
   (else
    (error 'fisher-yates-shuffle "Don't know what to do with ~s" thing))))

(define (fisher-yates-shuffle! v)
  (for ([(value index)
         (in-indexed
          (fisher-yates-shuffle v))])
    (vector-set! v index value)))

(provide
 fisher-yates-shuffle
 fisher-yates-shuffle!
 )
