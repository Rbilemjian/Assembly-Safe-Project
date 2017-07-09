mov r0,#3

Loop:
cmp r0,#3
beq Flip1
cmp r0,#0
beq Flip2

DoneFlip:
swi 0x201



b Loop


Flip1:
mov r0,#0
b DoneFlip

Flip2:
mov r0,#3
b DoneFlip
