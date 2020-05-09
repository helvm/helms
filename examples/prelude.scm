(define-syntax-rule (\ x body) (lambda (x) body))
(define-syntax-rule (true) (\ x  (\ y (x))))
(define-syntax-rule (false) (\ x  (\ y (y))))

(define-syntax-rule (S f g x) (f x (g x)))
(define-syntax-rule (K x y) (x))
(define-syntax-rule (I x) (x))
(define-syntax-rule (fix v)  (v (fix v)))
(define-syntax-rule (\ x body) (lambda (x) body) 

(define-combinator id template)
(define-combinator I (S K K))
(define-combinator Y (S S K (S (K (S S (S(S S K)))) K)))

(lambda (args) body)
(lambda1 arg body)
(\ arg -> body)
(\ arg . body)
(if test-expr then-expr else-expr)
                    
