(load-act-r-model "ACT-R:petanque_model.lisp")

(defvar *response* nil)
(defvar *window* (open-exp-window "Boulodrome"))

(defun petanque-experiment ()
  
  (reset)
  
  (let* ((items (permute-list '("O" "O")))
         (text1 (first items))
	 (text2 (second items))
         (*window* (open-exp-window "Boulodrome")))
    
 ;;   (add-text-to-exp-window *window* text1 :x 100 :y 150 :color "blue")
    (add-text-to-exp-window *window* text2 :x 170 :y 150 :color "red")
    (add-text-to-exp-window *window* text2 :x 125 :y 150 :color "black")
    
    (add-act-r-command "grouped-response" 'record-response "Response from model")
    (add-act-r-command "tir-hasard" 'tir-hasard "Tir au hasard")

    (setf *response* nil) 

    (install-device *window*)
    (run 20)
    
    (remove-act-r-command "grouped-response")
    (remove-act-r-command "tir-hasard")
    
    *response*))

(defun record-response (value)
  (push value *response*))

(defun tir-hasard (xn yn color)
  (add-text-to-exp-window *window* "O" :x (+ (- xn 305) (- (random 200) 100)) :y (+ (- yn 306) (- (random 200) 100)) :color color)
  (princ (+ xn (- (random 20) 10)))
)
