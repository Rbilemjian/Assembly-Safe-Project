@Group 1
@Raffi Bilemjian
@Meshari Alkheraigi
@Nima Yousef Hakimi
@Ryan Johnston
@Ayda Rahimi


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
.equ SWI_LCD_Print_String, 0x204	@outputs string onto LCD
.equ SWI_LCD_Clear_Screen, 0x206	@clears LCD screen
.equ SWI_RdInt,0x6c
.equ SWI_Open,0x66
.equ SWI_RdStr,0x6a
.equ SWI_PrChr,0x00
.equ SWI_PrStr,0x69
.equ seg_A, 0x80
.equ seg_B, 0x40
.equ seg_C, 0x20
.equ seg_D, 0x08
.equ seg_E, 0x04
.equ seg_F, 0x02
.equ seg_G, 0x01
.equ seg_P, 0x10

start:
swi SWI_LCD_Clear_Screen
mov	r0,#4
mov	r1,#1
ldr	r2,=LCD1		
swi	SWI_LCD_Print_String			
mov	r0,#4
mov	r1,#2
ldr	r2,=LCD2
swi	SWI_LCD_Print_String
mov	r0,#4
mov	r1,#3
ldr	r2,=LCD3
swi	SWI_LCD_Print_String		@displays initial menu

LCD_loop:							@loop awaiting input for menu choice from user
	swi SWI_CheckBlue
	cmp r0,#1
	beq blueError
	cmp r0,#2						@checks if blue button 1 (Encrypt) was selected
	bleq lightBoth
	beq LCD_option_1
	cmp r0,#4						@checks if blue button 2 (Decrypt) was selected
	bleq lightBoth
	beq LCD_option_2
	cmp r0,#8						@checks if blue button 3 (Safe Control) was selected
	bleq lightBoth
	beq LCD_option_3
	bgt blueError
	swi SWI_CheckBlack
	cmp r0,#0
	bgt blackError
	b LCD_loop
	
blueError:							@handles invalid blue button input for menu (0 or >3)
	bl lightBoth
	b LCD_Error
	
blackError:							@handles black button input, which is invalid in menu
	cmp r0,#0x02
	bleq lightLeft
	cmp r0,#0x01
	bleq lightRight
	b LCD_Error
	
blackError1:						@handles invalid black button input within option 1 of menu
	cmp r0,#0x02
	bleq lightLeft
	cmp r0,#0x01
	bleq lightRight
	b LCD_option_1_loop
	
blackError2:						@handles invalid black button input within option 2 of menu
	cmp r0,#0x02
	bleq lightLeft
	cmp r0,#0x01
	bleq lightRight
	b LCD_option_2_loop
	
LCD_errorb:							@prints error message for invalid input and jumps back to code where method was called
	stmfd sp!, {r0-r1,lr}
	mov r0,#4
	mov r1,#7
	ldr r2,=LCDerror2
	swi SWI_LCD_Print_String
	ldmfd sp!, {r0-r1,pc}	
	bx lr
	
LCD_Error:							@displays erronous input message and jumps back to LCD menu loop to await valid input
	mov	r0,#4
	mov	r1,#7
	ldr	r2,=LCDerror2
	swi	SWI_LCD_Print_String
	b LCD_loop

LCD_option_1:						@if "1.Encrypt" was selected
	swi SWI_LCD_Clear_Screen
	mov r0,#4
	mov r1,#2
	ldr r2,=option1or2
	swi SWI_LCD_Print_String		@displays shift value input message
LCD_option_1_loop:					@loops waiting for button input. If blue button, encrypts using inputted number. If black button, displays error msg and continues waiting
	swi SWI_CheckBlue
	cmp r0,#0
	bgt bluePressedShiftEncrypt
	swi SWI_CheckBlack
	cmp r0,#0
	blgt LCD_errorb
	bgt blackError2
	b LCD_option_1_loop

LCD_option_2:						@if "2.Decrypt" was selected
	swi SWI_LCD_Clear_Screen
	mov r0,#4
	mov r1,#2
	ldr r2,=option1or2
	swi SWI_LCD_Print_String		@displays shift value input message
