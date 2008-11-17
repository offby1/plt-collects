#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id$
exec  mzscheme --require "$0" --main -- ${1+"$@"}
|#

#lang scheme

(define (file->lines fn)
  (call-with-input-file
      fn
    (lambda (ip)
      (for/list ([line (in-lines ip)])
        line))))

(define (main . args)
  (for ([fn (in-list args)])
    (for ([line (in-list (file->lines fn))])
      (display line)
      (newline))))

(provide (all-defined-out))
