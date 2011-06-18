#lang scribble/manual

@(require planet/scribble
      (for-label racket))

@title{The ssl-url collection}

This collection provides SSL-enabled variants of various functions from net/url.

Examples:

@racketblock[
(call/input-url
 (string->url "https://encrypted.google.com/")
 (curryr ssl:get-pure-port '())
 (curryr copy-port (current-output-port)))
]
