(define (dup) '(He H))
(define (zero) '(Ne))
(define (swap) '(Hte H))
(define (one) '(Nte))
(define (addn number) (append '(0 N) (list number) '(S S)))
(define (addn2 number) (list 'Ne 'N number 'S 'S))
;(define (add) '(S S))
(define (jump address) (append '(A N) (list address) '(T)))
(define (exit) '(A Ne T))
(define (skip number) (append '(A Ne N) (list number) '(S S T)))
(define (rem) '(A A T))
(define (drop) '(Ne Nte H T))

(define (call address) (append '(A Nte N) (list address) '(T)))

(define (beg