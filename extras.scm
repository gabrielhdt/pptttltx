;; Some extra functions
(define-module (extras)
  #:export (hash-str-set!
            hash-str-ref
            ref-or-id
            alist->hash-str-table))

(use-modules (ice-9 hash-table)) ; For alist->hashx-table
(use-modules (srfi srfi-1))      ; For assoc

;; String hash table
(define (str-hash str size)
  (remainder (string-hash str) size))
(define (str-assoc key alist)
  (assoc key alist string=?))


(define (hash-str-set! htbl key val)
  (hashx-set! str-hash str-assoc htbl key val))
(define (hash-str-ref htbl key)
  (hashx-ref str-hash str-assoc htbl key))
(define (alist->hash-str-table alist)
  (alist->hashx-table str-hash str-assoc alist))

(define (ref-or-id shtbl csym)
  "Returns the element bound to csym in shtbl, or csym if it is not bound."
  (let ((binding (hash-str-ref shtbl csym)))
    (if binding
        binding
        csym)))
