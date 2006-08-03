;;; Stolen from SICP, and mzscheme-ified
(module q mzscheme
  (provide
   (rename my-make-queue make-queue)
   insert-queue!
   delete-queue!
   empty-queue?
   front-queue)

  (define-struct queue (front-ptr rear-ptr) #f)
  (define (empty-queue? q) (null? (queue-front-ptr q)))

  (define (front-queue q)
    (if (empty-queue? q)
        (error "FRONT called with an empty queue" q)
      (car (queue-front-ptr q))))

  (define (insert-queue! q item)
    (let ((new-pair (cons item '())))
      (cond ((empty-queue? q)
             (set-queue-front-ptr! q new-pair)
             (set-queue-rear-ptr! q new-pair)
             q)
            (else
             (set-cdr! (queue-rear-ptr q) new-pair)
             (set-queue-rear-ptr! q new-pair)
             q))))

  (define (delete-queue! q)
    (cond ((empty-queue? q)
           (error "DELETE! called with an empty queue" q))
          (else
           (set-queue-front-ptr! q (cdr (queue-front-ptr q)))
           q)))

  (define (my-make-queue seq)
    (let ((rv (make-queue '() '())))
      (for-each (lambda (item) (insert-queue! rv item))
                seq)
      rv))
  )
