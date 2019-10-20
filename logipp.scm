#!/usr/bin/guile \
-e main -s
!#

;; Entry point, parses stdin, command line and call pretty printer
(use-modules (ice-9 getopt-long))
(use-modules (json))

(add-to-load-path (dirname (current-filename)))
(use-modules ((to_latex) #:prefix ltx:))

(define version "0.0")

(define (help progname)
  (format #t "\
Usage: ~a [options]
  -V, --version    Display version
  -h, --help       Display this help
"
          progname))

(define option-spec
  '((version (single-char #\V) (value #f))
    (help    (single-char #\h) (value #f))))

(define (main args)
  (let* ((options (getopt-long args option-spec))
         (help-wanted (option-ref options 'help #f))
         (version-wanted (option-ref options 'version #f)))
    (if (or help-wanted version-wanted)
        (begin
          (if version-wanted
              (format #t "~a\n" version))
          (if help-wanted
              (help (car args))))
        (let* ((jsppt (json->scm))
               (ppstr (ltx:pp jsppt)))
          (display ppstr)))))
