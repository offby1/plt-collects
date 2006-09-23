#| -- hey Emacs: leave that comment marker alone!!

This function solves a problem: You want to call a function
repeatedly with all possible combinations of arguments.  For
example, let's say you have a function `drive' which takes three
arguments: a string representing the name of a driver, a symbol
representing a car, and a number representing a distance.  And say
you have many drivers, many cars, and many distances, and you want
to call the function for each possible combination.  E.g:

(define drive
  (lambda (drivers-name
           car
           distance)
    (string-append drivers-name " drives " (symbol->string car) " " (number->string distance) " miles")))

(define drivers   (list "Sarah" "Tom" "Zippy"))
(define cars      (list 'Camaro 'Beat-up-old-Honda 'station-wagon))
(define distances (list 3 5 100))

If you do

(map (lambda (args)
       (apply drive args))
     (multiply (list drivers cars distances)))

you'll get

("Sarah drives camaro 3 miles"
 "Sarah drives camaro 5 miles"
 "Sarah drives camaro 100 miles"
 "Sarah drives beat-up-old-honda 3 miles"
 "Sarah drives beat-up-old-honda 5 miles"
 "Sarah drives beat-up-old-honda 100 miles"
 "Sarah drives station-wagon 3 miles"
 "Sarah drives station-wagon 5 miles"
 "Sarah drives station-wagon 100 miles"
 "Tom drives camaro 3 miles"
 "Tom drives camaro 5 miles"
 "Tom drives camaro 100 miles"
 "Tom drives beat-up-old-honda 3 miles"
 "Tom drives beat-up-old-honda 5 miles"
 "Tom drives beat-up-old-honda 100 miles"
 "Tom drives station-wagon 3 miles"
 "Tom drives station-wagon 5 miles"
 "Tom drives station-wagon 100 miles"
 "Zippy drives camaro 3 miles"
 "Zippy drives camaro 5 miles"
 "Zippy drives camaro 100 miles"
 "Zippy drives beat-up-old-honda 3 miles"
 "Zippy drives beat-up-old-honda 5 miles"
 "Zippy drives beat-up-old-honda 100 miles"
 "Zippy drives station-wagon 3 miles"
 "Zippy drives station-wagon 5 miles"
 "Zippy drives station-wagon 100 miles")

I think you could also describe this function as returning the
`Cartesian Product' of its arguments, if you consider the arguments
as defining `domain's.
|#
;; from kilimanjaro on #scheme
(module multiply mzscheme
(provide multiply)
(define (multiply list-of-lists)
  (define (foobar lst lsts)
    (if (null? lsts)
        (map list lst)
      (apply append (map (lambda (elt)
                           (map (lambda (x) (cons elt x)) lsts))
                         lst))))

  (if (null? list-of-lists)
      '()
    (foobar (car list-of-lists) (multiply (cdr list-of-lists))))))
