;;; Stolen from SICP, and mzscheme-ified
#lang scheme

(define-struct queue (front-ptr rear-ptr) #:transparent #:mutable)
(define (empty-queue? q) (null? (queue-front-ptr q)))

(define (front-queue q)
  (mcar (queue-front-ptr q)))

(define (insert-queue! q item)
  (let ((new-pair (mcons item '())))
    (if (empty-queue? q)
        (set-queue-front-ptr! q new-pair)
        (set-mcdr! (queue-rear-ptr q) new-pair))
    (set-queue-rear-ptr! q new-pair)
    q))

(define (delete-queue! q)
  (set-queue-front-ptr! q (mcdr (queue-front-ptr q)))
  q)

(define (my-make-queue seq)
  (let ((rv (make-queue '() '())))
    (for-each (lambda (item) (insert-queue! rv item))
              seq)
    rv))

(define non-empty-queue?
  (and/c queue? (not/c empty-queue?)))

(provide/contract [front-queue (-> non-empty-queue? any/c)]
                  [delete-queue! (-> non-empty-queue? queue?)]
                  [insert-queue! (-> queue? any/c non-empty-queue?)]
                  [rename my-make-queue make-queue (-> list? queue?)]
                  [empty-queue? (-> any/c boolean?)])