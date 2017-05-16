li r0, 0
li r1, 1
li r2, 2
li r3, 0x10000
ldw r10, 0(r3)
ldw r10, 0(r3)
ldw r10, 0(r3)
ldw r10, 0(r3)
mul r4, r1, r2
stw r1, 0(r3)
stw r2, 0(r3)
tsl r5, 0(r3)
