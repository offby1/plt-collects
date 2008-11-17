;;; Stolen from SICP, and mzscheme-ified
#lang scheme
(provide
 (rename-out [my-make-queue make-queue])
 insert-queue!
 delete-queue!
 empty-queue?
 front-queue)

(define-struct queue (front-ptr rear-ptr) #:transparent #:mutable)
(define (empty-queue? q) (null? (queue-front-ptr q)))

(define (front-queue q)
  (if (empty-queue? q)
      (error "FRONT called with an empty queue" q)
      (mcar (queue-front-ptr q))))

(define (insert-queue! q item)
  (let ((new-pair (mcons item '())))
    (cond ((empty-queue? q)
           (set-queue-front-ptr! q new-pair)
           (set-queue-rear-ptr! q new-pair)
           q)
          (else
           (set-mcdr! (queue-rear-ptr q) new-pair)
           (set-queue-rear-ptr! q new-pair)
           q))))

(define (delete-queue! q)
  (cond ((empty-queue? q)
         (error "DELETE! called with an empty queue" q))
        (else
         (set-queue-front-ptr! q (mcdr (queue-front-ptr q)))
         q)))

(define (my-make-queue seq)
  (let ((rv (make-queue '() '())))
    (for-each (lambda (item) (insert-queue! rv item))
              seq)
    rv))
