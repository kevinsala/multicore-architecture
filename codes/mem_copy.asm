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

mov r3, r0
li r5, 0x10000
li r6, 0x20000

memcpy:
ldw r7, 0(r5)
stw r7, 0(r6)
add r5, r2, r5
add r6, r2, r6
add r3, r1, r3
bne r3, r4, memcpy
