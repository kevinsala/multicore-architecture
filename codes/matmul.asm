li r0, 0
li r1, 1
li r2, 4
# Matrix size
li r3, 4
# r3 * 4
li r20, 16

# A
li r10, 0x10000
# B
li r11, 0x11000

# Initialization
# i counter
li r4, 0

loopiniti:
# j counter 0x120
li r5, 0
loopinitj:
stw r5, 0(r10)
stw r5, 0(r11)
add r10, r2, r10
add r11, r2, r11

add r5, r1, r5
bne r5, r3, loopinitj

add r4, r1, r4
bne r4, r3, loopiniti

# Calculation
# A[i]
li r10, 0x10000
li r11, 0x10000
# B
li r12, 0x11000
# C
li r13, 0x12000

# i counter
li r4, 0
loopi:

# j counter
li r5, 0
loopj:

# @A = @A[i][0]
mov r11, r10
# @B = @B[0][j]
mul r21, r5, r2
li r12, 0x11000
add r12, r12, r21
# C[i][j] = 0
li r18, 0

# k counter
li r6, 0
loopk:

# Do one iteration
ldw r15, 0(r11)
ldw r16, 0(r12)
mul r17, r15, r16
add r18, r17, r18

# @A = @A + 1
add r11, r2, r11
# @B = @B + (k * N)
add r12, r20, r12

add r6, r1, r6
bne r6, r3, loopk

stw r18, 0(r13)

# @C = @C + 1
add r13, r2, r13

add r5, r1, r5
bne r5, r3, loopj

# @A[i] = @A[i] + N
add r10, r20, r10

add r4, r1, r4
bne r4, r3, loopi
