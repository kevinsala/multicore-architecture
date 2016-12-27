li  R0, 0
li  R1, 0x10000
li  R2, 0x07C
li  R3, 4
li  R5, 1
stw R0, 0(R1)

loop:
add R0, R0, R3
add R1, R1, R3
ldw R4, -4(R1)
add R4, R4, R5
stw R4, 0(R1)
jmp loop
