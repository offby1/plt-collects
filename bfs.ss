#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
exec mzscheme -M errortrace -qu "$0" ${1+"$@"}
|#

(module bfs mzscheme

  (require
   (only (lib "1.ss" "srfi") remove)
   (only "set.ss" make-set is-present? add!)
   "q.ss"
   )
  (provide bfs)
  
  (define (ep . args)
    (apply fprintf (cons (current-error-port)
                         args)))

  (define-struct agenda-item (trail word))
  
  (define (bfs start-node goal-node nodes-equal? node-neighbors)

    (define *already-seen* (make-set))
  
    (define (already-seen? thing)
      (is-present? thing *already-seen*))
  
    (define (note! thing)
      (add! thing *already-seen*))

    (define (enqueue! thing)
      (insert-queue! *the-queue* thing))
    
    (define *the-queue* (make-queue (list (make-agenda-item '() start-node))))

    (define (front)
      (front-queue *the-queue*))

    (define (pop-queue!)
      (begin0
        (front)
        (delete-queue! *the-queue*)))
    
    (define (loop)
      (if (empty-queue? *the-queue*) #f
        (let ((w     (agenda-item-word  (front)))
              (trail (agenda-item-trail (front))))

          (cond
           ((nodes-equal? goal-node w) trail)
           (else
            (for-each (lambda (n)
                        (note! n)
                        (enqueue! (make-agenda-item (cons w trail) n)))
                      (remove already-seen? (node-neighbors w)))
            (pop-queue!)
            (loop))))))

    (let ((rv (loop)))
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

  (printf "This should succeed: ~s~n" (bfs 'start 'goal nodes-equal? node-neighbors))
  (printf "This too: ~s~n"            (bfs 'goal 'start nodes-equal? node-neighbors))
  (printf "This should fail: ~s~n"    (bfs 'outlier 'goal nodes-equal? node-neighbors))
  (printf "This too: ~s~n"            (bfs 'cycle-a 'goal nodes-equal? node-neighbors))
  )