.equ SWI_SETSEG8, 0x200 @display on 8 Segment
.equ SWI_SETLED, 0x201 @LEDs on/off
.equ SWI_CheckBlack, 0x202 @check Black button
.equ SWI_CheckBlue, 0x203 @check press Blue button
.equ SWI_DRAW_STRING, 0x204 @display a string on LCD
.equ SWI_DRAW_INT, 0x205 @display an int on LCD
.equ SWI_CLEAR_DISPLAY,0x206 @clear LCD
.equ SWI_DRAW_CHAR, 0x207 @display a char on LCD
.equ SWI_CLEAR_LINE, 0x208 @clear a line on LCD
.equ SWI_EXIT, 0x11 @terminate program
.equ SWI_GetTicks, 0x6d @get current time
.equ LEFT_LED, 0x02 @bit patterns for LED lights
.equ RIGHT_LED, 0x01
.equ LEFT_BLACK_BUTTON,0x02 @bit patterns for black buttons
.equ RIGHT_BLACK_BUTTON,0x01 @and for blue buttons
.equ SWI_GetTicks, 0x6d @get current time
.equ LEFT_BLACK_BUTTON,0x02 @bit patterns for black buttons
.equ RIGHT_BLACK_BUTTON,0x01 @and for blue buttons
.equ seg_A, 0x80
.equ seg_B, 0x40
.equ seg_C, 0x20
.equ seg_D, 0x08
.equ seg_E, 0x04
.equ seg_F, 0x02
.equ seg_G, 0x01
.equ seg_P, 0x10

start:
	mov r7,#0 @boolean safe locked/unlocked. unlocked:0, locked:1
	mov r6,#0 @number of times right black button has been pressed in this interaction
	ldr r1,=currCode
	ldr r2,=currCode2
	ldr r3,=codes @r3 = head
	ldr r4,=codes @r4 = tail
	add r3,r3,#100
	add r4,r4,#100
	bl clearCurrCode
	bl clearCurrCode2

loop:
	swi SWI_CheckBlack
	cmp r0,#0x02
	beq leftPressed
	cmp r0,#0x01
	beq rightPressed
	swi SWI_CheckBlue
	cmp r0,#0
	bgt bluePressedPreliminary
	b loop
	
bluePressedPreliminary:	@method to determine which bluebutton method to call based on # of right black button presses
	cmp r6,#0
	beq bluePressed
	cmp r6,#1
	beq bluePressed
	cmp r6,#2
	beq bluePressed2
	cmp r6,#3
	bleq displayE
	b loop

leftPressed:
	bl lightLeft
	ldr r1,=currCode
	cmp r7,#0
	beq lockSafe
	cmp r7,#1
	beq unlockSafe
	
lockSafe:
	bl clearCurrCode
	bl clearCurrCode2
	ldrb r9,[r3]
	cmp r9,#0x81
	bleq displayE
	beq loop
	bl displayL
	mov r7,#1
	b loop	
	
unlockSafe:
	bl compareWithAllCodes
	@bl clearCurrCode
	@bl clearCurrCode2
	cmp r9,#1
	bleq displayU
	moveq r7,#0
	cmp r9,#0
	beq displayE
	b loop
	
	
rightPressed:
	bl lightRight
firstPress:
	cmp r7,#1
	beq displayE
	cmp r6,#0
	bleq displayP
	addeq r6,r6,#1
	beq loop
secondPress:
	cmp r6,#1			@starting here,
	bleq checkLength
	cmp r9,#0
	beq displayE
	cmp r6,#1
	bleq checkZero
	cmp r9,#0
	beq displayE
	cmp r6,#1
	bleq compareWithAllCodes
	cmp r9,#1
	beq displayE		@ending here, dealing with case of less than 4 char pass, all zero pass, and pre-existing pass			
thirdPressb:
	cmp r6,#1
	bleq displayC
	cmp r6,#2
	beq thirdPress
	add r6,r6,#1
	b loop

	
	
