#lang scheme

(provide
 make-set
 is-present?)

(define (make-set . words)
  (for/fold ([rv (make-immutable-hash '())])
      ([w (in-list words)])
      (hash-update rv w (lambda (_) #t) #f)))

(define (is-present? word set)
  (hash-ref set word (lambda () #f)))
