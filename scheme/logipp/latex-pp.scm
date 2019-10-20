(define-module (logipp latex-pp)
  #:use-module (ice-9 match)  ; Pattern matching
  #:use-module (srfi srfi-43) ; Vectors
  #:use-module ((logipp extras) #:prefix extras:)
  #:export (pp))

;; Load additionaly bound symbols
; FIXME the alist should be in a separate file, provided by the user
(define sttfa '(("sttfa:sttfa/etap.cst" . "η")))
(define bindings (extras:alist->hash-str-table sttfa))

;; Pretty prints json ppterm to LaTeX strings. All 'pp*' function return
;; strings, the main function prints the string gathered to stdout.

(define (normalise-object obj)
  "Put a scheme alist coming from a json object in normal form (that is, sort
first lexicographically)."
  (let ((sp-less ; Comparison on string pairs
         (lambda (p q)
           (string<? (car p) (car q)))))
    (sort obj sp-less)))

(define (pp-args ts)
  "Prints ts as a list of arguments."
  (let* ((space-pp
          (lambda (_ t)
            (string-concatenate/shared `("\\ " ,(pp t)))))
         (spaced (vector-map space-pp ts)))
    (string-concatenate/shared (vector->list spaced))))

(define (pp-annot annot)
  "Prints annot as an annotation, that is ': annot'."
  (match annot
    (#nil "")
    (t (string-concatenate/shared `(": " ,(pp t))))))

(define (pp-const const)
  "Prints constant ct with symbol c as '(c args)'"
  (match (normalise-object const)
    ((( "c_args" . #() ) ( "c_symb" . csym ))
     (extras:ref-or-id bindings csym))
    ((( "c_args" . cargs ) ( "c_symb" . csym ))
     (string-concatenate/shared `("\\left(" ,csym ,(pp-args cargs) "\\right)")))))

(define (pp-var var)
  "Prints variable v of symbol v as '(v args)'"
  (match (normalise-object var)
    ((( "v_args" . #() ) ( "v_symb" . vsym ))
     vsym)
    ((( "v_args" . vargs ) ( "v_symb" . vsym ))
     (string-concatenate/shared
      `("\\left(" ,vsym ,(pp-args vargs) "\\right)")))))

(define (pp-binder binder)
  "Given a binder with symbol B, bound variable x and body t, prints 'B x.t'"
  (match (normalise-object binder)
    ((( "annotation" . anno )
      ( "b_args" . #() )
      ( "b_symb" . symb )
      ( "body" . t )
      ( "bound" . bound ))
     (string-concatenate/shared
      `("\\left(" ,symb " " ,bound ,(pp-annot anno) ", "
        ,(pp t) "\\right)")))
    ((( "annotation" . anno )
      ( "b_args" . args )
      ( "b_symb" . symb )
      ( "bound" . bound )
      ( "body" . t ))
     (string-concatenate/shared
      `("\\left(\\left(" ,symb " " ,bound ,(pp-annot anno) ", "
        ,(pp t) "\\right)" ,(pp-args args) "\\right)")))))

;;
;; Public procedure
;;

(define (pp ppt)
  "Converts a Scheme representation of a json ppterm to a string."
  (match ppt
    (#("Const" content)
     (pp-const content))
    (#("Binder" content)
     (pp-binder content))
    (#("Var" content)
     (pp-var content))
    (_ (throw 'ill-json))))