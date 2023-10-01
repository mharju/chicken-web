(import scheme http-client intarweb uri-common medea (chicken io) (chicken process-context) srfi-1 srfi-12)

(define (chat-gpt messages)
  ;; Your endpoint URL and any required headers should be here. 
  ;; As of my last training data, OpenAI used "https://api.openai.com/v1/engines/davinci/completions"
  ;; but you need to check the latest endpoint from the official docs.
  (let* ((body `((model . "gpt-4") 
      	   (messages . ,(list->vector messages)) 
      	   (functions . #(((name . "set_scheme") 
      			   (description . "Sets the color scheme with a foreground, background and accent color")
      			   (parameters . ((type . "object")
      					  (description . "set color palette")
      					  (properties . ((foreground . ((type . "string")
      									(description . "the foreground color as HEX RGB")))
      							 (background . ((type . "string")
      									(description . "the foreground color as HEX RGB")))
      							 (accent . ((type . "string")
      								    (description . "the foreground color as HEX RGB")))))))
      			   (required . #("foreground" "background" "accent")))))
      	   (function_call . "auto")
      	   (top_p . 0.5)
      	   (temperature . 0.5)))
         (req (make-request method: 'POST 
      		      uri: (uri-reference "https://api.openai.com/v1/chat/completions")
      		      headers: (headers `((authorization #(,(string-append "Bearer " (get-environment-variable "OPENAI_API_KEY")) raw))
      					  (content-type application/json))))))
    (with-input-from-request
      req 
      (lambda () 
        (write-json body))
      read-json)))

(define (make-message role message)
  `((role . ,role) (content . ,message)))

(define (append-message messages role msg)
  (append messages (list (make-message role msg))))

(define (is-function-call? response)
  (pair? (filter (lambda (v) (and (eq? (car v) 'finish_reason)
      			    (equal? (cdr v) "function_call"))) 
      	   (car (vector->list (cdar (filter (lambda (v) (eq? (car v) 'choices)) response)))))))

(define (get-assistant-message response)
  (cdar (filter (lambda (v) (eq? (car v) 'content)) 
      	  (cdar (filter (lambda (v) (eq? (car v) 'message)) 
      			(car (vector->list (cdar (filter (lambda (v) (eq? (car v) 'choices)) response)))))))))

(define (get-function-call response)
  (cdar (filter (lambda (v) (eq? (car v) 'function_call)) 
      	  (cdar (filter (lambda (v) (eq? (car v) 'message)) 
      			(car (vector->list (cdar (filter (lambda (v) (eq? (car v) 'choices)) response)))))))))

(define *num-requests* 0)
(define *gpt-response* #f)
(define (chat-loop messages)
  (let ((response (chat-gpt messages)))
    (set! *gpt-response* response)
    (set! *num-requests* (+ *num-requests* 1))
    (if (is-function-call? response)
      `(function-call ,(get-function-call response))
      `(message ,(get-assistant-message response)))))
