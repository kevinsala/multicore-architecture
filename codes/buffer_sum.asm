li r0, 0
li r1, 1
li r2, 4
li r3, 0
li r4, 128
li r5, 0x10000

init:
stw r3, 0(r5)
add r5, r2, r5
add r3, r1, r3
bne r3, r4, init

mov r6, r0
li r5, 0x10000

add:
mov r3, r0
ldw r7, 0(r5)
add r6, r7, r6
add r5, r2, r5
add r3, r1, r3
bne r3, r4, add
