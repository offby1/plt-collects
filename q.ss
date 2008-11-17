;;; Stolen from SICP, and mzscheme-ified
#lang scheme
(provide
 (rename-out [my-make-queue make-queue])
 insert-queue!
 delete-queue!
 empty-queue?
 front-queue)

;; a mutable cons cell.  This is utterly pointless in most schemes,
;; but in mzscheme v4, cons cells are immutable by default; so in
;; order for this code to work in both v3 and v4, I just don't use the
;; built-in cons cells at all.

;; Note that, despite this cleverness, it still doesn't work in v3,
;; due to other incompatibilities.
(define-struct my-mcons (car cdr) #:transparent #:mutable)

(define-struct queue (front-ptr rear-ptr) #:transparent #:mutable)
(define (empty-queue? q) (null? (queue-front-ptr q)))

(define (front-queue q)
  (if (empty-queue? q)
      (error "FRONT called with an empty queue" q)
      (my-mcons-car (queue-front-ptr q))))

(define (insert-queue! q item)
  (let ((new-pair (make-my-mcons item '())))
    (cond ((empty-queue? q)
           (set-queue-front-ptr! q new-pair)
           (set-queue-rear-ptr! q new-pair)
           q)
          (else
           (set-my-mcons-cdr! (queue-rear-ptr q) new-pair)
           (set-queue-rear-ptr! q new-pair)
           q))))

(define (delete-queue! q)
  (cond ((empty-queue? q)
         (error "DELETE! called with an empty queue" q))
        (else
         (set-queue-front-ptr! q (my-mcons-cdr (queue-front-ptr q)))
         q)))

(define (my-make-queue seq)
  (let ((rv (make-queue '() '())))
    (for-each (lambda (item) (insert-queue! rv item))
              seq)
    rv))
