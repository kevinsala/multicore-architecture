li r0, 0
li r1, 1
li r2, 4
li r3, 0
li r4, 32
pid r10
add r10, r10, r1
li r11, 0x10000
mul r11, r11, r10
mov r5, r11

init:
stw r3, 0(r5)
add r5, r2, r5
add r3, r1, r3
bne r3, r4, init

mov r3, r0
mov r5, r11
add r6, r11, r11

memcpy:
ldw r7, 0(r5)
stw r7, 0(r6)
add r5, r2, r5
add r6, r2, r6
add r3, r1, r3
bne r3, r4, memcpy
