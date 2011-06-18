#lang scribble/manual

@(require planet/scribble
      "ssl-url.rkt"
      (for-label racket))

@title{The ssl-url collection}

This collection provides SSL-enabled variants of various functions
from net/url.  Each function's name begins with @racket[ssl:], and
works like the corresponding function from net/url, except that it
uses SSL to communicate with the remote server.

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
