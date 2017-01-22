li r0, 0
li r1, 1
li r2, 2
li r3, 3
mov r31, r4
mov r30, r5
beq r5, r2, dtlb
beq r5, r3, itlb

fin:
jump fin

dtlb:
tlbwrite r4, 1
iret
 
itlb:
tlbwrite r4, 0
iret