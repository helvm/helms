#! /usr/local/bin/racket
#lang racket/base


(define (divmod) (list 'E))
(define (trans)  (list 'T))
(define (addr)   (list 'A))
(define (out)    (list 'O))
(define (in)     (list 'I))
(define (sub)    (list 'S))
(define (hal)    (list 'H))
(define (nextl)  (list 'R))



(define (copy_ . n) (list n (hal)))
(define (copy    n) (copy_ (- 0 n)))
(define (swap  . n) (list n (hal)))
(define (addn  . n) (list 0 n (sub) (sub)))
(define (bnz   . a)  (list a (trans)))
(define (bz    . a)  (list a (trans))) ;;;;;;;

;(define (dup)    (list 0 (hal)))
(define (dup)    (list (copy 0)))
(define (add)    (list 0 (swap 1) (sub) (sub)))
;(define (jump . a) (list addr a (trans)))
(define (jump . a) (list addr (bnz a)) )
(define (exit)   (list (addr) 0 (trans)) )
;(define (skip . n) (list (addr) (add n) (trans)) )
(define (skip . n) (list (addr) (addr) (add n) (trans)) )
;(define (rem)    (list (addr) (addr) (trans)) )
(define (rem)    (list (skip 0)) )
(define (drop)   (list 0 (swap 1) (trans)) )
(define (drop0)  (list 0 (trans)))


(define (call . a) (list (addr) 1 a (trans)))

(define (param . n)  (build-list n (lambda (_) (swap n))))

(define (ret . n)  (list 1 (swap (+ 1 n)) (trans)))

(define (subn . n) (list n (sub)))
(define (div)    (list (divmod) (drop)))
(define (mod)    (list (divmod) (swap 1) (drop)))
(define (divn . n) (list n (div)))
(define (modn . n) (list n (mod)))


(define (outs)   (list
                   (nextl) (dup) (bz (addr)) (out) (bnz (addr) (subn 1))
                   (nextl) (drop0)
                 ) )



(define (flatten x)
  (cond ((null? x) '())
    ((not (pair? x)) (list x))
    (else (append (flatten (car x))
      (flatten (cdr x))))))

;(define (data) (bnz (addr) (subn 1)))
(define (data) (outs))

(display (data))
(newline)
(display (flatten (data)))
(newline)
