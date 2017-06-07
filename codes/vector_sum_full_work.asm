li r0, 0
li r1, 1
li r2, 2
li r3, 0
li r4, 4
li r5, 0x10000
li r6, 4
li r9, 0x20000

tsl r7, 0(r9)
beq r7, r1, vecsum

init:
stw r0, 0(r5)
add r5, r6, r5
add r3, r1, r3
bne r3, r4, init
stw r0, 0(r9)

li r5, 0x10000

vecsum:
tsl r10, 0(r9)
beq r10, r1, vecsum
ldw r7, 0(r5)
add r7, r2, r7
stw r7, 0(r5)
stw r0, 0(r9)
add r5, r6, r5
sub r4, r4, r1
bne r0, r4, vecsum

nop
nop
nop
nop