checkZero:
	stmfd sp!, {r0-r7,lr}
	ldr r1,=currCode
	mov r9,#0
	mov r5,#0
	zeroLoop:
		ldrb r2,[r1]
		cmp r2,#0x82
		beq doneZero
		cmp r2,#0
		movgt r9,#1
		add r1,r1,#1
		add r5,r5,#1
		cmp r5,#8
		blt zeroLoop
doneZero:
	ldmfd sp!, {r0-r7,pc}
	bx lr
	
	
compareWithAllCodes:		@compares currCode with all codes stored. r9 = 1: code matches one of the stored codes. r9 = 0: no matching code exists
	stmfd sp!, {r0-r7,lr}
	@r3 references head
	cmp r3,r4				@if codes does not have a single code stored yet, no need to check
	moveq r9,#0
	beq doneComparing
	loop1:
		ldr r2,=currCode2
		mov r6,#0
		loop2:					@loop stores codes into currCode2 in order to compare to currCode
			ldrb r5,[r3]
			strb r5,[r2]
			add r2,r2,#1
			add r3,r3,#1
			add r6,r6,#1
			cmp r6,#7
			blt loop2
		bl compareCodes			@compares currCode & currCode2
		cmp r9,#1
		beq doneComparing
		cmp r3,r4
		moveq r9,#0
		beq doneComparing
		b loop1
doneComparing:
	ldmfd sp!, {r0-r7,pc}
	bx lr
	
	
shiftLeft:
	stmfd sp!, {r0-r7,lr}
	add r9,r8,#7
	sub r7,r8,#7
	cmp r9,r4
	beq doneShifting
	shiftLoop:
		ldrb r9,[r8]
	ldmfd sp!, {r0-r7,pc}
	
checkLength:
	stmfd sp!, {r0-r4,lr}
	ldr r4,=currCode
	sub r9,r1,r4
	cmp r9,#4
	movlt r9,#0
	movgt r9,#1
	moveq r9,#1
	ldmfd sp!, {r0-r4,pc}
	bx lr
	
thirdPress:
	bl compareCodes
	cmp r9,#0
	bleq displayE
	cmp r9,#1
	bleq displayA
	bleq writeToCodes
	addeq r4,r4,#7
	moveq r6,#0
	bleq clearCurrCode
	bleq clearCurrCode2
	ldreq r1,=currCode
	ldreq r2,=currCode2
	b loop
	
writeToCodes:
	stmfd sp!, {r0-r9,lr}
	ldr r2,=currCode
	sub r8,r1,r2
	@r4 is tail of codes
	mov r5,#0
	storeLoop:
		add r5,r5,#1
		cmp r5,#8
		beq storeDone
		ldrb r3,[r2]
		strb r3,[r4]
		add r2,r2,#1
		add r4,r4,#1
		b storeLoop
storeDone:
	add r4,r4,r8
	ldmfd sp!, {r0-r9,pc}
	bx lr
	

	
	
lightLeft:
	stmfd sp!, {r0-r1,lr}
	mov r0,#0x02
	swi SWI_SETLED
	bl Wait
	mov r0,#0
	swi SWI_SETLED
	ldmfd sp!, {r0-r1,pc}
	bx lr
lightRight:
	stmfd sp!, {r0-r1,lr}
	mov r0,#0x01
	swi SWI_SETLED
	bl Wait
	mov r0,#0
	swi SWI_SETLED
	ldmfd sp!, {r0-r1,pc}
	bx lr
lightBoth:
	stmfd sp!, {r0-r1,lr}
	mov r0,#0x03
	swi SWI_SETLED
	bl Wait
	mov r0,#0
	swi SWI_SETLED
	ldmfd sp!, {r0-r1,pc}
	bx lr

compareCodes:
	stmfd sp!, {r0-r8,lr}	@using r9 as "return" boolean for matching or not
	ldr r1,=currCode
	ldr r2,=currCode2
	mov r5,#0
	compareLoop:
		add r5,r5,#1
		cmp r5,#8
		moveq r9,#1
		beq postLoop
		ldrb r3,[r1]
		ldrb r4,[r2]
		add r1,r1,#1
		add r2,r2,#1
		cmp r3,r4
		beq compareLoop
	mov r9,#0
