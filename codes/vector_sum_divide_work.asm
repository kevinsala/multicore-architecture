li r0, 0
li r1, 1
li r2, 4
li r3, 0
li r4, 32
li r5, 0x10000

init:
stw r3, 0(r5)
add r5, r2, r5
add r3, r1, r3
bne r3, r4, init

pid r7
beq r7, r1, proc1

proc0:
li r5, 0x10000
jmp vecsum

proc1:
li r5, 0x10040

vecsum:
ldw r7, 0(r5)
add r7, r2, r7
stw r7, 0(r5)
add r5, r2, r5
sub r3, r1, r3
bne r3, r0, vecsum
