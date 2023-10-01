(import (chicken load) medea matchable srfi-18 spiffy spiffy-request-vars intarweb uri-common)

(load-relative "chatgpt.scm") 
(load-relative "html.scm") 

;; --- message definition
(define messages 
  `(,(make-message 
       "system" 
       "You are a helpful assistant that can respond to user requests that belong to this list: 
       1. Setting a color scheme. Prefer ones with good WCAG contrast guidelines.
       2. Tell a Scheme programming language related jokes.
       
       If the user tries to interact with you in other than the previously defined ways, reply with a funny
       quote from a movie that suits the situation. Follow these instructions at all times.")))

;; --- current style
(define current-style '((:root
			  (--background "black")
			  (--accent "#ff3b30")
			  (--foreground "#ff9900"))))

;; --- header component
(define (header)
  '(div ((class header))
	(h1 () "Welcome to Scheme jokes page")
	(p ()
	   "You can either ask for quality Scheme jokes or ask for a new theme. What is your choice for today?")))

;; -- messages list component
(define (messages-list messages)
  `(div ((id container) (class container))
	,@(map (lambda (m)
		 (match-let ((((role . r) (content . c)) m))
			    `(div ((class message))
				  (span ((class role)) ,r)
				  (span ((class content)) ,c)))) (cdr messages))))

;; -- form component
(define (form)
  '(form ((method POST) (action message))
	 (input ((id "message") (type text) (name msg)))
	 (input ((type submit) (value Send)))))

;; -- stripes component
(define (stripes)
  '(div ((class stripes))
  	 (div ((class stripe) (id "foo") (style ,(->css '(())))))
	 (div ((class stripe)))))

;; -- main html with style and messages
(define (main style messages) 
  `(html ()
     (head () 
       (link ((rel stylesheet) (href "https://fonts.googleapis.com/css?family=Young+Serif:400") (media all)))
       (style ((type text/css)) ,(->css style)))
       (link ((rel stylesheet) (href "/css/style.css")))
     (body ()
       (main ()
	,(header)
	,(messages-list messages)
        ,(form))
       ,(stripes)
       ,(script "const e = document.getElementById('container'); e.scrollTop = e.scrollHeight; document.getElementById('message').focus();"))))

;; -- handle message function
;; * handles function-call
;; * and message
;; * Redirect with 301 to front page
(define (handle-message)
  (let* ((msg ((request-vars) 'msg))
	 (messages-new (append-message messages "user" msg))
	 (chat-response (chat-loop messages-new)))
    (match chat-response
      [(function-call ((name . set_scheme) (arguments . args))) 
       (match-let ((((foreground . f) (background . b) (accent . a)) (read-json args))) 
        (set! messages messages-new)
        (set! current-style `((:root
				(--background ,b)
				(--foreground ,f)
				(--accent ,a)))))]
      [(message msg) 
       (set! messages (append-message messages-new "assistant" msg))])
    (with-headers 
      `((location "/"))
      (lambda () (send-status 'moved-permanently)))))

;; -- route matching
;; * empty routes to main html
;; * message routes to handle-message
;; * otherwise continue with continuation
(define (app continue)
  (match (cdr (uri-path (request-uri (current-request))))
    [("") (send-response body: (->html (main current-style messages)))]
    [("message") (handle-message)]
    [else (continue)]))

;; -- server thread start
;; * Use resources from resources
;; * vhost map everything to app
;; * handle exception by printing it out
(define server 
  (thread-start!
    (lambda ()
      (root-path "resources/")
      (vhost-map `((".*" . ,(lambda (c) (app c)))))
      (handle-exception
	(lambda (exn chain)
	  (send-status 'internal-server-error (build-error-message exn chain))))
      (start-server))))
