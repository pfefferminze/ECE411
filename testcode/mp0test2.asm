origin 4x0000
Segment CodeSegment:
LDR R1, R0, var1	;r1<=1
LDR R2, R0, var2	;r2<=3
ADD R3, R1, R2		;r3<=1 + 3 = 4
AND R4, R3, R2		;r4<= 4 & 3 = 0
AND R5, R2, R1 		;r5<= 1 & 3 = 1
LOOP:
NOT R7, R7			;r6<=2^16 - 1
brn LOOP
brz MIDDLE
SPAGHETTI:

brnzp ENDIT
MIDDLE:
ADD R7, R2, R2		;r7<=3 + 3 = 6
brp SPAGHETTI
ADD R0, R0, R7
ENDIT:
str R3, R0, var3 
HALT:
brnzp HALT

var1: DATA2 4x0001
var2: DATA2 4x0003
var3: DATA2 4x0000
