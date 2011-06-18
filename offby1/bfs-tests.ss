#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id: v4-script-template.ss 5748 2008-11-17 01:57:34Z erich $
exec  mzscheme --require "$0" --main -- ${1+"$@"}
|#

#lang scheme
(require "bfs.ss"
         (planet schematics/schemeunit:3)
         (planet schematics/schemeunit:3/text-ui))

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

(define (main . args)
  (exit
   (run-tests
    (test-suite
     "The one and only suite"
     (check-not-false  (bfs 'start 'goal nodes-equal? node-neighbors))
     (check-not-false  (bfs 'goal 'start nodes-equal? node-neighbors))
     (check-false      (bfs 'outlier 'goal nodes-equal? node-neighbors))
     (check-false      (bfs 'cycle-a 'goal nodes-equal? node-neighbors))

     (check-false     (bfs 'start 'goal nodes-equal? node-neighbors 3))
     (check-not-false (bfs 'start 'goal nodes-equal? node-neighbors 4))))))
(provide main)