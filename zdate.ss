#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id$
exec mzscheme -M errortrace -qu "$0" ${1+"$@"}
|#

;; zdate is a handy function that formats a struct:date in ISO-8601 style.

(module zdate mzscheme
(require (lib "kw.ss")
         (only (lib "date.ss")
               find-seconds)
         (only (lib "19.ss" "srfi")
               date->string
               date->time-monotonic
               current-date
               make-time
               time-monotonic
               time-monotonic->date
               time-second
               )
         (rename (lib "19.ss" "srfi") srfi-19:date? date?))

(define (all-purpose-date->string . args)
  (let ((thing (car args))
        (args (cdr args)))
    (cond
     ((srfi-19:date? thing)
      (apply date->string thing args))
     ((date? thing)
      (apply date->string (PLT-date->srfi-19-date thing) args))
     (else
      (error "Not a date:" thing)))))

;; I am only about 95% certain that srfi-19's "monotonic" time
;; corresponds to PLT's seconds.
(define (srfi-19-date->PLT-date struct-tm-date)
  (seconds->date (time-second (date->time-monotonic struct-tm-date))))

;; loses the nanosecond info.  Such is life.
(define (PLT-date->srfi-19-date struct-date . tz-offset)
  (let ((tz-offset (if (null? tz-offset)
                       0
                     (car tz-offset))))
    (apply
     time-monotonic->date
     (list
      (make-time time-monotonic 0
                 (find-seconds
                  (date-second struct-date)
                  (date-minute struct-date)
                  (date-hour struct-date)
                  (date-day struct-date)
                  (date-month struct-date)
                  (date-year struct-date)
                  ))
      tz-offset))))

(define/kw (zdate #:optional any-date)
  (when (not any-date)
    (set! any-date (seconds->date (current-seconds))))
  (all-purpose-date->string
   (if (integer? any-date)
       (seconds->date any-date)
     any-date) "~Y-~m-~dT~X~z"))

(provide (all-defined-except all-purpose-date->string)
         (rename all-purpose-date->string date->string))
)