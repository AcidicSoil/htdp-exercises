;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ex433) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
; [List-of 1String] N -> [List-of String]
; bundles chunks of s into strings of length n
; idea take n items and drop n at a time
(define (bundle s n)
  (cond
    [(empty? s) '()]
    [(zero? n) (error 'bundle "can't extract chunks of size zero")]
    [else
     (cons (implode (take s n)) (bundle (drop s n) n))]))

(check-expect (bundle (explode "abcdefg") 3) (list "abc" "def" "g"))
(check-expect (bundle '("a" "b") 3) (list "ab"))
(check-expect (bundle '() 3) '())
(check-error (bundle '("a" "b" "c") 0))

 
; [List-of X] N -> [List-of X]
; keeps the first n items from l if possible or everything
(define (take l n)
  (cond
    [(zero? n) '()]
    [(empty? l) '()]
    [else (cons (first l) (take (rest l) (sub1 n)))]))

(check-expect (take '() 0) '())
(check-expect (take '(a b c d e) 0) '())
(check-expect (take '() 3) '())
(check-expect (take '(a b c d e) 3) '(a b c))

 
; [List-of X] N -> [List-of X]
; removes the first n items from l if possible or everything
(define (drop l n)
  (cond
    [(zero? n) l]
    [(empty? l) l]
    [else (drop (rest l) (sub1 n))]))

(check-expect (drop '() 0) '())
(check-expect (drop '(a b c d e) 0) '(a b c d e))
(check-expect (drop '() 3) '())
(check-expect (drop '(a b c d e) 3) '(d e))