postLoop:
	ldmfd sp!, {r0-r8,pc}	
	bx lr
	
	
	
Wait:
	stmfd sp!, {r0-r9,lr}
	mov r2,#100
	swi SWI_GetTicks
	mov r1, r0 @ R1: start time
WaitLoop:
	swi SWI_GetTicks
	subs r0, r0, r1 @ R0: time since start
	rsblt r0, r0, #0 @ fix unsigned subtract
	cmp r0, r2
	blt WaitLoop
WaitDone:
	ldmfd sp!, {r0-r9,pc}	
	bx lr

	
bluePressed:
	bl lightBoth
	ldr r9,=currCode
	sub r9,r1,r9		@starting here,
	cmp r9,#7
	bleq displayE
	bleq clearCurrCode	@and ending here, checking if user went above 7 char limit
	beq loop
	cmp r0,#1
	bleq zero
	cmp r0,#2
	bleq one
	cmp r0,#4
	bleq two
	cmp r0,#8
	bleq three
	cmp r0,#16
	bleq four
	cmp r0,#32
	bleq five
	cmp r0,#64
	bleq six
	cmp r0,#128
	bleq seven
	cmp r0,#256
	bleq eight
	cmp r0,#512
	bleq nine
	cmp r0,#1024
	bleq ten
	cmp r0,#2048
	bleq eleven
	cmp r0,#4096
	bleq twelve
	cmp r0,#8192
	bleq thirteen
	cmp r0,#16384
	bleq fourteen
	cmp r0,#32768
	bleq fifteen
	b loop
zero:
	mov r5,#0
	strb r5,[r1]
	add r1,r1,#1
	bx lr
one:
	mov r5,#1
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr
two:
	mov r5,#2
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr
three:
	mov r5,#3
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr
four:
	mov r5,#4
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr
five:
	mov r5,#5
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr
six:
	mov r5,#6
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr
seven:
	mov r5,#7
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr
eight:
	mov r5,#8
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr
nine:
	mov r5,#9
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr
ten:
	mov r5,#10
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr
eleven:
	mov r5,#11
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr
twelve:
	mov r5,#12
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr
thirteen:
	mov r5,#13
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr
fourteen:
	mov r5,#14
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr
fifteen:
	mov r5,#15
	strb r5,[r1]
	add r1,r1,#1
	mov r5,#0
	bx lr

	
	
bluePressed2:
	bl lightBoth
	ldr r9,=currCode2
	sub r9,r2,r9		@starting here,
	cmp r9,#7
	bleq displayE
	bleq clearCurrCode2	@and ending here, checking if user went above 7 char limit
	beq loop
	cmp r0,#1
	bleq zero2
	cmp r0,#2
	bleq one2
	cmp r0,#4
	bleq two2
	cmp r0,#8
	bleq three2
	cmp r0,#16
	bleq four2
	cmp r0,#32
	bleq five2
	cmp r0,#64
	bleq six2
	cmp r0,#128
	bleq seven2
	cmp r0,#256
	bleq eight2
	cmp r0,#512
	bleq nine2
	cmp r0,#1024
	bleq ten2
	cmp r0,#2048
	bleq eleven2
	cmp r0,#4096
	bleq twelve2
	cmp r0,#8192
	bleq thirteen2
	cmp r0,#16384
	bleq fourteen2
	cmp r0,#32768
	bleq fifteen2
	b loop
zero2:
	mov r5,#0
	strb r5,[r2]
	add r2,r2,#1
	bx lr
one2:
	mov r5,#1
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
two2:
	mov r5,#2
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
three2:
	mov r5,#3
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
four2:
	mov r5,#4
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
five2:
	mov r5,#5
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
six2:
	mov r5,#6
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
seven2:
	mov r5,#7
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
eight2:
	mov r5,#8
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
nine2:
	mov r5,#9
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
ten2:
	mov r5,#10
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
eleven2:
	mov r5,#11
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
twelve2:
	mov r5,#12
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
thirteen2:
	mov r5,#13
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
fourteen2:
	mov r5,#14
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
fifteen2:
	mov r5,#15
	strb r5,[r2]
	add r2,r2,#1
	mov r5,#0
	bx lr
		
