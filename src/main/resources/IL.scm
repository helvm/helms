#! /usr/bin/env racket
#lang racket/base

(define (add_pop) (list 'A))
(define (mul_pop) (list 'M))

(define (add . n) (list n (add_pop)))
(define (mul . n) (list n (mul_pop)))

(define (flatten x)
  (cond ((null? x) '())
    ((not (pair? x)) (list x))
    (else (append (flatten (car x))
      (flatten (cdr x))))))

(define (data) (list 1 (add (list 2 (mul 3)))))

(display (data))
(newline)
(display (flatten (data)))
(newline)

(define (data2) (list 1 (add 2 (mul 3 (add 4 (mul 5))))))

(display (data2))
(newline)
(display (flatten (data2)))
(newline)



(display (list 1 (+ 2 3)))
(newline)

;(define )

;(display (eval '1))
(newline)

;(display (apply list '(1 (+ 2 3))))
;(newline)

