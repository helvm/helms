

; Delayed evaluation functions
(define force
    (lambda (object)
	      (object)))

(define-syntax delay 
  (syntax-rules () 
    ((delay expression)
     (make-promise (lambda () expression)))))

(define make-promise
  (lambda (proc)
    (let ((result-ready? #f)
          (result #f))
      (lambda ()
        (if result-ready? 
            result
            (let ((x (proc)))
              (if result-ready?
                  result
                  (begin (set! result x)
                         (set! result-ready? #t)
                         result))))))))
