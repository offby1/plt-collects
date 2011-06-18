#lang scribble/manual

@(require racket
          planet/scribble
          (only-in "ssl-url.rkt" ssl:get-pure-port)
          (for-label racket
                     (only-in "ssl-url.rkt" ssl:get-pure-port)
                     net/url))

@title{The ssl-url collection}

This collection provides SSL-enabled variants of various functions
from @racket[net/url].  Each function's name begins with
@racket[ssl:], and works like the corresponding function from
@racket[net/url], except that it uses SSL to communicate with the
remote server.

Here's a trivial call that doesn't use SSL:

@racketblock[

(call/input-url
 (string->url "http://www.google.com/")
 (curryr get-pure-port '())
 (curryr copy-port (current-output-port)))
]

Here's the SSL-enabled equivalent (the URL is different because
@url{https://www.google.com} redirects there):

@racketblock[
(call/input-url
 (string->url "https://encrypted.google.com/")
 (curryr ssl:get-pure-port '())
 (curryr copy-port (current-output-port)))
]

Just for fun, here's a list of the symbols that it exports.  I suspect
that only the ones whose names contain "port" are useful.

@;;nor do I have any idea why many of them end with a dot and a number.

@(define ssl-ns (module->namespace "ssl-url.rkt"))

@(define (begins-with s prefix)
  (and
   (<= (string-length prefix)
       (string-length s))
   (string=?
    (substring s 0 (string-length prefix))
    prefix)))


@(define (ends-with-a-number s)
   (regexp-match #rx"\\.[0-9]+$" s))

@(apply
  itemlist
  (map item
       (sort
        (filter (compose not ends-with-a-number)
                (filter
                 (curryr begins-with "ssl:")
                 (map symbol->string (namespace-mapped-symbols ssl-ns))))
        string<?)))