clearCurrCode:
	ldr r1,=currCode
	stmfd sp!, {r0-r9,lr}
	ldr r1,=currCode
	mov r3,#0
	mov r4,#0x82 @WAS ZERO
	cloop:
		strb r4,[r1]
		add r3,r3,#1
		add r1,r1,#1
		cmp r3,#7
		blt cloop
	ldmfd sp!,{r0-r9,pc}
	bx lr
	
clearCurrCode2:
	ldr r2,=currCode2
	stmfd sp!, {r0-r9,lr}
	ldr r1,=currCode2
	mov r3,#0
	mov r4,#0x82 @WAS ZERO
	cloop2:
		strb r4,[r1]
		add r3,r3,#1
		add r1,r1,#1
		cmp r3,#7
		blt cloop2
	ldmfd sp!,{r0-r9,pc}
	bx lr
		

		
displayU:
	stmfd	sp!,{r0-r2, lr}
	ldr		r2,=Letter
	ldr		r0,=0				@The number loaded into r0 correlates to the placement of the character in Letter
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	ldmfd	sp!, {r0-r2, pc}
	bx lr
displayL:
	stmfd	sp!,{r0-r2, lr}
	ldr		r2,=Letter
	ldr		r0,=1				@The number loaded into r0 correlates to the placement of the character in Letter
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	ldmfd	sp!, {r0-r2, pc}
	bx lr
displayP:
	stmfd	sp!,{r0-r2, lr}
	ldr		r2,=Letter
	ldr		r0,=2				@The number loaded into r0 correlates to the placement of the character in Letter
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	ldmfd	sp!, {r0-r2, pc}
	bx lr
displayC:
	stmfd	sp!,{r0-r2, lr}
	ldr		r2,=Letter
	ldr		r0,=3				@The number loaded into r0 correlates to the placement of the character in Letter
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	ldmfd	sp!, {r0-r2, pc}
	bx lr
displayF:
	stmfd	sp!,{r0-r2, lr}
	ldr		r2,=Letter
	ldr		r0,=4				@The number loaded into r0 correlates to the placement of the character in Letter
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	ldmfd	sp!, {r0-r2, pc}
	bx lr
displayA:
	stmfd	sp!,{r0-r2, lr}
	ldr		r2,=Letter
	ldr		r0,=5				@The number loaded into r0 correlates to the placement of the character in Letter
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	ldmfd	sp!, {r0-r2, pc}
	bx lr
displayE:
	bl clearCurrCode
	bl clearCurrCode2
	mov r6,#0
	ldr		r2,=Letter
	ldr		r0,=6				@The number loaded into r0 correlates to the placement of the character in Letter
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	b loop
displayBlank:
	stmfd	sp!,{r0-r2, lr}
	ldr		r2,=Letter
	ldr		r0,=7				@The number loaded into r0 correlates to the placement of the character in Letter
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	ldmfd	sp!, {r0-r2, pc}
	bx lr




.align
Letter:
	.word seg_B|seg_C|seg_D|seg_E|seg_G|seg_P			@U = Unlock	(r0,=0)	
	.word seg_D|seg_E|seg_G|seg_P						@L = Lock (r0,=1)
	.word seg_A|seg_B|seg_E|seg_F|seg_G|seg_P			@P = Program a code (r0,=2)
	.word seg_A|seg_D|seg_E|seg_G|seg_P					@C = Confirm new code (r0,=3)
	.word seg_A|seg_E|seg_F|seg_G|seg_P					@F = Forget old code (r0,=4)
	.word seg_A|seg_B|seg_C|seg_E|seg_F|seg_G|seg_P		@A = Programming request was successful (r0,=5)
	.word seg_A|seg_D|seg_E|seg_F|seg_G|seg_P			@E = Error (r0,=6)
	.word 0												@Blank display (r0,=7)
currCode:.skip 7
currCode2:.skip 7
codes:
	
	
	
	
	
	
	
	
	
	
	