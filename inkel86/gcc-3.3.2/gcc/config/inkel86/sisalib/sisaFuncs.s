

.code
.subr SisaHalt
    halt

.subr SisaIn
    addi    r7,r7,-2
    stw     0(r7),r6
    addi    r6,r7,0

    addi    r7,r7,-6

    stw     -2(r6),r0
    stw     -4(r6),r2
    stw     -6(r6),r4

    ldw     r2,2(r6)
    xor     r4,r4,r4
    mli     r4,64

    cmpgeu  r0,r2,r4
    bne     r0,LfinalIns
    mhi     r4,LiniciIns>>8
    mli     r4,LiniciIns&255

    add     r2,r2,r2
    add     r2,r2,r2      ;; multipliquem per 4

    add     r4,r4,r2

    mhi     r0,LfinalIns>>8
    mli     r0,LfinalIns&255
    jmp     r4

LfinalIns:
    ;;restaurem registres

    ldw     r4,-6(r6)
    ldw     r2,-4(r6)
    ldw     r0,-2(r6)
    
    ldw     r6,0(r6)
    addi    r7,r7,8
    
    jmp     r5

LiniciIns:

    in      r1,00
    jmp     r0
    in      r1,01
    jmp     r0
    in      r1,02
    jmp     r0
    in      r1,03
    jmp     r0
    in      r1,04
    jmp     r0
    in      r1,05
    jmp     r0
    in      r1,06
    jmp     r0
    in      r1,07
    jmp     r0
    in      r1,08
    jmp     r0
    in      r1,09
    jmp     r0
    in      r1,10
    jmp     r0
    in      r1,11
    jmp     r0
    in      r1,12
    jmp     r0
    in      r1,13
    jmp     r0
    in      r1,14
    jmp     r0
    in      r1,15
    jmp     r0
    in      r1,16
    jmp     r0
    in      r1,17
    jmp     r0
    in      r1,18
    jmp     r0
    in      r1,19
    jmp     r0
    in      r1,20
    jmp     r0
    in      r1,21
    jmp     r0
    in      r1,22
    jmp     r0
    in      r1,23
    jmp     r0
    in      r1,24
    jmp     r0
    in      r1,25
    jmp     r0
    in      r1,26
    jmp     r0
    in      r1,27
    jmp     r0
    in      r1,28
    jmp     r0
    in      r1,29
    jmp     r0
    in      r1,30
    jmp     r0
    in      r1,31
    jmp     r0
    in      r1,32
    jmp     r0
    in      r1,33
    jmp     r0
    in      r1,34
    jmp     r0
    in      r1,35
    jmp     r0
    in      r1,36
    jmp     r0
    in      r1,37
    jmp     r0
    in      r1,38
    jmp     r0
    in      r1,39
    jmp     r0
    in      r1,40
    jmp     r0
    in      r1,41
    jmp     r0
    in      r1,42
    jmp     r0
    in      r1,43
    jmp     r0
    in      r1,44
    jmp     r0
    in      r1,45
    jmp     r0
    in      r1,46
    jmp     r0
    in      r1,47
    jmp     r0
    in      r1,48
    jmp     r0
    in      r1,49
    jmp     r0
    in      r1,50
    jmp     r0
    in      r1,51
    jmp     r0
    in      r1,52
    jmp     r0
    in      r1,53
    jmp     r0
    in      r1,54
    jmp     r0
    in      r1,55
    jmp     r0
    in      r1,56
    jmp     r0
    in      r1,57
    jmp     r0
    in      r1,58
    jmp     r0
    in      r1,59
    jmp     r0
    in      r1,60
    jmp     r0
    in      r1,61
    jmp     r0
    in      r1,62
    jmp     r0
    in      r1,63



.subr SisaOut
    addi    r7,r7,-2
    stw     0(r7),r6
    addi    r6,r7,0

    addi    r7,r7,-8
    stw     -2(r6),r0
    stw     -4(r6),r2
    stw     -6(r6),r3
    stw     -8(r6),r4

    ldw     r2,2(r6)     ;; en r2 el numero de port
    ldw     r3,4(r6)     ;; en r3 la quantitat a mostrar

    xor     r4,r4,r4
    mli     r4,64

    xor     r1,r1,r1
    cmpgeu  r0,r2,r4
    bne     r0,Lfinal
    mhi     r4,LregistreI00>>8
    mli     r4,LregistreI00&255

    add     r2,r2,r2
    add     r2,r2,r2      ;; multipliquem per 4

    add     r4,r4,r2

    mhi     r0,LfinalCarrega>>8
    mli     r0,LfinalCarrega&255
    jmp     r4


LfinalCarrega:
    addi    r1,r1,1

Lfinal:
    ;;restaurem registres

    ldw     r4,-8(r6)
    ldw     r3,-6(r6)
    ldw     r2,-4(r6)
    ldw     r0,-2(r6)
    
    ldw     r6,0(r6)
    addi    r7,r7,10
    
    jmp     r5

LregistreI00:
    out    00,r3
    jmp    r0
    out    01,r3
    jmp    r0
    out    02,r3
    jmp    r0
    out    03,r3
    jmp    r0
    out    04,r3
    jmp    r0
    out    05,r3
    jmp    r0
    out    06,r3
    jmp    r0
    out    07,r3
    jmp    r0
    out    08,r3
    jmp    r0
    out    09,r3
    jmp    r0
    out    10,r3
    jmp    r0
    out    11,r3
    jmp    r0
    out    12,r3
    jmp    r0
    out    13,r3
    jmp    r0
    out    14,r3
    jmp    r0
    out    15,r3
    jmp    r0
    out    16,r3
    jmp    r0
    out    17,r3
    jmp    r0
    out    18,r3
    jmp    r0
    out    19,r3
    jmp    r0
    out    20,r3
    jmp    r0
    out    21,r3
    jmp    r0
    out    22,r3
    jmp    r0
    out    23,r3
    jmp    r0
    out    24,r3
    jmp    r0
    out    25,r3
    jmp    r0
    out    26,r3
    jmp    r0
    out    27,r3
    jmp    r0
    out    28,r3
    jmp    r0
    out    29,r3
    jmp    r0
    out    30,r3
    jmp    r0
    out    31,r3
    jmp    r0
    out    32,r3
    jmp    r0
    out    33,r3
    jmp    r0
    out    34,r3
    jmp    r0
    out    35,r3
    jmp    r0
    out    36,r3
    jmp    r0
    out    37,r3
    jmp    r0
    out    38,r3
    jmp    r0
    out    39,r3
    jmp    r0
    out    40,r3
    jmp    r0
    out    41,r3
    jmp    r0
    out    42,r3
    jmp    r0
    out    43,r3
    jmp    r0
    out    44,r3
    jmp    r0
    out    45,r3
    jmp    r0
    out    46,r3
    jmp    r0
    out    47,r3
    jmp    r0
    out    48,r3
    jmp    r0
    out    49,r3
    jmp    r0
    out    50,r3
    jmp    r0
    out    51,r3
    jmp    r0
    out    52,r3
    jmp    r0
    out    53,r3
    jmp    r0
    out    54,r3
    jmp    r0
    out    55,r3
    jmp    r0
    out    56,r3
    jmp    r0
    out    57,r3
    jmp    r0
    out    58,r3
    jmp    r0
    out    59,r3
    jmp    r0
    out    60,r3
    jmp    r0
    out    61,r3
    jmp    r0
    out    62,r3
    jmp    r0
    out    63,r3
    jmp    r0

