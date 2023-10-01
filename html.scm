(define (join-with-space l) (apply string-append (intersperse l " ")))

;; (join-attributes '((class "flex flex-col") (id "foo")))
(define (join-attributes attributes)
  (join-with-space
    (map 
      (lambda (v) 
	(string-append 
	  (symbol->string (car v))  "=\"" 
	  (join-with-space 
	    (map (lambda (v) 
		   (if (symbol? v) (symbol->string v) v)) (cdr v)))  "\"")) 
      attributes)))

;; (->css '((body (background-color "#efe") (color "black"))))
(define (->css items)
  (join-with-space 
    (map (lambda (entry)
	   (string-append 
	     (if (symbol? (car entry)) (symbol->string (car entry)) (car entry)) " {"
	     (join-with-space 
	       (map (lambda (pair)
		      (string-append (symbol->string (car pair)) ": " (cadr pair) ";"))
		    (cdr entry)))
	     "}"))
	 items)))

;; (->html `(html () (h1 () "Hello scheme world!")))
(define (->html node)
  (if (list? node)
    (let ((tag (symbol->string (car node))))
      (string-append 
	"<" tag (if (not (null? (cadr node))) " " "") (join-attributes (cadr node)) ">" 
	(apply 
	  string-append 
	  (intersperse 
	    (map 
	      (lambda (n) 
		(if (list? n)
		  (->html n)
		  n)) (cddr node)) " "))
	"</" tag ">"))
    node))

;; (->html (script "console.log(\"Hello world!\");"))
(define (script content) `(script ((type text/javascript)) ,content))
