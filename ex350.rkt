;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ex350) (read-case-sensitive #t) (teachpacks ((lib "abstraction.rkt" "teachpack" "2htdp") (lib "dir.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "abstraction.rkt" "teachpack" "2htdp") (lib "dir.rkt" "teachpack" "htdp")) #f)))
; .: Constants :.
(define WRONG "invalid BSL-expr")

; .: Data definitions :.

(define-struct add [left right])
; An Addition is a structure:
;   (make-add BSL-expr BSL-expr)
; interpretation (make-add a b) is the sum of a and b

(define-struct mul [left right])
; A Multiplication is a structure:
;   (make-mul BSL-expr BSL-expr)
; interpretation (make-mul a b) is the product of a and b

(define-struct and* [left right])
; A Conjunction (AND) is a structure:
;   (make-and* BSL-bool BSL-bool)
; interpretation (make-and* a b) is the conjunction of a and b

(define-struct or* [left right])
; A Disjunction (OR) is a structure:
;   (make-or* BSL-bool BSL-bool)
; interpretation (make-or* a b) is the disjunction of a and b

(define-struct not* [p])
; A Negation (NOT) is a structure:
;   (make-not* BSL-bool)
; interpretation (make-not* p) is the negation of p

; A BSL-bool is one of the following:
; - Boolean
; - Conjunction
; - Disjunction
; - Negation

; A BSL-expr is one of the following:
; - Number
; - Addition
; - Multiplication

; A BSL-eval is a Number
; interpretation the result of evaluating a BSL-expr


; .: Data examples :.

(define be1 (make-add 10 -10))
(define be2 (make-add (make-mul 20 3) 33))
(define be3 (make-add (make-mul 3.14 (make-mul 2 3))
                      (make-mul 3.14 (make-mul -1 -9))))
(define be4 (make-add -1 2))
(define be5 (make-add (make-mul -2 -3) 33))
(define be6 (make-mul (make-add 1 (make-mul 2 3)) 3.14))

(define bb1 (make-or* #true (make-not* #true)))
(define bb2 (make-or* (make-and* #true #true) #true))
(define bb3 (make-or* (make-and* #false (make-and* #true #true))
                      (make-and* #false (make-and* (make-not* #true)
                                                   (make-not* #true)))))
(define bb4 (make-or* (make-not* #true) #true))
(define bb5 (make-or* (make-and* (make-not* #true) (make-not* #false)) #true))
(define bb6 (make-and* (make-or* #true (make-and* #true #true)) #true))



; .: Functions :.

; Q: What is unusual about the definition of this program with respect
; to the design recipe?
; A: parse-sl doesn't follow the usual template for its data definition.
; It should have two cond clauses, one for the case of an empty list
; and one for the case of a non-empty list, which should have one natural
; recursion. Instead, it has three cond clauses that refer to the length
; of the given list.

; S-expr -> BSL-expr
(define (parse s)
  (cond
    [(atom? s) (parse-atom s)]
    [else (parse-sl s)]))

(check-expect (parse '(+ 10 -10)) be1)
(check-expect (parse '(+ (* 20 3) 33)) be2)
(check-expect (parse '(+ (* 3.14 (* 2 3)) (* 3.14 (* -1 -9)))) be3)
(check-expect (parse '(+ -1 2)) be4)
(check-expect (parse '(+ (* -2 -3) 33)) be5)
(check-expect (parse '(* (+ 1 (* 2 3)) 3.14)) be6)
(check-error (parse "hello world") WRONG)
(check-error (parse 'x) WRONG)
(check-error (parse '(sqr 8)) WRONG)
(check-error (parse '(1 2 3)) WRONG)
(check-error (parse '(string-append "hello" "world")) WRONG)
 
; SL -> BSL-expr 
(define (parse-sl s)
  (local ((define L (length s)))
    (cond
      [(< L 3) (error WRONG)]
      [(and (= L 3) (symbol? (first s)))
       (cond
         [(symbol=? (first s) '+)
          (make-add (parse (second s)) (parse (third s)))]
         [(symbol=? (first s) '*)
          (make-mul (parse (second s)) (parse (third s)))]
         [else (error WRONG)])]
      [else (error WRONG)])))
 
; Atom -> BSL-expr 
(define (parse-atom s)
  (cond
    [(number? s) s]
    [(string? s) (error WRONG)]
    [(symbol? s) (error WRONG)]))


; BSL-expr -> BSL-eval
; computes the value of the given BSL expression
(define (eval-expression be)
  (cond
    [(number? be) be]
    [(add? be) (+ (eval-expression (add-left be))
                  (eval-expression (add-right be)))]
    [(mul? be) (* (eval-expression (mul-left be))
                  (eval-expression (mul-right be)))]))

(check-expect (eval-expression be1) 0)
(check-expect (eval-expression be2) 93)
(check-expect (eval-expression be3) 47.1)
(check-expect (eval-expression be4) 1)
(check-expect (eval-expression be5) 39)
(check-expect (eval-expression be6) 21.98)


; BSL-bool -> BSL-eval
; computes the value of the given BSL Boolean expression
(define (eval-bool-expression bb)
  (cond
    [(boolean? bb) bb]
    [(not*? bb) (not (eval-bool-expression (not*-p bb)))]
    [(and*? bb) (and (eval-bool-expression (and*-left bb))
                     (eval-bool-expression (and*-right bb)))]
    [(or*? bb) (or (eval-bool-expression (or*-left bb))
                   (eval-bool-expression (or*-right bb)))]))

(check-expect (eval-bool-expression bb1) #true)
(check-expect (eval-bool-expression bb2) #true)
(check-expect (eval-bool-expression bb3) #false)
(check-expect (eval-bool-expression bb4) #true)
(check-expect (eval-bool-expression bb5) #true)
(check-expect (eval-bool-expression bb1) #true)


; Any -> Boolean
; Checks if x is an Atom
(define (atom? x)
  (or (number? x) (string? x) (symbol? x)))

(check-expect (atom? 69420) #true)
(check-expect (atom? "Meshuggah") #true)
(check-expect (atom? 'x) #true)
(check-expect (atom? '()) #false)
(check-expect (atom? #true) #false)

