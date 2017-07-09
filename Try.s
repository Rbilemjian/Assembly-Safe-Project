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
	mov r7,#0	@boolean safe locked/unlocked. unlocked:0, locked:1
	ldr r1,=currCode
	@ldr r2,=codes @r2 = head
	@ldr r3,=codes @r3 = tail
	mov r6,#0 @number of times right black button has been pressed in this interaction
	
loop:
	swi SWI_CheckBlack
	cmp r0,#0x02
	beq leftPressed
	cmp r0,#0x01
	beq rightPressed
	swi SWI_CheckBlue
	cmp r0,#0
	blgt bluePressed
	b loop


leftPressed:
	bl lightLeft
	ldrb r4,[r2]
	cmp r4,#0
	bleq displayE
	beq loop
	bl displayL
	mov r7,#1
	b loop
	
	
rightPressed:
	bl lightRight
	cmp r6,#0
	bleq displayP
	cmp r6,#1
	bleq displayC
	cmp r6,#2
	@handle cases of displaying E & C
	add r6,r6,#1
	bl awaitBlue
	b loop
	
	
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
	
awaitBlue:
	blueLoop:
		swi SWI_CheckBlue
		cmp r0,#0
		beq blueLoop
		bl bluePressed
		mov r0,#0
		swi SWI_CheckBlack
		cmp r0,#0
		bxgt lr
	
	
	
	
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
	mov r6,#0
	strb r6,[r1]
	add r1,r1,#1
	bx lr
one:
	mov r6,#1
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr
two:
	mov r6,#2
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr
three:
	mov r6,#3
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr
four:
	mov r6,#4
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr
five:
	mov r6,#5
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr
six:
	mov r6,#6
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr
seven:
	mov r6,#7
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr
eight:
	mov r6,#8
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr
nine:
	mov r6,#9
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr
ten:
	mov r6,#10
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr
eleven:
	mov r6,#11
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr
twelve:
	mov r6,#12
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr
thirteen:
	mov r6,#13
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr
fourteen:
	mov r6,#14
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr
fifteen:
	mov r6,#15
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	bx lr

		
clearCurrCode:
	stmfd sp!, {r0-r9,lr}
	ldr r1,=currCode
	mov r3,#0
	mov r4,#0
	cloop:
		strb r4,[r1]
		add r3,r3,#1
		add r1,r1,#1
		cmp r3,#7
		blt cloop
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
	stmfd	sp!,{r0-r2, lr}
	ldr		r2,=Letter
	ldr		r0,=6				@The number loaded into r0 correlates to the placement of the character in Letter
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	ldmfd	sp!, {r0-r2, pc}
	bx lr
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
currCode:.skip 6
currCode2:.skip 6
codes: .skip 1000
	
	
	
	
	
	
	
	
	
	
	