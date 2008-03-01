#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id$
exec mzscheme --no-init-file --mute-banner --version --require "$0"
|#
(module hostinfo mzscheme
(require (lib "dns.ss" "net")
         (planet "assert.ss" ("offby1" "offby1.plt"))
         (only (planet "port.ss" ("schematics" "port.plt" ))
               port->string)
         (only (lib "misc.ss" "swindle")
               regexp-case)
         (lib "match.ss")
         (only (planet "memoize.ss" ("dherman" "memoize.plt" )) define/memo*)
         (lib "process.ss")
         (lib "string.ss")
         (lib "trace.ss")
         (only (lib "13.ss" "srfi")
               string-join))

(define/memo* (get-name . args)
  (apply dns-get-name args))

(define/memo* (get-address . args)
  (apply dns-get-address args))

(define-syntax safely
  (syntax-rules ()
    ((safely _expr)
     (with-handlers ([exn:fail? (lambda (e) #f)])
       _expr))))

;; given a string, returns two values: the hostname described by the
;; string, and a guess as to the country in which that host lives.
(define (get-info hostname-or-ip-string)
  ;; These are the four numbers that make up the IP address.
  (define address (safely (string->ip-address  hostname-or-ip-string)))

  (define name (and (not address) hostname-or-ip-string))
  (when (not address)
    (set!
     address
     (safely
      (string->ip-address
       (get-address *nameserver* name)))))

  (when (not name)
    (set!
     name
     (safely
      (get-name *nameserver* (ip-address->string address)))))

  (values
   (or
    name
    (let ((address (ip-address->strings address)))
      (or
       (apply try address)
       (apply try  "in-addr.arpa" (reverse address))
       (apply try  "in-addr.arpa" (cdr (reverse address)))
       (apply try  "in-addr.arpa" (cddr (reverse address)))
       "??")))
   (safely
    (or
     (geoiplookup (ip-address->string address))
     (guess-country-from-hostname name)
     "??"))))

(define (guess-country-from-hostname str)
  (regexp-case
   str
   [(#px"\\.([[:alpha:]]{2})$" kaching) kaching]
   [else #f]))

;; This should probalby be a parameter, and be provided
(define *nameserver*
  ;;"208.67.220.220" ;; opendns.com.
  (dns-find-nameserver)                 ; default
  )

;; find as much information as possible about a machine, given its IP
;; address or host name.  Basically we do lots of name server lookups
;; on the address, like this:

;; Try the IP address as is.
;; Try the address with the octets reversed, and with `.in-addr.arpa'
;; appended.  That is, if the address in question is 209.53.16.180,
;; we'd try

;;   180.16.53.209.in-addr.arpa
;; and then
;;   16.53.209.in-addr.arpa
;; and then
;;   53.209.in-addr.arpa

(define (split-on-newlines str)
  (let ((ip (open-input-string str)))
    (let loop ((lines '()))
      (let ((one-line (read-line ip)))
        (if (eof-object? one-line)
            (reverse lines)
            (loop (cons one-line lines)))))))

(define (string->ip-address str)
  (regexp-case
   str
   [#px"^([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})$"
       =>
       (lambda args (apply public-make-ip-address (cdr args)))]
   [else (error 'string->ip-address "~s doesn't look like an IP address" str)]))

(define-struct ip-address (a b c d) #f)

(define (ip-address->strings ip)
  (check-type 'ip-address->strings ip-address? ip)
  (map number->string (cdr (vector->list (struct->vector ip)))))

(define (ip-address->string ip)
   (string-join (ip-address->strings ip) "."))

(define (public-make-ip-address a b c d)

  (define (puke datum)
    (error
     'public-make-ip-address
     "Wanted four dot-separated integers 'twixt 0 and 255 inclusive; but one of them was ~s"
     datum))

  (apply
   make-ip-address
   (map (lambda (str)
          (let ((datum (read-from-string str (lambda (e) (puke str)))))
            (when (not (byte? datum)) (puke datum))
            datum))
        (list a b c d))))

(define-struct (exn:fail:process           exn:fail        ) (                ) #f)
(define-struct (exn:fail:process:exit      exn:fail:process) (status exit-code) #f)
(define-struct (exn:fail:process:not-found exn:fail:process) (                ) #f)

(define (port->string/close ip)
  (begin0
      (port->string ip)
    (close-input-port ip)))

(define (fep . args)
  (apply find-executable-path args))

;; Strange that I had to write this myself.
(define (shell-command->string . args)
  (let ((command
         (let again ((command (car args))
                     (tries 0))
           (let ((found (fep command)))
             (or found
                 (and (< tries 1)
                      (eq? (system-type 'os) 'windows)
                      (again (string-append command ".exe") (add1 tries))))))))

    (when (not command)
      (raise (make-exn:fail:process:not-found
              (format "Subprocess ~s failed: ~a not found"
                      args (car args))
              (current-continuation-marks))))

    (match-let ([(stdout stdin pid stderr controller)
                 (apply process*  command (cdr args))])

      (close-output-port stdin)
      (controller 'wait)
      (when (not (eq? 'done-ok (controller 'status)))
        (raise (make-exn:fail:process:exit
                (format "Subprocess ~s failed: status ~a; exit code ~a"
                        args
                        (controller 'status)
                        (controller 'exit-code))
                (current-continuation-marks)
                (controller 'status)
                (controller 'exit-code))))
      (port->string/close stdout))))

(define (try . components)
  (let ((got (safely
               (get-name
                *nameserver*
                (string-join components ".")))))
    (and (not (equal? "nxdomain.guide.opendns.com" got))
         got)))

(define/memo* (geoiplookup h)
  (with-handlers
      ([exn:fail:process?
        (lambda (e) #f)])
    (regexp-case
     (car (split-on-newlines
           ;; The Debian package 'geoip-bin'
           ;; http://www.maxmind.com/download/geoip/api/c/
           (let again ((exe "geoiplookup")
                       (tries 1))
             (with-handlers
                 ([exn:fail:process:not-found?
                   (lambda (e)
                     (if (= 1 tries)
                         (again "/usr/bin/geoiplookup" (add1 tries))
                         (raise e)))])

               (shell-command->string exe h)))))
     [(#px"GeoIP Country Edition: (..)," iso-code)
         (and (not (equal? iso-code "--"))
              iso-code)]
     [#t #f])))

(provide get-info)
)
