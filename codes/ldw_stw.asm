li r0, 0x10000
li r1, 0x20000
li r2, 0xABCDE
stw r2, 0(r0)
ldw r3, 0(r0)
stw r3, 0(r1)
