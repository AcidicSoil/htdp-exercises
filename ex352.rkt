;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ex352) (read-case-sensitive #t) (teachpacks ((lib "abstraction.rkt" "teachpack" "2htdp") (lib "dir.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "abstraction.rkt" "teachpack" "2htdp") (lib "dir.rkt" "teachpack" "htdp")) #f)))
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

; A BSL-var-expr is one of: 
; – Number
; – Symbol 
; – (make-add BSL-var-expr BSL-var-expr)
; – (make-mul BSL-var-expr BSL-var-expr)


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

(define bv1 'x)
(define bv2 (make-add 'x 3))
(define bv3 (make-mul 1/2 (make-mul 'x 3)))
(define bv4 (make-add (make-mul 'x 'x) (make-mul 'y 'y)))



; .: Functions :.

; BSL-var-expr Symbol Number -> BSL-var-expr
; replaces all occurrences of x with v in the given expression
(define (subst ex x v)
  (cond
    [(number? ex) ex]
    [(symbol? ex) (if (symbol=? ex x) v ex)]
    [(add? ex) (make-add (subst (add-left ex) x v)
                         (subst (add-right ex) x v))]
    [(mul? ex) (make-mul (subst (mul-left ex) x v)
                         (subst (mul-right ex) x v))]))

(check-expect (subst bv1 'x 5) 5)
(check-expect (subst bv2 'x 5) (make-add 5 3))
(check-expect (subst bv3 'x 5) (make-mul 1/2 (make-mul 5 3)))
(check-expect (subst bv4 'x 5) (make-add (make-mul 5 5) (make-mul 'y 'y)))
(check-expect (subst (subst bv4 'x 5) 'y 3)
              (make-add (make-mul 5 5) (make-mul 3 3)))


; S-expr -> BSL-eval
; if the given S-expr can be parsed as a BSL-expr, evaluates it
(define (interpreter-expr sexp)
  (eval-expression (parse sexp)))

(check-expect (interpreter-expr '(+ 10 -10))
              (eval-expression be1))
(check-expect (interpreter-expr '(+ (* 20 3) 33))
              (eval-expression be2))
(check-expect (interpreter-expr '(+ (* 3.14 (* 2 3)) (* 3.14 (* -1 -9))))
              (eval-expression be3))
(check-expect (interpreter-expr '(+ -1 2))
              (eval-expression be4))
(check-expect (interpreter-expr '(+ (* -2 -3) 33))
              (eval-expression be5))
(check-expect (interpreter-expr '(* (+ 1 (* 2 3)) 3.14))
              (eval-expression be6))
(check-error (interpreter-expr "hello world") WRONG)
(check-error (interpreter-expr 'x) WRONG)
(check-error (interpreter-expr '(sqr 8)) WRONG)
(check-error (interpreter-expr '(1 2 3)) WRONG)
(check-error (interpreter-expr '(string-append "hello" "world")) WRONG)

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
