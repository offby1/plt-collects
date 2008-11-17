#lang scheme

(provide
 make-set
 is-present?)

(provide/contract [add (-> (and/c hash? immutable?)
                           any/c
                           (and/c hash? immutable?))] )

(define (add set item)
  (hash-update set item (lambda (_) #t) #f))

(define (make-set . words)
  (for/fold ([rv (make-immutable-hash '())])
      ([w (in-list words)])
      (add rv w)))

(define (is-present? word set)
  (hash-ref set word (lambda () #f)))
