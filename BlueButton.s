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
start:
	ldr r6,=codes
	ldr r7,=head
	ldr r8,=tail
	str r6,[r7]
	str r6,[r8]
	ldr r1,=currCode
	mov r4,#0
loop:
	ldr r5,=currCode
	sub r5,r1,r5
	cmp r5,#6
	@bgt display E
	mov r0,#0
	swi SWI_CheckBlack
	cmp r0,#0x02
	moveq r8,#2
	beq leftblackpressed
	cmp r0,#0x01
	moveq r8,#1
	beq rightblackpressed
	swi SWI_CheckBlue
	cmp r0,#0
	beq loop	@if r0 == 0, no blue button pressed
BluePressed:
	bl lightBothLED
	cmp r0,#1
	beq zero
	cmp r0,#2
	beq one
	cmp r0,#4
	beq two
	cmp r0,#8
	beq three
	cmp r0,#16
	beq four
	cmp r0,#32
	beq five
	cmp r0,#64
	beq six
	cmp r0,#128
	beq seven
	cmp r0,#256
	beq eight
	cmp r0,#512
	beq nine
	cmp r0,#1024
	beq ten
	cmp r0,#2048
	beq eleven
	cmp r0,#4096
	beq twelve
	cmp r0,#8192
	beq thirteen
	cmp r0,#16384
	beq fourteen
	cmp r0,#32768
	beq fifteen
	b loop
zero:
	mov r6,#0
	strb r6,[r1]
	add r1,r1,#1
	b loop
one:
	mov r6,#1
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
two:
	mov r6,#2
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
three:
	mov r6,#3
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
four:
	mov r6,#4
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
five:
	mov r6,#5
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
six:
	mov r6,#6
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
seven:
	mov r6,#7
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
eight:
	mov r6,#8
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
nine:
	mov r6,#9
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
ten:
	mov r6,#10
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
eleven:
	mov r6,#11
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
twelve:
	mov r6,#12
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
thirteen:
	mov r6,#13
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
fourteen:
	mov r6,#14
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
fifteen:
	mov r6,#15
	strb r6,[r1]
	add r1,r1,#1
	mov r6,#0
	b loop
leftblackpressed:
	swi SWI_SETLED
	bl Wait
	mov r0,#0
	swi SWI_SETLED
	
	b loop
rightblackpressed:
	swi SWI_SETLED
	bl Wait
	mov r0,#0
	swi SWI_SETLED
	cmp r4,#0
	beq newCode
	b loop
lightBothLED:
	stmfd sp!, {r0-r1,lr}
	mov r0,#0x03
	swi SWI_SETLED
	bl Wait
	mov r0,#0
	swi SWI_SETLED
	ldmfd sp!, {r0-r1,pc}
	bx lr
Wait:
	stmfd sp!, {r0-r1,lr}
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
	ldmfd sp!, {r0-r1,pc}	
	bx lr
newCode:
	
exit:
	swi 0x11
.align
currCode:.skip 100
head:.skip 2
tail:.skip 2
codes:
.align

