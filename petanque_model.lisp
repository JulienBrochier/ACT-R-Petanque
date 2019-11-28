(clear-all)

(define-model petanque
(sgp :seed (123456 0))
(sgp :v t :esc t :lf 0.4 :bll 0.5 :ans 0.5 :rt 0 :ncnar nil :trace-detail high)

(sgp :show-focus t)
(chunk-type partie xn yn db1 db2 db3 dr1 dr2 dr3 dpp)
(chunk-type tirer force inclinaison direction)
(chunk-type terrain type)
(chunk-type goal state typeTerrain ouvreur nbB nbR xn yn dist dpp couleur bqp)

;dpp : distance plus proche
;bqp : boule qui prend (couleur)

(add-dm
 (start isa chunk) (trouverCochonnet isa chunk) (encodeCochonnet isa chunk)
 (trouverBoule isa chunk) (encodeBoule isa chunk) (saveBoule isa chunk)
 (retrieving isa chunk) (detBPP isa chunk) (remember isa chunk)
 (first-goal isa goal state start typeTerrain 1 ouvreur blue) (plot isa chunk))

(P debuterManche
   =goal>
      ISA         goal
      state       start
;;      typeTerrain =type
   ?imaginal>
	state free
 ==>
   !output! ("START")
   =goal>
      ISA         goal
      state   trouverCochonnet
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
   ?imaginal>
      state       free
 ==>
   !output! ("Encode le cochonnet")
   =goal>
      state       trouverBoule
	xn =coordX
	yn =coordY
   !output! (=coordX)
   !output! (=coordY)
   +imaginal>
	isa partie   
	xn =coordX
	yn =coordY
	dpp 5000
	db1 0
	db2 0
	db3 0
	dr1 0
	dr2 0
	dr3 0
)

(P findBoule
   =goal>
      ISA         goal
      state       trouverBoule
 ==>
   !output! ("find Boule")
   +visual-location>
      :attended    new
   =goal>    
      state       encodeBoule
)

(P encodeBoule
   =goal>
      ISA         goal
      state       encodeBoule
   =visual-location>
     screen-x     =coordX
     screen-y  	  =coordY
     color        =couleur
  =imaginal>
	xn =xn
	yn =yn
 ==>
   !output! ("Encode boule")
   !bind! =dist (sqrt (+ (* (- =coordX =xn) (- =coordX =xn)) (* (- =coordY =yn) (- =coordY =yn))) )
   =goal>
      state   saveBoule
	dist  =dist
	couleur =couleur
   =imaginal>
  !output! (=dist)
  !output! (=couleur)
)

(P saveBouleBleu1
   =goal>
	state saveBoule
	couleur blue
	nbB 0
        dist =dist
   ?imaginal>
        state       free
   =imaginal>
 ==>
    =imaginal>
	db1 =dist
    =goal>
	nbB 1
	state detBPP
)

(P saveBouleBleu2
   =goal>
	state saveBoule
	couleur blue
	nbB 1
        dist =dist
   ?imaginal>
        state       free
   =imaginal>
 ==>
    =imaginal>
	db2 =dist
    =goal>
	nbB 1
	state detBPP
)

(P saveBouleBleu3
   =goal>
	state saveBoule
	couleur blue
	nbB 1
        dist =dist
   ?imaginal>
        state       free
   =imaginal>
 ==>
    =imaginal>
	db3 =dist
    =goal>
	nbB 1
	state detBPP
)

(P saveBouleRouge1
   =goal>
	state saveBoule
	couleur red
	nbR 0
        dist =dist
   ?imaginal>
        state       free
   =imaginal>
 ==>
    =imaginal>
	dr1 =dist
    =goal>
	nbR 1
	state detBPP
)

(P saveBouleRouge2
   =goal>
	state saveBoule
	couleur red
	nbR 1
        dist =dist
   ?imaginal>
        state       free
   =imaginal>
 ==>
    =imaginal>
	dr2 =dist
    =goal>
	nbR 1
	state detBPP
)

(P saveBouleRouge3
   =goal>
	state saveBoule
	couleur red
	nbR 1
        dist =dist
   ?imaginal>
        state       free
   =imaginal>
 ==>
    =imaginal>
	dr3 =dist
    =goal>
	nbR 1
	state detBPP
)

(P determinerBoulePlusProche
    =goal>
	state detBPP
	dist =dist
	dpp  =dpp
      < dist =dpp
	couleur =couleur
 ==>
   =goal>
	state trouverBoule
	dpp =dist
	bqp =couleur
)

(P determineBleuProche
   =goal>
	state encodeBoule
	bqp red
      < nbB 4
   ?visual-location>
       buffer  failure	
 ==>
   =goal>
	state remember
)

(P determineRougeProche
   =goal>
	state encodeBoule
	bqp blue
      < nbR 4
	xn =xn
	yn =yn
   ?visual-location>
       buffer  failure	
 ==>
   !eval! (tir-hasard =xn =yn "red")
   =goal>
	state trouverBoule
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
   -retrieval>
;; Il faudra définir une similitude pour avoir une chance que ça match
)

(P cantRemember
    =goal>
       state retrieving
	xn =xn
	yn =yn
     ?retrieval>
       buffer  empty
 ==>
    !output! (Tir au hasard)
    !eval!   (tir-hasard =xn =yn "blue")
     -goal>
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
)

(goal-focus first-goal)
)