LCD_option_2_loop:					@loops waiting for button input. If blue button, decrypts using inputted number. If black button, displays error msg and continues waiting
	swi SWI_CheckBlue
	cmp r0,#0
	bgt bluePressedShiftDecrypt
	swi SWI_CheckBlack
	cmp r0,#0
	blgt LCD_errorb
	bgt blackError2
	b LCD_option_2_loop

LCD_option_3:						@if "3.Safe Control" was selected
	swi SWI_LCD_Clear_Screen
	b safeControl					@jumps to safe control (have it jump to the star of the safe control program)
								
								
bluePressedShiftEncrypt:			@stores proper value into r3 for shift input for encryption, then jumps to encryption
	bl lightBoth
	cmp r0,#1
	moveq r3,#0
	cmp r0,#2
	moveq r3,#1
	cmp r0,#4
	moveq r3,#2
	cmp r0,#8
	moveq r3,#3
	cmp r0,#16
	moveq r3,#4
	cmp r0,#32
	moveq r3,#5
	cmp r0,#64
	moveq r3,#6
	cmp r0,#128
	moveq r3,#7
	cmp r0,#256
	moveq r3,#8
	cmp r0,#512
	moveq r3,#9
	cmp r0,#1024
	moveq r3,#10
	cmp r0,#2048
	moveq r3,#11
	cmp r0,#4096
	moveq r3,#12
	cmp r0,#8192
	moveq r3,#13
	cmp r0,#16384
	moveq r3,#14
	cmp r0,#32768
	moveq r3,#15
	bl encryption
	b start
		
	bluePressedShiftDecrypt:		@stores proper value into r3 for shift input for decryption, then jumps to decryption
	bl lightBoth
	cmp r0,#1
	moveq r3,#0
	cmp r0,#2
	moveq r3,#1
	cmp r0,#4
	moveq r3,#2
	cmp r0,#8
	moveq r3,#3
	cmp r0,#16
	moveq r3,#4
	cmp r0,#32
	moveq r3,#5
	cmp r0,#64
	moveq r3,#6
	cmp r0,#128
	moveq r3,#7
	cmp r0,#256
	moveq r3,#8
	cmp r0,#512
	moveq r3,#9
	cmp r0,#1024
	moveq r3,#10
	cmp r0,#2048
	moveq r3,#11
	cmp r0,#4096
	moveq r3,#12
	cmp r0,#8192
	moveq r3,#13
	cmp r0,#16384
	moveq r3,#14
	cmp r0,#32768
	moveq r3,#15
	bl decryption
	b start
	
	
safeControl:						@starts safe control program
	swi SWI_CheckBlack				@checking for previous black or blue button inputs, and clearing them so they don not get recognized by safe
	swi SWI_CheckBlue
	mov r0,#0
	mov r7,#0 						@boolean safe locked/unlocked. unlocked:0, locked:1
	mov r6,#0 						@number of times right black button has been pressed in this interaction
	mov r10,#0 						@boolean delete/add deleting code:1. else adding code
	ldr r1,=currCode
	ldr r2,=currCode2
	ldr r3,=codes @r3 = head
	ldr r4,=codes @r4 = tail
	add r3,r3,#150
	add r4,r4,#150
	bl clearCurrCode
	bl clearCurrCode2
	bl displayU

loop:								@main loop for dealing with button inputs and jumping to proper method
	cmp r6,#0
	bleq noPresses
postNoPresses:
	swi SWI_CheckBlack
	cmp r0,#0x02
	beq leftPressed
	cmp r0,#0x01
	beq rightPressed
	swi SWI_CheckBlue
	cmp r0,#0
	bgt bluePressedPreliminary
	b loop
	
noPresses:							@if nothing has been inputted in a loop of "loop", ensures that safe status is displayed (locked or unlocked)
	cmp r7,#0
	bleq displayU
	blgt displayL
	b postNoPresses
	
