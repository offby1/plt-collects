#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id$
exec mzscheme -M errortrace -qu "$0" ${1+"$@"}
|#

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

;; loses the nanosecond info.  Such is life.  TODO -- provide an
;; optional time-zone argument.
(define (PLT-date->srfi-19-date struct-date)
  (time-monotonic->date
   (make-time time-monotonic 0
              (find-seconds
               (date-second struct-date)
               (date-minute struct-date)
               (date-hour struct-date)
               (date-day struct-date)
               (date-month struct-date)
               (date-year struct-date)
               ))))

(define (zdate PLT-date)
  (date->string  (PLT-date->srfi-19-date PLT-date) "~Y-~m-~dT~X~z"))

(provide (all-defined))
)