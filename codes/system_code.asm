li r26, 2
li r27, 3
mov r31, r28
mov r30, r29
beq r29, r26, dtlb
beq r29, r27, itlb

fin:
jump fin

dtlb:
tlbwrite r28, 1
iret

itlb:
tlbwrite r28, 0
iret