bluePressedPreliminary:				@method to determine which bluebutton method to call based on # of right black button presses
	cmp r6,#0
	beq bluePressed
	cmp r6,#1
	beq bluePressed
	cmp r6,#2
	beq bluePressed2
	cmp r6,#3
	bleq displayE
	b loop

leftPressed:						@method to handle left button pressed, 
	bl lightLeft
	ldr r1,=currCode
	cmp r7,#0
	beq lockSafe
	cmp r7,#1
	beq unlockSafe
	
lockSafe:							@If valid code is stored in codes, locks safe and leaves to loop. If not, displays E and leaves
	bl clearCurrCode
	bl clearCurrCode2
	ldrb r9,[r3]
	cmp r9,#0x81
	bleq displayE
	beq loop
	bl displayL
	mov r7,#1
	b loop	
	
unlockSafe:							@If entered code matches a code in codes, unlocks safe. If not, displays E. Then leaves to loop
	bl compareWithAllCodes
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
	bleq clearCurrCode
	bleq displayP
	addeq r6,r6,#1
	beq loop
secondPress:
	cmp r6,#1						@starting here,
	bleq checkLength
	cmp r9,#0
	beq displayE
	cmp r6,#1
	bleq checkZero
	cmp r9,#0
	beq displayE
	cmp r6,#1
	bleq compareWithAllCodes
	cmp r9,#1						@ending here, dealing with case of less than 4 char pass, all zero pass, and pre-existing pass
	moveq r10,#1
	cmp r6,#1
	cmpeq r10,#0
	bleq displayC
	cmp r10,#1
	bleq displayF
	cmp r6,#2
	beq thirdPress
	add r6,r6,#1
	b loop
	
thirdPress:
	bl compareCodes
	cmp r9,#0
	bleq displayE
	cmp r9,#1
	beq codesEqual
	b loop
	
codesEqual:							@if 2nd code input confirmed to be equal to 1st code input, method either deletes existing code from codes or adds new code depending on deletion boolean r10
	bl displayA
	mov r6,#0
	cmp r10,#1
	bleq deleteCode
	subeq r4,r4,#7
	moveq r8,r4
	bleq deleteCode @need to call it again to delete duplicate code after shift
	cmp r10,#0
	bleq writeToCodes
	addeq r4,r4,#7
	bl clearCurrCode
	bl clearCurrCode2
	ldr r1,=currCode
	ldr r2,=currCode2
	mov r10,#0
	b loop
	
	
	
checkZero:							@checks if code has at least one non-zero digit. If all 0s, returns 0 in r9. Else returns 1
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
	
	
compareWithAllCodes:				@compares currCode with all codes stored. r9 = 1: code matches one of the stored codes. r9 = 0: no matching code exists
	stmfd sp!, {r0-r7,lr}
	@r3 references head
	cmp r3,r4						@if codes does not have a single code stored yet, no need to check
	moveq r9,#0
	beq doneComparing
	loop1:
		ldr r2,=currCode2
		mov r6,#0
		mov r0,r3
		loop2:						@loop stores codes into currCode2 in order to compare to currCode
			ldrb r5,[r3]
			strb r5,[r2]
			add r2,r2,#1
			add r3,r3,#1
			add r6,r6,#1
			cmp r6,#7
			blt loop2
		bl compareCodes				@compares currCode & currCode2
		cmp r9,#1
		mov r8,r0
		beq doneComparing
		cmp r3,r4
		moveq r9,#0
		beq doneComparing
		b loop1
doneComparing:
	bl clearCurrCode2
	ldmfd sp!, {r0-r7,pc}
	bx lr
	
	
shiftLeft:							@assume r8 stores first index of codes that need to be shifted.
	stmfd sp!, {r0-r7,lr}
	ldrb r0,[r8]
	cmp r0,#0x81
	beq doneShifting
	sub r7,r8,#7
	shiftLoop:						@shifts all codes 7 to the left, continuing to shift bits until bit containg hex 81 is encountered, meaning empty memory
		ldrb r9,[r8]
		cmp r9,#0x81
		beq doneShifting
		strb r9,[r7]
		add r8,r8,#1
		add r7,r7,#1
		b shiftLoop
