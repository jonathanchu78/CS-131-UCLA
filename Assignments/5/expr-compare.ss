;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; I. expr-compare

;need to handle:
;lists
;quote
;lambda
;let
;if

(define return-expr
  (lambda(a b c d) 
    (cons a (cons b (cons c (cons d '()))))
  )
)

(define compare-quote
  (lambda (x y)
    (compare-const x y)
  )
)

(define compare-lambda
  (lambda (x y)
    ;just need to check what comes after "lambda"
    (if (equal? (car (cdr x)) (car (cdr y)))
      (compare-list x y)
      (compare-const x y)
    )
  )
)

;recursively compare the binds
(define (bind-equal x y)
  (if (and (equal? x '()) (equal? y '()))
    #t
    (if (equal? (car (car x)) (car (car y))) ;list nested in let binding
      (bind-equal (cdr x) (cdr y))
      #f
    )
  )
)

(define (make-bound x y)
  (string->symbol
    (string-append 
      (symbol->string (car x)) 
      (string-append 
        "!"
        (symbol->string (car y))
      )
    )
  )
)

(define (bind-if-neq x y) ;x is '((a c))
  ;(cons 
    (if (equal? (car x) (car y))
      (car x)
      (make-bound (car x) (car y))
    )
    ;(compare-list (cdr (car x)) (cdr (car y))) ;problem is here somewhere!
  ;)
)

(define (rest-of-bind x y)
  (compare-list (cdr (car x)) (cdr (car y)))
)

;recursively check elements from both in parallel
(define compare-list-z
  (lambda (x y a b z)
    (if (equal? x '())
      '()
      (if (equal? y '())
	'()
	(cons 
	  (if (equal? (car x) (car a))
	    z
	    (expr-compare (car x) (car y))
	  ) 
	  (compare-list-z (cdr x) (cdr y) a b z)
	)
      )
    )

  )
)

(define (bind-single x y) ;x is '(((a c)) a)
  (let ([z (bind-if-neq (car x) (car y))])
    ;(cons
      (cons z (rest-of-bind (car x) (car y)))
      ;(compare-list-z (cdr x) (cdr y) (cdr x) (cdr y) z)
    ;)
  )
)

(define (list-bind x y) ;x is '(((a c)) a)
  (if (equal? x '())
    '()
    (if (equal? y '())
      '()
      (let ([z (bind-if-neq (car x) (car y))])  
	(cons 
	  (cons z (rest-of-bind (car x) (car y))) 
	  (compare-list-z (cdr x) (cdr y) (cdr x) (cdr y) z)
	)
      )
      ;(cons
      ;  (bind-single x y)
;	(bind-single (cdr x) (cdr y))
  ;    )
    )
  )
)

(define (compare-let x y)
  (if (bind-equal (car (cdr x)) (car (cdr y)))
    (compare-list x y)
    (cons
      (car x)
      (list-bind (cdr x) (cdr y))
    )
  )
)

;recursively check elements from both in parallel
(define compare-list
  (lambda (x y)
    (if (equal? x '())
      '()
      (if (equal? y '())
	'()
	(cons (expr-compare (car x) (car y)) (compare-list (cdr x) (cdr y)))
      )
    )
  )
)

(define compare-const
  (lambda (x y)
    (if (equal? x y) 
      x 
      (if (and (equal? x #t) (equal? y #f)) '%
        (if (and (equal? x #f) (equal? y #t)) '(not %)
          (return-expr 'if '% x y)
	)
      )
    )
  )
)

(define both-built-in
  (lambda (x y)
    (case (car x)
      ('quote (compare-quote x y))
      ('lambda (compare-lambda x y))
      ('let (compare-let x y))
      (else (compare-list x y))
    )
  )
)

(define either-built-in
  (lambda (x y)
    (if (or 
	  (or (or (equal? (car x) 'quote)  (equal? (car y) 'quote))
              (or (equal? (car x) 'lambda) (equal? (car y) 'lambda))
	  )
	  (or (or (equal? (car x) 'let) (equal? (car y) 'let))
	      (or (equal? (car x) 'if) (equal? (car y) 'if))
	  )
        )
      (compare-const x y)
      (compare-list x y) 	
    )
  )
)

(define (expr-compare x y)
  (if (and (list? x) (list? y))
    (if (equal? (length x) (length y))
      (if (equal? (car x) (car y))
	(both-built-in x y)
	(either-built-in x y)
      )
      (compare-const x y)
    )
    (compare-const x y)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; II. test-expr-compare

(define (test-expr-compare x y)
  (let ((my_expr (expr-compare x y)))
    (if (and
      (equal?
        (eval (cons 'let (cons '((% #t)) (cons my_expr '() ))))
	(eval x)
      )
      (equal?
        (eval (cons 'let (cons '((% #f)) (cons my_expr '() ))))
	(eval y)
      ))
      #t
      #f
    )
  )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; III. test-expr-x and test-expr-y

;things that should be tested:
;quote
;let
;list
;lambda
;if
;cons

(define test-expr-x 
  '(cons
    (+  
      (let ((a 1) (b 2)) (list a b))
      (lambda (a b) (if a 5 10))
    )
    (cons
      (quote (a b)))
      (#t)
  )	
)

(define test-expr-y
  '(cons
    (+
      (let ((c 1) (b 2)) (cons e d))
      (lambda (z b) (if b 25 1))
    )
    (cons
      (quote (a b)))
      (#f)
  )
)















