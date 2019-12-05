(load-act-r-model "ACT-R:petanque_model.lisp")

(defvar *resultat* nil)
(defvar *window* (open-exp-window "Boulodrome"))
(defvar *boules_rouges* nil)
(defvar *cochonnet* nil)
(defvar *boules_bleus* nil)
(defvar *texte* "O")
(defvar *tirer* 0)
(defvar *pointer* 0)

(defun win ()
(setf *resultat* 1) 
)
(defun loose ()
(setf *resultat* 0) 
)
(defun set-pointer ()
(setf *pointer* (+ *pointer* 0.16))
)
(defun set-tirer ()
(setf *tirer* (+ *tirer* 0.16))
)

(defun petanque-experiment ()
  
  (setf *cochonnet* nil) 
  (setf *boules_rouges* nil)
  (setf *boules_bleus* nil)  
  
  (setf *window* (open-exp-window "Boulodrome"))
    
     (creation-terrain) 
    
    (add-act-r-command "grouped-response" 'record-response "Response from model")
    (add-act-r-command "tir-hasard" 'tir-hasard "Tir au hasard")
    (add-act-r-command "win" 'win "gagner")
    (add-act-r-command "loose" 'loose "perdre")
    (add-act-r-command "tirer" 'tirer "Bleu tire")
    (add-act-r-command "set-tirer" 'set-tirer "set-tirer")
    (add-act-r-command "set-pointer" 'set-pointer "set-pointer")


    (init-partie)

    (run-full-time 5)

    (set-buffer-chunk 'goal 'goal (list 'goal 'state 'start))
    
    (remove-act-r-command "grouped-response")
    (remove-act-r-command "tir-hasard")
    (remove-act-r-command "win")
    (remove-act-r-command "loose")
    (remove-act-r-command "tirer")
    (remove-act-r-command "set-tirer")
    (remove-act-r-command "set-pointer")
    
    *resultat*)

(defun petanque-trial(n)
(let((resTot 0) (res 0))
(dotimes (i n)
(setf res (petanque-experiment))
(setf resTot (+ resTot res))
)
(setf resTot (list resTot))
resTot
)
)

(defun petanque-blocks (blocks block-size) 
  (let (res)    
    (dotimes (i blocks)
      (push (petanque-trial block-size) res))
    (reverse res)))


(defun creation-terrain ()
  (clear-exp-window)
  (install-device *window*)
   (dolist (l *cochonnet*)
	(add-text-to-exp-window *window* "O" :x (car l) :y (car (cdr l)) :color "black")
   )
   (dolist (l *boules_rouges*)
	(add-text-to-exp-window *window* "O" :x (car l) :y (car (cdr l)) :color "red")
   )
   (dolist (l *boules_bleus*)
	(add-text-to-exp-window *window* "O" :x (car l) :y (car (cdr l)) :color "blue")
   )
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
  (let ((rdn (random 2)))
  (if (= rdn 0)
     (progn (princ *boules_rouges*	)
     (push(pop *boules_rouges*)*boules_bleus*	)
     (princ *boules_bleus*	)
     (creation-terrain) 
  ))
(if (= rdn 1)
 (tir-hasard 50 50 "blue")
)))

(defun init-partie ()
(let ((joueur (random 2)) (xn (+(random 150) 50)) (yn (+(random 150) 50)))
(add-text-to-exp-window *window* *texte* :x xn :y yn :color "black")
(ajoute-boule 125 100 "black")
(if (= joueur 1)
(mod-chunk-fct 'goal (list 'state 'start 'ouvreur 'red))
(mod-chunk-fct 'goal (list 'state 'start 'ouvreur 'blue))
)
)
)

(defun petanque-learning (n &optional (graph t))
  (let ((data nil))
    (dotimes (i n)
      (reset)
      (if (null data)
          (setf data (petanque-blocks 20 5))
        (setf data (mapcar (lambda (x y) 
                             (mapcar '+ x y)) 
                     data (petanque-blocks 20 5)))))
    
    (let ((percentages (mapcar (lambda (x) (/ (car x) n 5.0)) data)))
      (when graph
        (draw-graph percentages))
      
      (list (list (/ (apply '+ (subseq percentages 0 5)) 5)
                  (/ (apply '+ (subseq percentages 5 10)) 5)
                  (/ (apply '+ (subseq percentages 10 15)) 5)
                  (/ (apply '+ (subseq percentages 15 20)) 5))
                  percentages)))

(format t "~%Pourcentage Pointer Tirer")
(list (/ (/ *pointer* 20) 5)  (/ (/ *tirer* 20) 5) )
)


(defun draw-graph (points)
  (let ((w (open-exp-window "Data" :visible t :width 550 :height 460)))
    (add-line-to-exp-window w '(50 0) '(50 420) 'white)
    (dotimes (i 11)
      (add-text-to-exp-window w (format nil "~3,1f" (- 1 (* i .1))) 
                              :x 5 :y (+ 5 (* i 40)) :width 35)
      (add-line-to-exp-window w (list 45 (+ 10 (* i 40))) 
                              (list 550 (+ 10 (* i 40))) 'white))
    
    (let ((x 50))
      (mapcar (lambda (a b) 
                (add-line-to-exp-window w (list x (floor (- 410 (* a 400))))
                                        (list (incf x 25) (floor (- 410 (* b 400))))
                                        'blue))
        (butlast points) (cdr points)))))


