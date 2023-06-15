(define main-procedure
    (lambda (tripleList)
    (if (or (null? tripleList) (not (list? tripleList)))
        (error "ERROR305: the input should be a list full of triples")
            (if (check-triple? tripleList)
                (sort-area (filter-pythagorean (filter-triangle
                (sort-all-triples tripleList))))
        (error "ERROR305: the input should be a list full of triples")
        )
    )
)
)


(define check-triple?
  (lambda (tripleList)
    (define is-triple?
      (lambda (lst)
        (and (list? lst)
             (eq? (length lst) 3)
             (number? (car lst))
             (number? (cadr lst))
             (number? (caddr lst)))))
    (define check-list
      (lambda (lst)
        (if (null? lst)
            #t
            (if (not (is-triple? (car lst)))
                #f
                (check-list (cdr lst))
            )
        )
      )
    )
    (check-list tripleList)
    )
)

(define check-length?
    (lambda (inTriple count)
        (if (eq? (length inTriple) count) 
            #t
            #f
        
        )
    )
)

(define check-sides?
  (lambda (inTriple)
    (if (null? inTriple)
        #t
        (if (not (and (number? (car inTriple)) (> (car inTriple) 0)))
            #f
            (check-sides? (cdr inTriple))))))  

(define sort-all-triples
  (lambda (tripleList)
    (if (null? tripleList)
        '()
        (cons (sort-triple (car tripleList)) (sort-all-triples (cdr tripleList)))
    )
  )
)

(define sort-triple
      (lambda (triple)
        (let ((a (car triple))
              (b (cadr triple))
              (c (caddr triple)))
          (cond ((and (<= a b) (<= b c))
                 triple)
                ((and (<= b a) (<= a c))
                 (list b a c))
                ((and (<= c a) (<= a b))
                 (list c a b))
                ((and (<= b c) (<= c a))
                 (list b c a))
                ((and (<= a c) (<= c b))
                 (list a c b))
                ((and (<= c b) (<= b a))
                 (list c b a))
          )
        )
      )
    )

(define triangle?
      (lambda (triple)
        (let ((a (car triple))
              (b (cadr triple))
              (c (caddr triple)))
        ( if (> ( + a b) c)
            (if   (> ( + a c) b)
                (if   (> ( + b c) a)
                #t
                #f
                )
            #f)
        #f
        )
        )
        )
 )
    
(define filter-triangle
  (lambda (tripleList)
    (if (null? tripleList)
        '() 
        (if (triangle? (car tripleList))
            (cons (car tripleList) (filter-triangle (cdr tripleList))) 
            (filter-triangle (cdr tripleList)) 
        )
    )
  )
)

(define pythagorean-triangle?
  (lambda (triple)
    (let ((a (car triple))
          (b (cadr triple))
          (c (caddr triple)))
      (if (eq? (+ (* a a) (* b b)) (* c c))
          #t
          #f
      )
    )
  )
)

    
(define filter-pythagorean
  (lambda (tripleList)
    (if (null? tripleList)
        '() 
        (if (pythagorean-triangle? (car tripleList))
            (cons (car tripleList) (filter-pythagorean (cdr tripleList))) 
            (filter-pythagorean (cdr tripleList)) 
        )
    )
  )
)

(define get-area
  (lambda (triple)
    (let ((a (car triple))
          (b (cadr triple)))
      (/ (* a b) 2)
    )
  )
)

(define insertion
  (lambda (triple sorted-triples)
    (if (null? sorted-triples)
        (list triple)
        (if (< (get-area triple) (get-area (car sorted-triples)))
            (cons triple sorted-triples)
            (cons (car sorted-triples) (insertion triple (cdr sorted-triples)))))))

(define sort-area
  (lambda (tripleList)
    (if (null? tripleList)
        '()
        (insertion (car tripleList) (sort-area (cdr tripleList))))))