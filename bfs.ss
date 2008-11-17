#lang scheme

(require
 "set.ss"
 "q.ss")

(provide bfs bfs-distance)
(define bfs-distance (make-parameter 0 (lambda (thing)
                                         (if (and (exact? thing)
                                                  (integer? thing)
                                                  (not (negative? thing)))
                                             thing
                                             (raise-type-error 'bfs-distance "Exact non-negative integer" thing)))))
(define (ep . args)
  (apply fprintf (cons (current-error-port)
                       args)))

(define-struct agenda-item (trail word depth))

(define (bfs start-node goal-node nodes-equal? node-neighbors . max-depth)

  (define *already-seen* (make-set))

  (define (already-seen? thing)
    (is-present? thing *already-seen*))

  (define (note! thing)
    (set! *already-seen* (add *already-seen* thing)))

  (define (enqueue! thing)
    (insert-queue! *the-queue* thing))

  (define *the-queue* (make-queue (list (make-agenda-item '() start-node 0))))

  (define (front)
    (front-queue *the-queue*))

  (define (pop-queue!)
    (begin0
        (front)
      (delete-queue! *the-queue*)))

  (define (loop max-depth)
    (if (empty-queue? *the-queue*) #f
        (let ((w     (agenda-item-word  (front)))
              (trail (agenda-item-trail (front)))
              (depth (agenda-item-depth (front))))

          (parameterize ((bfs-distance depth))
            (cond
             ((equal? (sub1 depth) max-depth)
              #f)
             ((nodes-equal? goal-node w) trail)
             (else
              (for-each (lambda (n)
                          (note! n)
                          (enqueue! (make-agenda-item (cons w trail) n (add1 depth))))
                        (filter-not already-seen? (node-neighbors w)))
              (pop-queue!)
              (loop max-depth)))))))
  (let ((rv (loop (if (null? max-depth) #f (car max-depth)))))
    (and rv (reverse (cons goal-node rv)))))
