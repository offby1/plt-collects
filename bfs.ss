#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
exec mzscheme -M errortrace -qu "$0" ${1+"$@"}
|#

(module bfs mzscheme

(require
 (only (lib "1.ss" "srfi") remove)
 (only "set.ss" make-set is-present? add!)
 (planet "test.ss"     ("schematics" "schemeunit.plt" 2))
 (planet "text-ui.ss"  ("schematics" "schemeunit.plt" 2))
 "q.ss"
 )
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
    (add! thing *already-seen*))

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
                                  (remove already-seen? (node-neighbors w)))
                        (pop-queue!)
                        (loop max-depth)))))))
  (let ((rv (loop (if (null? max-depth) #f (car max-depth)))))
    (and rv (reverse (cons goal-node rv)))))

;;; A fake network, for testing.

(define nodes-equal? eq?)
(define (node-neighbors n)
  (cond
   ((assoc n '((start   a b)
               (a       start c)
               (b       start c e)
               (c       a b e)
               (e       b c d f)
               (d       e)
               (f       e goal)
               (goal    f)
               (outlier)
               (cycle-a cycle-b)
               (cycle-b cycle-a)
               ))
    => cdr)
   (else
    (error 'node-neighbors "Unknown node ~s" n))))

(test/text-ui
 (test-suite
  "The one and only suite"
  (test-not-false "basic"         (bfs 'start 'goal nodes-equal? node-neighbors))
  (test-not-false "inverse order" (bfs 'goal 'start nodes-equal? node-neighbors))
  (test-false     "outlier"       (bfs 'outlier 'goal nodes-equal? node-neighbors))
  (test-false     "cycle"         (bfs 'cycle-a 'goal nodes-equal? node-neighbors))

  (test-false "depth-constrained"
              (bfs 'start 'goal nodes-equal? node-neighbors 3))
  (test-not-false "no off-by-one errors in depth constraint"
                  (bfs 'start 'goal nodes-equal? node-neighbors 4))))

)