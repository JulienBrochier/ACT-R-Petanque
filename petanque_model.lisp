(clear-all)

(define-model petanque
(sgp :seed (123456 0))
(sgp :v t :esc t :lf 0.4 :bll 0.5 :egs 3 :ans 0.5 :rt 0 :ncnar nil :trace-detail high :visual-finst-span 5 :visual-num-finsts 8
)

(sgp :show-focus t)
(chunk-type partie xn yn db1 db2 db3 dr1 dr2 dr3 dpp)
(chunk-type tirer force inclinaison direction)
(chunk-type terrain type)
(chunk-type goal state typeTerrain ouvreur nbB nbR xn yn dist db1 db2 db3 dr1 dr2 dr3 dpp xpp ypp couleur bqp waiting)

;dpp : distance plus proche
;bqp : boule qui prend (couleur)

(add-dm
 (start isa chunk) (trouverCochonnet isa chunk) (encodeCochonnet isa chunk)
 (trouverBoule isa chunk) (attendBoule isa chunk)(encodeBoule isa chunk) (saveBoule isa chunk)
 (retrieving isa chunk) (detBPP isa chunk) (remember isa chunk) (wait isa chunk)
 (go isa chunk)(plot isa chunk))

(define-chunks
(first-goal isa goal)
)


(P debuterManche
   =goal>
      ISA         goal
      state       start
      ouvreur =ouvreur
;;      typeTerrain =type
 ==>
   !output! ("START")
   =goal>
      ISA         goal
      state   trouverCochonnet
       bqp =ouvreur
)

(P findCochonnet
   =goal>
      ISA         goal
      state       trouverCochonnet
 ==>
   !output! ("find Cochonnet")
   +visual-location>
      :attended    nil
      color black
   =goal>    
      state       encodeCochonnet
      nbB 0
      nbR 0
)

(P encodeCochonnet
   =goal>
      ISA         goal
      state       encodeCochonnet
   =visual-location>
     screen-x     =coordX
     screen-y  	  =coordY
 ==>
   !output! ("Encode le cochonnet")
   =goal>
      state       trouverBoule
	xn =coordX
	yn =coordY
	dpp 5000
	db1 0
	db2 0
	db3 0
	dr1 0
	dr2 0
	dr3 0
   !output! (=coordX)
   !output! (=coordY)
)

(P findBoule
   =goal>
      ISA         goal
      state       trouverBoule
 ==>
   +visual-location>
      :attended    nil
    - color black
   =goal>    
      state       attendBoule
      waiting go
)

(P attend-boule
   =goal>
      state       attendBoule
   =visual-location>
   ?visual>
      state       free
==>
   +visual>
      cmd         move-attention
      screen-pos  =visual-location
   =goal>
      state       encodeBoule
   =visual-location>
)

(P encodeBoule
   =goal>
      ISA         goal
      state       encodeBoule
	xn =xn
	yn =yn
   =visual-location>
     screen-x     =coordX
     screen-y  	  =coordY
     color        =couleur
 ==>
   !output! ("Encode boule")
   !bind! =dist (sqrt (+ (* (- =coordX =xn) (- =coordX =xn)) (* (- =coordY =yn) (- =coordY =yn))) )
   =goal>
      state   saveBoule
	dist  =dist
	couleur =couleur
  !output! (=dist)
  !output! (=couleur)
)

(P saveBouleBleu1
   =goal>
	state saveBoule
	couleur blue
	nbB 0
        dist =dist
 ==>
    =goal>
	db1 =dist
	nbB 1
	state detBPP
)

(P saveBouleBleu2
   =goal>
	state saveBoule
	couleur blue
	nbB 1
        dist =dist
 ==>
    =goal>
	db2 =dist
	nbB 2
	state detBPP
)

(P saveBouleBleu3
   =goal>
	state saveBoule
	couleur blue
	nbB 2
        dist =dist
 ==>
    =goal>
	db3 =dist
	nbB 3
	state detBPP
)

(P saveBouleRouge1
   =goal>
	state saveBoule
	couleur red
	nbR 0
        dist =dist
 ==>
    =goal>
	dr1 =dist
	nbR 1
	state detBPP
)

(P saveBouleRouge2
   =goal>
	state saveBoule
	couleur red
	nbR 1
        dist =dist
 ==>
    =goal>
	dr2 =dist
	nbR 2
	state detBPP
)

(P saveBouleRouge3
   =goal>
	state saveBoule
	couleur red
	nbR 2
        dist =dist
 ==>
    =goal>
	dr3 =dist
	nbR 3
	state detBPP
)

(P determinerBoulePlusProcheVrai
    =goal>
	state detBPP
	dist =dist
	dpp =dpp
      < dist =dpp
	couleur =couleur
 ==>
   =goal>
	state trouverBoule
	dpp =dist
	bqp =couleur
)

(P determinerBoulePlusProcheVrai2
    =goal>
	state detBPP
	dist =dist
	dpp =dpp
        dist =dpp
	couleur =couleur
 ==>
   =goal>
	state trouverBoule
	dpp =dist
	bqp =couleur
)

(P determinerBoulePlusProcheFaux
    =goal>
	state detBPP
	dist =dist
	dpp =dpp
     > dist =dpp
	couleur =couleur
 ==>
   =goal>
	state trouverBoule
)

(P determineBleuJoue1
   =goal>
	state attendBoule
	bqp red
      < nbB 3
	waiting go
   ?visual-location>
       buffer  failure
 ==>
   =goal>
	state remember
)

(P determineBleuJoue2
   =goal>
	state attendBoule
	bqp blue
      < nbB 3
        nbR 3
	waiting go
   ?visual-location>
       buffer  failure
 ==>
   =goal>
	state remember
)

(P determineRougeJoue1
   =goal>
	state attendBoule
	bqp blue
      < nbR 3
	xn =xn
	yn =yn
	waiting go
   ?visual-location>
       buffer  failure
 ==>
   !eval! (tir-hasard =xn =yn "red")
   =goal>
	state trouverBoule
	waiting wait
)

(P determineRougeJoue2
   =goal>
	state attendBoule
	bqp red
      < nbR 3
	nbB 3
	xn =xn
	yn =yn
	waiting go
   ?visual-location>
       buffer  failure
 ==>
   !output! (Rouge tir)
   !eval! (tir-hasard =xn =yn "red")
   =goal>
	state trouverBoule
	waiting wait
)

;;
;;determiner bleu et rouge out
;;

(P searchInMemory
   =goal>
	state       remember
	xn =xn
	yn =yn
	dpp =dpp
 ==>
   =goal>
       state retrieving
   +retrieval>
	isa partie
	xn =xn
	yn =yn
	dpp =dpp
;; Il faudra définir une similitude pour avoir une chance que ça match
)



(P cantRemember-tirer
    =goal>
       state retrieving
	xn =xn
	yn =yn
      > nbR 0 
     ?retrieval>
       buffer  failure
 ==>
    !output! (Tir au hasard)
    !eval! (tirer )
   =goal>
	waiting wait   
	state trouverBoule
)

(P cantRemember-pointer
    =goal>
       state retrieving
	xn =xn
	yn =yn
     ?retrieval>
       buffer  failure
 ==>
    !output! (Tir au hasard)
    !eval!   (tir-hasard =xn =yn "blue")
    =goal>
	waiting wait   
	state trouverBoule
)


(P wait
   =goal>
        waiting wait
	state encodeBoule
   ?visual-location>
       buffer  failure	
 ==>
   !output! (WaiT)
   =goal>
	state trouverBoule
)

(P canRemember
    =goal>
       state retrieving
   =retrieval>
	isa partie
	xn =xn
	yn =yn
	dpp =dpp
 ==>
   -goal>
   !output! (Remember)
;;executer le tir prévu
;;   =goal>
;;	waiting wait   
;;	state trouverBoule
)


(goal-focus first-goal)
)