doneShifting:
	sub r8,r8,#7
	ldmfd sp!, {r0-r7,pc}
	b postShift
	
deleteCode:							@assume r8 stores first index of code that needs to be deleted and stores hex 81 into 7 slots of code. Then calls shift to shift proceeding codes as needed
	stmfd sp!, {r0-r7,lr}
	mov r6,#0
	mov r5,#0x81
	deleteLoop:
		strb r5,[r8]
		add r8,r8,#1
		add r6,r6,#1
		cmp r6,#7
		blt deleteLoop
	bl shiftLeft
postShift:
	ldmfd sp!, {r0-r7,pc}
	bx lr
	
checkLength:						@checks if code is shorter than 4 digits. If it is too short, returns 0 in r9. Else returns 1
	stmfd sp!, {r0-r4,lr}
	ldr r4,=currCode
	sub r9,r1,r4
	cmp r9,#4
	movlt r9,#0
	movgt r9,#1
	moveq r9,#1
	ldmfd sp!, {r0-r4,pc}
	bx lr
	

	
writeToCodes:						@writes code contained in currCode to codes, where valid codes for locking and unlocking are stored
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
	ldmfd sp!, {r0-r9,pc}
	add r4,r4,#7
	bx lr
	

	
	
lightLeft:							@lights left LED
	stmfd sp!, {r0-r1,lr}
	mov r0,#0x02
	swi SWI_SETLED
	bl Wait
	mov r0,#0
	swi SWI_SETLED
	ldmfd sp!, {r0-r1,pc}
	bx lr
lightRight:							@lights right LED
	stmfd sp!, {r0-r1,lr}
	mov r0,#0x01
	swi SWI_SETLED
	bl Wait
	mov r0,#0
	swi SWI_SETLED
	ldmfd sp!, {r0-r1,pc}
	bx lr
lightBoth:							@lights both LEDs
	stmfd sp!, {r0-r1,lr}
	mov r0,#0x03
	swi SWI_SETLED
	bl Wait
	mov r0,#0
	swi SWI_SETLED
	ldmfd sp!, {r0-r1,pc}
	bx lr

compareCodes:						@compares codes in currCode and currCode2 for confirmation purposes (eg. confirming a new code or confirming deletion of old code)
	stmfd sp!, {r0-r8,lr}			@using r9 as "return" boolean for matching or not
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
	
	
	
Wait:								@makes program wait for 100 ms
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
	
Wait2:								@makes program wait for 1 second
	stmfd sp!, {r0-r9,lr}
	mov r2,#1000
	swi SWI_GetTicks
	mov r1, r0 @ R1: start time
WaitLoop2:
	swi SWI_GetTicks
	subs r0, r0, r1 @ R0: time since start
	rsblt r0, r0, #0 @ fix unsigned subtract
	cmp r0, r2
	blt WaitLoop2
WaitDone2:		
	ldmfd sp!, {r0-r9,pc}	
	bx lr
	
Wait3:								@makes program wait for 2 seconds
	stmfd sp!, {r0-r9,lr}
	ldr r2,=0x7D0
	swi SWI_GetTicks
	mov r1, r0 @ R1: start time
WaitLoop3:
	swi SWI_GetTicks
	subs r0, r0, r1 @ R0: time since start
	rsblt r0, r0, #0 @ fix unsigned subtract
	cmp r0, r2
	blt WaitLoop3
WaitDone3:
	ldmfd sp!, {r0-r9,pc}	
	bx lr
	
bluePressed:						@lights both LEDs, stores proper value for blue button input into current pointer in currCode
	bl lightBoth
	ldr r9,=currCode
	sub r9,r1,r9					@starting here,
	cmp r9,#7
	beq displayE					@and ending here, checking if user went above 7 digit limit
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

	
	
