(clear-all)

(define-model petanque
(sgp :seed (123456 0))
(sgp :v t :esc t :lf 0.4 :bll 0.5 :egs 3 :ans 0.2 :rt 0 :ul t :ncnar nil :trace-detail high :visual-finst-span 5 :visual-num-finsts 7
)

(sgp :show-focus t)
(chunk-type tirer force inclinaison direction)
(chunk-type terrain type)
(chunk-type goal state typeTerrain ouvreur nbB nbR xn yn dist db1 db2 db3 dr1 dr2 dr3 dpp xpp ypp couleur bqp waiting dernier_coup dpp_boule_rouge)
(chunk-type combinaison coup dpp)

;dpp : distance plus proche
;bqp : boule qui prend (couleur)

(add-dm
 (start isa chunk) (trouverCochonnet isa chunk) (encodeCochonnet isa chunk) (save-result isa chunk)
 (trouverBoule isa chunk) (attendBoule isa chunk)(encodeBoule isa chunk) (saveBoule isa chunk)
 (retrieving isa chunk) (detBPP isa chunk) (remember isa chunk) (wait isa chunk)(done isa chunk)
 (go isa chunk)(plot isa chunk)(pointer isa chunk) (tirer isa chunk)(first isa chunk))

(define-chunks
(goal isa goal)
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
  dernier_coup first
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
;; Pour le remplacement:
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
  dpp =dpp
      < nbB 3
	waiting go
   ?visual-location>
       buffer  failure
 ==>
   =goal>
	state remember
  dpp_boule_rouge =dpp
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

(P determineRougeCommence
   =goal>
   dpp =dpp
	state attendBoule
	bqp blue
      = nbR 0
	xn =xn
	yn =yn
	waiting go
   ?visual-location>
       buffer  failure
 ==>
 ;; Le coup precedent est gagnant
   !eval! (tir-hasard =xn =yn "red")
   =goal>
   state trouverBoule
	 waiting wait
)

(P determineRougeJoue1
   =goal>
   dpp =dpp
	state attendBoule
	bqp blue
      < nbR 3
	xn =xn
	yn =yn
	waiting go
  dernier_coup =dernier_coup
  dpp_boule_rouge =dpp_boule_rouge
   ?visual-location>
       buffer  failure
  ?imaginal>
      state free
 ==>
 ;; Le coup precedent est gagnant
   !bind! =distance_round (round (/ =dpp_boule_rouge 30))
   !eval! (tir-hasard =xn =yn "red")
   !output! (=distance_round)
   =goal>
	state save-result
	waiting wait
  +imaginal>
  isa combinaison
  ;; dpp =dpp_boule_rouge
  dpp =distance_round
  coup =dernier_coup
)

(P save-result
 =imaginal>
 =goal>
  state save-result
==>
=goal>
  state trouverBoule
  waiting wait
-imaginal>
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
  dernier_coup =coup
 ==>
 !bind! =distance_round (round (/ =dpp 30))
   =goal>
       state retrieving
   +retrieval>
	isa combinaison
	dpp =distance_round
  coup =coup
;; Il faudra d�finir une similitude pour avoir une chance que �a match
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
    !output! (Tirer au hasard)
   !eval! (set-tirer )
   !eval! (tirer )
   =goal>
	waiting wait
	state trouverBoule
  dernier_coup tirer
)

(P cantRemember-pointer
    =goal>
       state retrieving
	xn =xn
	yn =yn
     ?retrieval>
       buffer  failure
 ==>
    !output! (pointer au hasard)
    !eval!   (tir-hasard =xn =yn "blue")
    !eval!   (set-pointer)
    =goal>
	waiting wait
	state trouverBoule
  dernier_coup pointer
)

(P canRemembertirer
    =goal>
       state retrieving
       xn =xn
       yn =yn
   =retrieval>
	     isa combinaison
	     dpp =dpp
       coup tirer
 ==>
   !output! (Remember)
   !output! (Tir au hasard)
   !eval! (set-tirer)
   !eval! (tirer )
   =goal>
   waiting wait
   state trouverBoule
   dernier_coup tirer
 )

(P canRememberpointer
    =goal>
       state retrieving
       xn =xn
       yn =yn
   =retrieval>
	  isa combinaison
	   dpp =dpp
     coup pointer
 ==>
   !output! (Remember)
   !output! (Tir au hasard)
   !eval!   (tir-hasard =xn =yn "blue")
   !eval!   (set-pointer);;executer le tir pr�vu
   =goal>
   waiting wait
   state trouverBoule
   dernier_coup pointer
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

(P gagner
   =goal>
	state attendBoule
	nbB 3
        nbR 3
        bqp blue
   ?visual-location>
       buffer  failure
 ==>
   !eval! (win)
   !output! (Le modele gagne)
  =goal>
   state done
)
(P perdre
   =goal>
	state attendBoule
	nbB 3
        nbR 3
        bqp red
   ?visual-location>
       buffer  failure
 ==>
   !eval! (loose)
   !output! (Le modele perd)
  =goal>
   state done
)

(goal-focus goal)

(spp perdre :reward -5)
(spp gagner :reward 10)

)
