#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id$
exec mzscheme -M errortrace -qu "$0" ${1+"$@"}
|#

;; zdate is a handy function that formats a struct:date in ISO-8601 style.

;; TODO: write an all-purpose "date->string" that checks its input --
;; if it's a SRFI-19 date, it simply applies SRFI-19's date->string to
;; its arguments; if it's a PLT date, it converts the date vis
;; PLT-date->srfi-19-date and then applies date->string to its arguments.

(module zdate mzscheme
(require (only (lib "date.ss")
               find-seconds)
         (only (lib "19.ss" "srfi")
               date->string
               date->time-monotonic
               current-date
               make-time
               time-monotonic
               time-monotonic->date
               time-second
               ))

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

(define (zdate PLT-date)
  (date->string  (PLT-date->srfi-19-date PLT-date) "~Y-~m-~dT~X~z"))

(provide (all-defined))
)