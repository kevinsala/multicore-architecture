li r0, 0
li r1, 1
li r2, 2
li r3, 4
li r4, 128
li r5, 0x10000

init:
mul r2, r3, r2
mul r6, r2, r3
stw r6, 0(r5)
add r6, r6, r2
beq r0, r0, init