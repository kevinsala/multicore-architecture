li r0, 0
li r1, 1
li r2, 4
li r3, 0
li r4, 4
li r5, 0x10000
li r6, 0x20000

tsl r7, 0(r6)
beq r7, r1, wait

init:
stw r0, 0(r5)
add r5, r2, r5
add r3, r1, r3
bne r3, r4, init
stw r0, 0(r6)
jmp pids

wait:
tsl r7, 0(r6)
nop
beq r7, r1, wait


pids:
li r3, 0
li r4, 2
pid r7
beq r7, r1, proc1

proc0:
li r5, 0x10000
jmp vecsum

proc1:
li r5, 0x10008

vecsum:
ldw r7, 0(r5)
add r7, r2, r7
stw r7, 0(r5)
add r5, r2, r5
add r3, r1, r3
bne r3, r4, vecsum

end:
nop
jmp end
nop
