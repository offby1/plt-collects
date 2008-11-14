#lang scheme

(require scheme/date
         (prefix-in srfi-19- srfi/19)
         scheme/port
         (planet schematics/schemeunit:3))
(define (zdate
         [the-time (srfi-19-current-time)]
         #:format [format-string "~4"]
         #:offset [offset
                   (srfi-19-date-zone-offset
                    (srfi-19-time-utc->date (srfi-19-current-time)))])
  (cond

   ;; Something like "last week" -- let /bin/date parse that
   ((string? the-time)
    (let-values (((child
                   stdout-ip
                   stdin-op
                   stderr-ip)
                  (subprocess #f #f #f
                              "/bin/date"
                              "-u"
                              "+%s"
                              (format "--date=~a" the-time))))

      (close-output-port stdin-op)
      (subprocess-wait child)
      (let ((stat  (subprocess-status child)))
        (when (positive? stat)
          (copy-port stdout-ip (current-output-port))
          (copy-port stderr-ip (current-error-port))
          (close-input-port stderr-ip)
          (error 'zdate "/bin/date returned ~s" stat)))
      (let ((seconds-string (read-line stdout-ip)))
        (close-input-port stdout-ip)
        (zdate (string->number seconds-string) #:format format-string #:offset offset))))

   ;; Seconds since The Epoch, like a time_t
   ((integer? the-time)
    (zdate (srfi-19-make-time 'time-utc 0 the-time) #:format format-string #:offset offset))

   ((srfi-19-time? the-time)
    (srfi-19-date->string (srfi-19-time-utc->date the-time offset) format-string))

   ((srfi-19-date? the-time)
    (zdate (srfi-19-date->time-utc the-time) #:format format-string #:offset offset))

   ;; Scheme/date
   ((date? the-time)
    (zdate
     (srfi-19-make-date
      0
      (date-second           the-time)
      (date-minute           the-time)
      (date-hour             the-time)
      (date-day              the-time)
      (date-month            the-time)
      (date-year             the-time)
      (date-time-zone-offset the-time))
     #:format format-string
     #:offset offset))

   (else
    (error 'zdate "Don't know what to do with ~s" the-time))))

(provide zdate)
(check-equal? (zdate 0 #:offset 0) "1970-01-01T00:00:00Z")
(check-equal? (zdate "January 18, 1964" #:offset 0) "1964-01-18T00:00:00Z")
(check-equal? (zdate (srfi-19-make-time 'time-utc 0 0) #:offset 0) "1970-01-01T00:00:00Z")
(check-equal? (zdate (srfi-19-make-date 0 0 0 0 1 1 1970 0) #:offset 0) "1970-01-01T00:00:00Z")
(check-equal? (zdate (struct-copy
                      date
                      (seconds->date (find-seconds 0 0 0 1 1 1970))
                      [time-zone-offset 0])
                     #:offset 0)
              "1970-01-01T00:00:00Z")
