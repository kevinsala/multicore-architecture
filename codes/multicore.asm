li r0, 0
li r1, 1
li r2, 10
li r3, 0x10000

nop
nop
pid r4
beq r4, r1, proc1

proc0:
stw r2, 0(r3)
jmp finalize

proc1:
ldw r5, 0(r3)

finalize:
nop
jmp finalize
