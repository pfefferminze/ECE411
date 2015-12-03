;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;Program to Calculate 5!;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;Written by Nick Moore  ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;njmoore3               ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;ECE 411                ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;Fall 2015              ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R6 holds the final 
;R0 holds 0
;R1 holds the initial value and outer loop's counter
;R2 holds the multiplicand
;R3 holds the multiplier
;R4 holds negative one

origin 4x0000
Segment CodeSegment:


;clear all the registers (assuming R0 starts out as 0)
ADD R1, R0, R0
ADD R2, R0, R0
ADD R3, R0, R0
ADD R4, R0, R0
ADD R5, R0, R0
ADD R6, R0, R0
ADD R7, R0, R0

;initialize R4
NOT R4, R0

;take the given value and store it in R1 and R6
LDR R1, R0,FIVE 
ADD R6, R1, R0
;outer loop begins
;
;if R1 is greater than 0
BRnz FINISH

OUTERLOOP:
;copy R6 to be the multiplier (R3)
ADD R3, R6, R0

;clear R6
ADD R6, R0, R0

;subtract 1 from R1 and put it in the multiplicand (R2)
ADD R2, R4, R1

;if the new multiplicand is 0 we are multiplying by 1 in the factorial
;algorithm, so we can finish
BRnz FINISH

;;;;;;;;multiplication loop
;if multiplicand (R2) is greater than 0
MULTIPLY:
;add multiplier (R3) to the final value (R6)
ADD R6, R6, R3

;subtract 1 from multiplicand (R2)
ADD R2, R4, R2

;return back to multiplication loop
BRp MULTIPLY

;MULTIPLY is finished, so go back to outer loop after decrementing 
ADD R1, R1, R4
BRp OUTERLOOP

FINISH:
;store the final value (R6)
ADD R6,R3,R0
STR R6, R0,ANSWER 

;continuously branch back to itself
HALT:
brnzp HALT

FIVE:	DATA2 4x0005
ANSWER:	DATA2 4x0000
