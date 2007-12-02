#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
#$Id$
exec mzscheme -M errortrace --no-init-file --mute-banner --version --require "$0" -p "text-ui.ss" "schematics" "schemeunit.plt" -e "(exit (test/text-ui hostinfo-tests 'verbose))"
|#
(module hostinfo mzscheme
(require (lib "dns.ss" "net")
         (only (planet "port.ss" ("schematics" "port.plt" ))
               port->string)
         (only (lib "misc.ss" "swindle")
               regexp-case)
         (lib "match.ss")
         (lib "process.ss")
         (lib "string.ss")
         ;;(lib "1.ss" "srfi")
         (only (lib "13.ss" "srfi")
               string-join)
         (lib "trace.ss"))

;; This should probalby be a parameter, and be provided
(define *nameserver*
  "208.67.220.220" ;; opendns.com.
  ;; (dns-find-nameserver)                 ; default
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

(define (ip-string->list str)
  (regexp-case
   str
   [#px"^([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})$" => (lambda args (cdr args))]
   [else #f]))

(define-struct (exn:fail:process           exn:fail        ) (                ) #f)
(define-struct (exn:fail:process:exit      exn:fail:process) (status exit-code) #f)
(define-struct (exn:fail:process:not-found exn:fail:process) (                ) #f)

(define (port->string/close ip)
  (begin0
      (port->string ip)
    (close-input-port ip)))

(define (fep . args)
  (apply find-executable-path args))
(trace fep)

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

    (fprintf (current-error-port) "args: ~s~%" args)

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
(trace shell-command->string)

(define (verbose-dns-get-name . args)
  (apply dns-get-name args))
(trace verbose-dns-get-name)

(define (try . components)
  (let ((got (with-handlers
                 ([exn:fail?
                   (lambda (e) #f)])

               (verbose-dns-get-name
                *nameserver*
                (string-join components ".")))))
    (and (not (equal? "nxdomain.guide.opendns.com" got))
         got)))
(trace try)

(provide (all-defined))
)
