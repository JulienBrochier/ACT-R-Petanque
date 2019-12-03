(load-act-r-model "ACT-R:petanque_model.lisp")

(defvar *response* nil)
(defvar *window* (open-exp-window "Boulodrome"))
(defvar *boules_rouges* nil)
(defvar *cochonnet* nil)
(defvar *boules_bleus* nil)

(defun petanque-experiment ()
  
  (reset)
  (setf *cochonnet* nil) 
  (setf *boules_rouges* nil)
  (setf *boules_bleus* nil)  
  
  (setf *window* (open-exp-window "Boulodrome"))
  (install-device *window*)
    
;;    (add-text-to-exp-window *window* "O" :x 170 :y 150 :color "blue")
     (add-text-to-exp-window *window* "O" :x 170 :y 150 :color "red")
     (ajoute-boule 125 150 "black")
     (ajoute-boule 125 100 "red")
     (creation-terrain) 
    
    (add-act-r-command "grouped-response" 'record-response "Response from model")
    (add-act-r-command "tir-hasard" 'tir-hasard "Tir au hasard")
    (add-act-r-command "tirer" 'tirer "Bleu tire")

    (setf *response* nil) 

    (run 20)
    
    (remove-act-r-command "grouped-response")
    (remove-act-r-command "tir-hasard")
    (remove-act-r-command "tirer")
    
    *response*)

(defun record-response (value)
  (push value *response*))

(defun creation-terrain ()
  (clear-exp-window)
   (dolist (l *cochonnet*)
	(add-text-to-exp-window *window* "O" :x (car l) :y (car (cdr l)) :color "black")
   )
   (dolist (l *boules_rouges*)
	(add-text-to-exp-window *window* "O" :x (car l) :y (car (cdr l)) :color "red")
   )
   (dolist (l *boules_bleus*)
	(add-text-to-exp-window *window* "O" :x (car l) :y (car (cdr l)) :color "blue")
   )
  ;;(proc-display nil)
)

(defun ajoute-boule (x y color)
  (if (string= color "red")
     (push (list x y) *boules_rouges*	))
  (if (string= color "blue")
     (push (list x y) *boules_bleus*	))
  (if (string= color "black")
     (push (list x y) *cochonnet*))  
)

(defun tir-hasard (xn yn color)
  (ajoute-boule (+ (- xn 305)(- (random 200) 100)) (+ (- yn 306)(- (random 200) 100)) color)
  (creation-terrain)
  ;;(princ (+ xn (- (random 20) 10)))
)

(defun tirer ()
  ;;(remove-items-from-exp-window *last_red_shoot*)
  (add-text-to-exp-window *window* "O" :x 100 :y 100 :color "blue")
)
