
;   Author: Paul Fitzpatrick, paulfitz@csail.mit.edu
;   Copyright (c) 2003 Paul Fitzpatrick
;
;   This file is part of CosmicOS.
;
;   CosmicOS is free software; you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation; either version 2 of the License, or
;   (at your option) any later version.
;
;   CosmicOS is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with CosmicOS; if not, write to the Free Software
;   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load some resources

;; Load look-up table for names of built-in procedures
(load "identifiers")

;; Load entire message as a list-of-lists, to allow programmatic access
(load "primer")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper procedures to deal with differences between CosmicOS lists
;; and Scheme lists.
;; In CosmicOS, lists contain their length as the first element of
;; a CONS structure.

(define fritz-break-list
  (lambda (in)
    (if (> (length in) 0)
	(let ((top (car in))
	      (rem (cdr in)))
	  (if (list? top)
	      (cons (fritz-break-list top) (fritz-break-list rem))
	      (if (= top -1)
		  (list (fritz-break-list rem))
		  (cons top (fritz-break-list rem)))))
	'())))


;; synchonize definition of cons/car/cdr with message
;; so that translator can be modified within message
(define fritz-cons (lambda (x) (lambda (y) (lambda (f) ((f x) y)))))
(define fritz-car (lambda (p) (p (lambda (x) (lambda (y) x)))))
(define fritz-cdr (lambda (p) (p (lambda (x) (lambda (y) y)))))


(define fritzify-list
  (lambda (exp)
    (if (number? exp)
	exp
	((fritz-cons (length exp))
		    (if (> (length exp) 1)
			((fritz-cons (fritzify-list (car exp)))
				    (fritz-cdr (fritzify-list (cdr exp))))
			(if (> (length exp) 0)
			    (fritzify-list (car exp))
			    0))))))

(define defritzify-list
  (lambda (exp)
    (if (number? exp)
	exp
	(let ((n (fritz-car exp)))
	  (if (> n 1)
	      (append (list (defritzify-list (fritz-car (fritz-cdr exp))) )
		      (defritzify-list ((fritz-cons (- n 1))
					(fritz-cdr (fritz-cdr exp)))))
	      (if (> n 0)
		  (list (defritzify-list (fritz-cdr exp)))
		  '()))))))


(define defritzify-list-old
  (lambda (exp)
    (if (number? exp)
	exp
	(fritz-break-list
	 (let ((n (fritz-car exp)))
	   (if (> n 1)
	       (append (list (defritzify-list (fritz-car (fritz-cdr exp))) )
		       (defritzify-list ((fritz-cons (- n 1))
					      (fritz-cdr (fritz-cdr exp)))))
	       (if (> n 0)
		   (list (defritzify-list (fritz-cdr exp)))
		   '())))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper procedures to deal with differences between CosmicOS true/false
;; values and Scheme true/false values.
;; In CosmicOS, true equals integer 1, and false equals integer 0.

;; tish: "truth-ish" -- convert a number to a truth-value
(define tish
  (lambda (x)
    (> x 0)))

;; nish: "number-ish" -- convert a truth-value to a number
(define nish
  (lambda (x)
    (if x 1 0)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Built-in procedures

(define cos-intro
  (lambda (x) (nish #t)))

(define cos-=
  (lambda (x) (lambda (y) 
		(nish
		 (equal? x y)))))

(define cos->
  (lambda (x) (lambda (y) (nish (> x y)))))

(define cos-<
  (lambda (x) (lambda (y) (nish (< x y)))))

(define cos-+
  (lambda (x) (lambda (y) (+ x y))))

(define cos-*
  (lambda (x) (lambda (y) (* x y))))

(define cos--
  (lambda (x) (lambda (y) (- x y))))

(define cos-not
  (lambda (x) (nish (not (tish x)))))

(define cos-demo
  (lambda (x) x))

;(define cos-<=
;  (lambda (x) (lambda (y) (nish (<= x y)))))

;(define cos->=
;  (lambda (x) (lambda (y) (nish (>= x y)))))

;(define cos-and
;  (lambda (x) (lambda (y) (nish (and (tish x) (tish y))))))

;(define cos-or
;  (lambda (x) (lambda (y) (nish (or (tish x) (tish y))))))

;(define cos-if
;  (lambda (x) (lambda (y) (lambda (z) (if (tish x) y z)))))


;(define cos-false
;  (nish #f))

;(define cos-true
;  (nish #t))

;(define cos-cons
;  (lambda (x) (lambda (y) (cons x y))))

;(define cos-car
;  (lambda (x) (car x)))

;(define cos-cdr
;  (lambda (x) (cdr x)))

(define cos-number?
  (lambda (x) (nish (number? x))))

(define cos-translate-old
  (lambda (exp0)
    (let ((exp (defritzify-list exp0)))
      (fritz-translate exp))))

(define cos-translate
  (lambda (exp0)
    (fritz-translate exp0)))

(define cos-make-cell
  (lambda (x)
    (make-cell x)))

(define cos-set!
  (lambda (x)
    (lambda (y)
      (begin (set-cell-contents! x y)
	     (nish #t)))))

(define cos-get!
  (lambda (x)
    (cell-contents x)))

(define cos-div
  (lambda (x) (lambda (y) (quotient x y))))

(define cos-primer
  (fritzify-list (fritz-break-list fritz-primer)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Minor built-in procedures that could be stripped without affecting
;; important parts of the message

(define cos-forall
  (lambda (x)
    (nish (and (tish (x -5)) (tish (x 10)) (tish (x 15)) (tish (x 18)))))) ;; try a few samples - not real code

(define cos-exists
  (lambda (x)
    (nish
     (let loop ((n -10))   ;; try a few samples - not real code
       (if (tish (x n))
	   #t
	   (if (< n 20)
	       (loop (+ n 1))
	       #f))))))

(define cos-all
  (lambda (x)
    (fritzify-list
     (let loop ((n -50))   ;; try a few samples - not real code
       (let ((rest (if (< n 50)
		       (loop (+ n 1))
		       '())))
	 (if (tish (x n))
	     (append (list n) rest)
	     rest))))))

(define cos-natural-set
  (cos-all (lambda (x) (nish (>= x 0)))))

;; should eliminate this
(define cos-undefined
  0)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Place-holders: value should never be checked in practice, and
;; are just assigned here to catch potential bugs

;;; "lambda" gets created in message, value here doesn't matter
(define cos-lambda
  (nish #f))

;; "define" gets intercepted, value here doesn't matter
(define cos-define
  (nish #f))

;; "if" gets intercepted, value here doesn't matter
(define cos-if
  (nish #f))

;; "assign" gets intercepted, value here doesn't matter
(define cos-assign
  (nish #f))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Evaluation

;; Translation needs to work on expressions composed of the same 
;; kind of list as is defined in the message.  Here's what that
;; currently is:

(define fcar
  (lambda (lst)
    (let ((rem (fritz-cdr lst)))
      (if (= (fritz-car lst) 1)
	  rem 
	  (fritz-car rem)))))
  
(define fcdr
  (lambda (lst)
    (let ((len (fritz-car lst)))
      (if (<= len 1)
	  ((fritz-cons 0) 0)
	  ((fritz-cons
	    (- (fritz-car lst) 1))
	   (fritz-cdr (fritz-cdr lst)))))))

(define flength
  (lambda (lst)
    (fritz-car lst)))

;; this is the core "translate" procedure.
;; It converts the FRITZ expression it receives into SCHEME code.
(define fritz-translate
  (lambda (exp)
    (if (not (number? exp))
	(let ((cmd (fcar exp))
	      (rem (fcdr exp)))
	  (cond ((equal? cmd 12)
		 ;; expression evaluates to a procedure
		 (let ((formal (fcar rem))
		       (body (fcar (fcdr rem))))
		   (list 'lambda
			 (list (intern 
				(string-append "cos-" 
					       (fritz-name formal))))
			 (fritz-sub-translate body))))
		;; expression defines a procedure
		((equal? cmd 13)
		 (let ((formal (fcar rem))
		       (body (fcar (fcdr rem))))
		   (list 'begin
			 (list 'define 
			       (intern 
				(string-append "cos-" 
					       (fritz-name formal)))
			       (fritz-sub-translate body))
			 (nish #t))))
		;; assignment shorthand
		((equal? cmd 14)
		 (let ((formal (fcar rem))
		       (value (fcar (fcdr rem)))
		       (body  (fcar (fcdr (fcdr rem)))))
		   (list
		    (list 'lambda
			  (list (intern 
				 (string-append "cos-" 
						(fritz-name formal))))
			  (fritz-sub-translate body))
		    (fritz-sub-translate value))))
		;; expression is an if statement
		((equal? cmd 15)
		 (let ((cnd (fcar rem))
		       (on1 (fcar (fcdr rem)))
		       (on0 (fcar (fcdr (fcdr rem)))))
		   (list 'if
			 (list 'tish (fritz-sub-translate cnd))
			 (fritz-sub-translate on1)
			 (fritz-sub-translate on0))))
		;; expression is a procedure call
		(else (let ((func-id (fritz-sub-translate cmd)))
			(let ((func (if (number? func-id)
					(intern 
					 (string-append "cos-" 
							(fritz-name func-id)))
					func-id)))
			  (if (> (flength rem) 0)
			      (let loop ((n (flength rem))
					 (arg rem)
					 (base func))
				(if (> n 1)
				    (loop (- n 1) (fcdr arg)
					  (list base (fritz-sub-translate (fcar arg))))
				    (list base (fritz-sub-translate (fcar arg)))))
			      func))))))
	exp)))

;; Translate via cos-translate; this is necessary so that
;; cos-translate can be overridden within the body of the method.
(define fritz-sub-translate
  (lambda (exp)
    (cos-translate exp)))


;; Quote an expression - used by "DEMO" machinery
(define fritz-quote
  (lambda (prefix exp)
    (if (number? exp)
	exp
	(append
	 '(16)
	 (map (lambda (x) (fritz-quote prefix x))
	      exp)))))


;; Convert a "demo" expression so that it evaluates to true.
;; First integer in expression is assumed to be demo marker.
;; First integer in expression is assumed to be -1 break marker.
(define fritz-add-result
  (lambda (exp result)
    (if (equal? (car exp) 7)
	(if (equal? (car (cdr exp)) -1)
	    (let ((base-exp (cdr (cdr exp))))
	      (if (number? result)
		  (list 8
			base-exp
			result)
		  (cons 8
			(cons base-exp
			      (cons -1
				    (fritz-quote 16 result))))))))))


;; Execute a single CosmicOS expression
;; Result is expected to be true (integer 1)
(define fritz-translate-show
  (lambda (id exp)
    (begin
      (display "    Expression: ")
      (display exp)
      (display "\n")
      (let ((result (cos-translate (fritzify-list (fritz-break-list exp)))))
	(begin
	  (display "    Translation: ")
	  (display result)
	  (display "\n")
	  (let ((val (eval result user-initial-environment)))
	    (if (equal? (car exp) 7)
		(begin
		  (display "DEMO PATCH: change line ")
		  (display id)
		  (display " from ")
		  (display exp)
		  (display " to ")
		  (display (fritz-add-result exp (defritzify-list val))))
		(if (equal? val 1)
		    (display "ok")
		    (begin
		      (display "UNEXPECTED RESULT: ")
		      (display (defritzify-list val)))))
	    (display "\n")))))))


