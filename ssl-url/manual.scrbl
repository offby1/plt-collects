#lang scribble/manual

@(require planet/scribble
      (for-label racket))

@title{The ssl-url collection}

This collection provides SSL-enabled variants of various functions from net/url.

Examples:

@racketblock[
(call/input-url
 (string->url "https://encrypted.google.com/")
 (lambda (url)
   (ssl:get-pure-port
    url
    '()))

 (lambda (ip)
   (copy-port ip (current-output-port))))
]
