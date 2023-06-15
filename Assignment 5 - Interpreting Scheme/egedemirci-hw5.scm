(define get-operator
  (lambda (op-symbol)
    (cond
      ((eq? op-symbol '+) +)
      ((eq? op-symbol '*) *)
      ((eq? op-symbol '-) -)
      ((eq? op-symbol '/) /)
      (else #f)
    )
  )
)

(define operandControl
  (lambda (opList)
    (if (null? opList)
        #t
        (if (string? (car opList))
            #f
            (operandControl (cdr opList))
        )
    )
  )
)
(define op?
  (lambda (op-symbol)
    (cond
      ((eq? op-symbol '+) #t)
      ((eq? op-symbol '*) #t)
      ((eq? op-symbol '-) #t)
      ((eq? op-symbol '/) #t)
      (else #f)
    )
  )
)

(define get-value
  (lambda (var old-env new-env)
    (cond
      ((null? new-env)
       (display "cs305: ERROR \n\n")
       (repl old-env))
      ((equal? (caar new-env) var) (cdar new-env))
      (else (get-value var old-env (cdr new-env)))
    )
  )
)

(define extend-env
  (lambda (var val old-env)
    (cons (cons var val) old-env)
  )
)

(define define-expr?
  (lambda (e)
    (and (list? e) (= (length e) 3) (eq? (car e) 'define) (symbol? (cadr e)))
  )
)

(define if-expr?
  (lambda (e)
    (and (list? e) (= (length e) 4) (eq? (car e) 'if))
  )
)

(define cond-expr?
  (lambda (e)
    (and (list? e) (>= (length e) 3) (eq? (car e) 'cond) (cond-list? (cdr e)))
  )
)

(define member?
  (lambda (inSym inSeq)
    (cond
      ((null? inSeq) #f)
      ((eq? (car inSeq) inSym) #t)
      (else (member? inSym (cdr inSeq)))
    )
  )
)

(define search
  (lambda (lst lst2)
    (cond
      ((null? lst) #t)
      ((member? (caar lst) lst2) #f)
      (else (search (cdr lst) (cons (caar lst) lst2)))
    )
  )
)

(define let?
  (lambda (e)
    (and (list? e) (>= (length e) 3) (eq? (car e) 'let) (list? (cadr e)) (let-list? (cadr e)) (search (cadr e) '()))
  )
)

(define letstar?
  (lambda (e)
    (and (list? e) (>= (length e) 3) (eq? (car e) 'let*) (list? (cadr e)) (let-list? (cadr e)))
  )
)

(define let-list?
  (lambda (e)
    (cond
      ((null? e) #t)
      ((or (not (list? (car e))) (not (equal? (length (car e)) 2))) #f)
      ((not (symbol? (caar e))) #f)
      (else (let-list? (cdr e)))
    )
  )
)

(define operator?
  (lambda (oper)
    (and
      (list? oper)
      (not (null? oper))
      (if (equal? (op? (car oper)) #f) #f #t)
    )
  )
)

(define cond-list?
  (lambda (e)
    (if (null? e)
        #f
        (if (and (list? (car e)) (= (length (car e)) 2))
            (if (equal? (caar e) 'else)
                (if (null? (cdr e))
                    #t
                    #f
                )
                (cond-list? (cdr e))
            )
            #f
        )
    )
  )
)

(define repl
  (lambda (env)
    (let* (
             (dummy1 (display "cs305> "))
             (expr (read))
             (new-env (if (define-expr? expr)
                         (extend-env (cadr expr) (s6-interpret (caddr expr) env) env)
                         env
                       )
                     )
             (val (if (define-expr? expr)
                      (cadr expr)
                      (s6-interpret expr env)
                    )
                 )
             (dummy2 (display "cs305: "))
             (dummy3 (display val))
             (dummy4 (newline))
             (dummy5 (newline))
           )
      (repl new-env)
    )
  )
)

(define s6-interpret
  (lambda (e env)
    (cond
      ((number? e) e)
      ((symbol? e) (get-value e env env))
      ((not (list? e)) "ERROR")
      ((if-expr? e)
       (if (eq? (s6-interpret (cadr e) env) 0)
           (s6-interpret (cadddr e) env)
           (s6-interpret (caddr e) env)
       )
      )
      ((cond-expr? e)
       (if (= (length (cdr e)) 2)
           (if (eq? (s6-interpret (caadr e) env) 0)
               (s6-interpret (car (cdaddr e)) env)
               (s6-interpret (cadadr e) env)
           )
           (if (eq? (s6-interpret (caadr e) env) 0)
               (s6-interpret (cons (car e) (cddr e)) env)
               (s6-interpret (cadadr e) env)
           )
       )
      )
      ((let? e)
       (let*
         ((valueList (map s6-interpret (map cadr (cadr e)) (make-list (length (map cadr (cadr e))) env)))
           (newEnvironment (append (map cons (map car (cadr e)) valueList) env)))
         (s6-interpret (caddr e) newEnvironment)
       )
      )
      ((letstar? e)
       (if (eq? (length (cadr e)) 0)
           (s6-interpret (list 'let '() (caddr e)) env)
           (if (eq? (length (cadr e)) 1)
               (s6-interpret (list 'let (cadr e) (caddr e)) env)
               (let* ((valueList (s6-interpret (car (cdaadr e)) env))
                      (newEnvironment (cons (cons (caaadr e) valueList) env)))
                 (s6-interpret (list 'let* (cdadr e) (caddr e)) newEnvironment)
               )
           )
       )
      )
      ((operator? e)
       (let ((operands (map s6-interpret (cdr e) (make-list (length (cdr e)) env)))
             (operator (get-operator (car e))))
        (if (operandControl operands)
        (apply operator operands)
        "ERROR"
    )

       )
      )
      (else "ERROR")
    )
  )
)

(define cs305
  (lambda ()
    (repl '())
  )
)



 