bluePressed2:						@lights both LEDs, stores proper value from blue button input into currCode2 in memory				
	bl lightBoth
	ldr r9,=currCode2
	sub r9,r2,r9					@starting here,
	cmp r9,#7
	beq displayE					@and ending here, checking if user went above 7 char limit
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
		
clearCurrCode:					@clears current code and replaces all 7 slots in memory with hexadecimal 82 (which represents null within a code)
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
	
clearCurrCode2:					@clears current code 2 and replaces all 7 slots in memory with hexadecimal 82 (which represents null within a code)
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
	ldr		r0,=1				
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	ldmfd	sp!, {r0-r2, pc}
	bx lr
displayP:
	stmfd	sp!,{r0-r2, lr}
	ldr		r2,=Letter
	ldr		r0,=2				
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	ldmfd	sp!, {r0-r2, pc}
	bx lr
displayC:
	stmfd	sp!,{r0-r2, lr}
	ldr		r2,=Letter
	ldr		r0,=3				
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	ldmfd	sp!, {r0-r2, pc}
	bx lr
displayF:
	stmfd	sp!,{r0-r2, lr}
	ldr		r2,=Letter
	ldr		r0,=4				
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	ldmfd	sp!, {r0-r2, pc}
	bx lr
displayA:
	stmfd	sp!,{r0-r2, lr}
	ldr		r2,=Letter
	ldr		r0,=5				
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	bl Wait2
	ldmfd	sp!, {r0-r2, pc}
	bx lr
displayE:						
	ldr r1,=currCode
	bl clearCurrCode
	bl clearCurrCode2			@clears currCode 1 and 2 resets their currCode curr pointer to its head
	mov r6,#0					@resets r6 (number of black button presses) to 0
	mov r10,#0					@resets r10 (add/delete boolean) to 0
	ldr		r2,=Letter
	ldr		r0,=6				
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	ldr r2,=currCode2			@resets curr pointer of currCode2 to its head
	bl Wait2
	b loop
