li r0, 0
li r1, 1
li r2, 0x10000
li r3, 0x20000

tsl r6, 0(r2)
beq r6, r1, loop
stw r0, 0(r3)
stw r0, 0(r2)

loop:
tsl r4, 0(r2)
beq r4, r1, loop
ldw r5, 0(r3)
add r5, r5, r1
stw r5, 0(r3)
stw r0, 0(r2)
jmp loop

nop
nop
nop
nop
