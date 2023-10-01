;; Hello Aurajoki Overflow!

(define title "Cluckin' Colors and Comedic Code: AI-Powered Chicken Scheme Fun")
(define presenter "Mikko Harju")
(define company "Taiste")
(define role "CTO")

;; numbers
1
1.2
3+4i
22/7

;; strings
"hello world"

;; binding
(let ((a "value"))
  a)

;; definitions
(define foo (lambda (n) (+ n n)))
(define (foo n) (+ n n))

;; quoting
(quote (1 2 3 4))
'(1 2 3 4)

;; pairs
(cons 1 2)
'(1 . 2)

;; lists
(cons 1 (cons 2 '()))
(list 1 2)

;; key-value pairs
'(("key" . "value") ("key2" . "value2"))

;; joining lists 
(append '(1 2 3) '(4 5 6))

;; quasiquoting
`(1 2 ,(+ 1 2))

;; matching
(import matchable)
(match '("foo" "bar")
 [(a b) (string-append a ", " b)])

;; match-let
(match-let (((a b) '("foo" "bar")))
  (string-append a ", " b))