displayBlank:
	stmfd	sp!,{r0-r2, lr}
	ldr		r2,=Letter
	ldr		r0,=7				@The number loaded into r0 correlates to the placement of the character in Letter
	ldr		r0,[r2, r0, lsl#2]
	swi		0x200
	ldmfd	sp!, {r0-r2, pc}
	bx lr
	
	
	
	
encryption:
	stmfd sp!,{r0-r10,lr}
	ldr r0,=InFileName
	mov r1,#0
	swi SWI_Open				@this & following line attempt to open input file, if none found displays error message to user in inFileErrorEncryption
	bcs inFileErrorEncryption
	mov r7,r0
	mov r0,r7
	ldr r1,=CharArray
	mov r2, #1000
	mov r6,r3
	swi SWI_RdStr
	ldrb r5,[r1]
	cmp r5,#0
	bleq displayError			@handles case of empty input file, displays to user that input file is empty
	beq doneEncryption
	cmp r3,#0
	beq writeToFile
readbitloop:
	LDRB R5, [R1] 				@loads each character in charArray from start to end
	cmp r5,#0
	beq writeToFile
	mov r8,#0
	incCharLoop:				@loops number of times of shift desired by user
		cmp r5,#126
		moveq r5,#32			@this with line before it handles case of rollover in ASCII table
		addne r5,r5,#1 			@increments character
		add r8,r8,#1
		cmp r8,r6
		blt incCharLoop
	strb r5,[r1] 				@stores character back into chararray
	add r1,r1,#1 				@increments pointer in chararray
	b readbitloop
writeToFile:					@writes encrypted message to output file
	ldr r0,=OutFileName
	mov r1,#1
	swi SWI_Open
	ldr r1,=OutFileHandle
	str r0,[r1]
	ldr r1,=CharArray
	swi SWI_PrStr
	bl clearCharArray
doneEncryption:
	ldmfd sp!,{r0-r10,pc}
	bx lr
decryption:						@same as code foundation as encryption. Only difference: shifts left, not right.
	stmfd sp!,{r0-r10,lr}
	ldr r0,=InFileName2
	mov r1,#0
	swi SWI_Open
	bcs inFileErrorDecryption
	mov r7,r0
	mov r0,r7
	ldr r1,=CharArray
	mov r2, #1000
	mov r6,r3
	swi SWI_RdStr
	ldrb r5,[r1]
	cmp r5,#0
	bleq displayError
	beq doneDecryption
	cmp r6,#0
	beq writeToFile
readbitloop2:
	LDRB R5, [R1] 				@loads curr bit of chararray
	cmp r5,#0
	beq writeToFile2
	mov r8,#0
	incCharLoop2:
		cmp r5,#32
		moveq r5,#126
		subne r5,r5,#1 			@decrements character
		add r8,r8,#1
		cmp r8,r6
		blt incCharLoop2
	strb r5,[r1] 				@stores character back into chararray
	add r1,r1,#1 				@increments pointer in chararray
	b readbitloop2
writeToFile2:
	ldr r0,=OutFileName2
	mov r1,#1
	swi SWI_Open
	ldr r1,=OutFileHandle2
	str r0,[r1]
	ldr r1,=CharArray
	swi SWI_PrStr
	bl clearCharArray
doneDecryption:
	ldmfd sp!,{r0-r10,pc}
	bx lr

	
displayError:					@displays error of empty input file
	stmfd sp!,{r0-r10,lr}
	swi SWI_LCD_Clear_Screen
	mov r0,#4
	mov r1,#2
	ldr r2,=LCDerror1
	swi SWI_LCD_Print_String
	bl Wait3
	ldmfd sp!,{r0-r10,pc}
	bx lr
	
clearCharArray:					@clears charArray in memory by replacing bits with 0 until a bit that already contains 0 is reach, at which point method exits back to where it was called
	stmfd sp!,{r0-r10,lr}
	ldr r0,=CharArray
	mov r2,#0
	clearLoop:
		ldrb r1,[r0]
		cmp r1,#0
		beq doneClearing
		strb r2,[r0]
		add r0,r0,#1
		b clearLoop
doneClearing:
	ldmfd sp!,{r0-r10,pc}
	bx lr
	
inFileErrorEncryption:			@handles case of no input file existing for encryption. Displays to user then starts program over
	swi SWI_LCD_Clear_Screen
	mov r0,#4
	mov r1,#2
	ldr r2,=InFileError
	swi SWI_LCD_Print_String
	bl Wait3
	b start
inFileErrorDecryption:			@handles case of no input file existing for decryption. Displays to user then starts program over
	swi SWI_LCD_Clear_Screen
	mov r0,#4
	mov r1,#2
	ldr r2,=InFileError2
	swi SWI_LCD_Print_String
	bl Wait3
	b start

.data
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
LCD1:	.asciz "1. Encrypt\n"
LCD2:	.asciz "2. Decrypt\n"
LCD3:	.asciz "3. Safe Control\n"
LCDerror1: .asciz "Input file is empty."
LCDerror2: .asciz "Invalid input."
option1or2:	.asciz	"Enter a shift value from 0 - 15"
InFileError:.asciz "No input file found for encryption"
InFileError2:.asciz "No input file found for decryption"
InFileHandle: .word 0
InFileName: .asciz "inputencryption.txt"
OutFileHandle: .word 4
OutFileName: .asciz "outputencryption.txt"
InFileName2:.asciz "inputdecryption.txt"
OutFileName2:.asciz "outputdecryption.txt"
InFileHandle2:.word 1
OutFileHandle2:.word 3
CharArray: .skip 1000									@array used to store ASCII values of strings from input files for encryption and decryption. Also used to write to output file
currCode:.skip 7										@array used to store current code, first input of a code stores it there in safe control
currCode2:.skip 7										@array used to store current code 2, second input of a code for confirmation stores it there in safe control
codes:													@"dynamic" array used to store all valid codes which user has entered. Does not have static size, program can continue adding to it until memory runs out
		
	
	
	
	
	
	
	
	
	
	