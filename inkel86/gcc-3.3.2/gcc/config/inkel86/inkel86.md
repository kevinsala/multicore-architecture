;;Mida per defecte d'una instruccio
(define_attr "length" "" (const_int 2))


;;ADD i ADDI
(define_insn "addhi3"
    [(set (match_operand:HI 0 "register_operand" "=r,r")
          (plus:HI (match_operand:HI 1 "register_operand" "%r,r")
                   (match_operand:HI 2 "nonmemory_operand" "r,I")
          )
     )
    ]
    ""
    "@
     add\\t%0,%1,%2
     addi\\t%0,%1,%2"
)

;;SUB
(define_insn "subhi3"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (minus:HI (match_operand:HI 1 "register_operand" "r")
                    (match_operand:HI 2 "register_operand" "r")
          )
     )
    ]
    ""
    "sub\\t%0,%1,%2"
)



;;AND
(define_insn "andhi3"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (and:HI (match_operand:HI 1 "register_operand" "%r")
                  (match_operand:HI 2 "register_operand" "r")
          )
     )
    ]
    ""
    "and\\t%0,%1,%2"
)

(define_insn "inkel86_ashrhi1"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (ashiftrt:HI (match_operand:HI 1 "register_operand" "r")
                        (const_int 1)
          )
     )
    ]
    ""
    "sra\\t%0,%1"
)

(define_insn "inkel86_lshrhi1"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (lshiftrt:HI (match_operand:HI 1 "register_operand" "r")
                        (const_int 1)
          )
     )
    ]
    ""
    "srl\\t%0,%1"
)

(define_insn "inkel86_ashlhi1"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (ashift:HI (match_operand:HI 1 "register_operand" "r")
                        (const_int 1)
          )
     )
    ]
    ""
    "add\\t%0,%1,%1"
)

(define_expand "ashrhi3"
    [(set (match_operand:HI 0 "register_operand" "")
          (ashiftrt:HI (match_operand:HI 1 "register_operand" "")
                        (match_operand:HI 2 "register_operand" "")
          )
     )
    ]
    ""
    {
        emit_inkel86_ashrhi3(operands[0],operands[1],operands[2]);
        DONE;
    }
)

(define_expand "lshrhi3"
    [(set (match_operand:HI 0 "register_operand" "")
          (lshiftrt:HI (match_operand:HI 1 "register_operand" "")
                        (match_operand:HI 2 "register_operand" "")
          )
     )
    ]
    ""
    {
        emit_inkel86_lshrhi3(operands[0],operands[1],operands[2]);
        DONE;
    }
)

(define_expand "ashlhi3"
    [(set (match_operand:HI 0 "register_operand" "")
          (ashift:HI (match_operand:HI 1 "register_operand" "")
                        (match_operand:HI 2 "register_operand" "")
          )
     )
    ]
    ""
    {
        emit_inkel86_ashlhi3(operands[0],operands[1],operands[2]);
        DONE;
    }
)


;;OR
(define_insn "iorhi3"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (ior:HI (match_operand:HI 1 "register_operand" "%r")
                  (match_operand:HI 2 "register_operand" "r")
          )
     )
    ]
    ""
    "or\\t%0,%1,%2"
)

;;XOR
(define_insn "xorhi3"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (xor:HI (match_operand:HI 1 "register_operand" "%r")
                  (match_operand:HI 2 "register_operand" "r")
          )
     )
    ]
    ""
    "xor\\t%0,%1,%2"
)

;;NOT
(define_insn "one_cmplhi2"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (not:HI (match_operand:HI 1 "register_operand" "r")
          )
     )
    ]
    ""
    "not\\t%0,%1"
)

;;instruccions de comparacio. Tindrem: lt, ltu, le, leu, ft, ftu, ge, geu !!

(define_expand "cmphi"
  [(match_operand:HI 0 "register_operand" "")
   (match_operand:HI 1 "register_operand" "")]
  ""
  {
      inkel86_compare_op0 = operands[0];
      inkel86_compare_op1 = operands[1];
      DONE;
  }
)

(define_expand "sle"
    [(set (match_operand:HI 0 "register_operand" "")
          (le:HI (match_dup 1)
                 (match_dup 2)
          )
     )
    ]
    ""
    {
        operands[1]=inkel86_compare_op0;
        operands[2]=inkel86_compare_op1;
    }
)

(define_expand "sleu"
    [(set (match_operand:HI 0 "register_operand" "")
          (leu:HI (match_dup 1)
                 (match_dup 2)
          )
     )
    ]
    ""
    {
        operands[1]=inkel86_compare_op0;
        operands[2]=inkel86_compare_op1;
    }
)

(define_expand "slt"
    [(set (match_operand:HI 0 "register_operand" "")
          (lt:HI (match_dup 1)
                 (match_dup 2)
          )
     )
    ]
    ""
    {
        operands[1]=inkel86_compare_op0;
        operands[2]=inkel86_compare_op1;
    }
)

(define_expand "sltu"
    [(set (match_operand:HI 0 "register_operand" "")
          (ltu:HI (match_dup 1)
                 (match_dup 2)
          )
     )
    ]
    ""
    {
        operands[1]=inkel86_compare_op0;
        operands[2]=inkel86_compare_op1;
    }
)

(define_expand "sgt"
    [(set (match_operand:HI 0 "register_operand" "")
          (gt:HI (match_dup 1)
                 (match_dup 2)
          )
     )
    ]
    ""
    {
        operands[1]=inkel86_compare_op0;
        operands[2]=inkel86_compare_op1;
    }
)

(define_expand "sgtu"
    [(set (match_operand:HI 0 "register_operand" "")
          (gtu:HI (match_dup 1)
                 (match_dup 2)
          )
     )
    ]
    ""
    {
        operands[1]=inkel86_compare_op0;
        operands[2]=inkel86_compare_op1;
    }
)

(define_expand "sge"
    [(set (match_operand:HI 0 "register_operand" "")
          (ge:HI (match_dup 1)
                 (match_dup 2)
          )
     )
    ]
    ""
    {
        operands[1]=inkel86_compare_op0;
        operands[2]=inkel86_compare_op1;
    }
)

(define_expand "sgeu"
    [(set (match_operand:HI 0 "register_operand" "")
          (geu:HI (match_dup 1)
                 (match_dup 2)
          )
     )
    ]
    ""
    {
        operands[1]=inkel86_compare_op0;
        operands[2]=inkel86_compare_op1;
    }
)

(define_expand "sne"
    [(set (match_operand:HI 0 "register_operand" "")
          (ne:HI (match_dup 1)
                 (match_dup 2)
          )
     )
    ]
    ""
    {
        operands[1]=inkel86_compare_op0;
        operands[2]=inkel86_compare_op1;
    }
)

(define_insn "set_internal"
  [(set (match_operand:HI 0 "register_operand" "=r")
        (match_operator:HI 1 "comparison_operator"
         [(match_operand:HI 2 "register_operand" "r")
          (match_operand:HI 3 "register_operand" "r")]))]
  "(GET_CODE(operands[1]) != EQ && GET_CODE(operands[1]) != NE)"
  "cmp%C1\\t%0,%2,%3"
)


(define_expand "ble"
    [(label_ref (match_operand 0 "" ""))]
    ""
    {
        generar_salt(LE,operands[0]);
        DONE;
    }
)

(define_expand "bleu"
    [(label_ref (match_operand 0 "" ""))]
    ""
    {
        generar_salt(LEU,operands[0]);
        DONE;
    }
)

(define_expand "blt"
    [(label_ref (match_operand 0 "" ""))]
    ""
    {
        generar_salt(LT,operands[0]);
        DONE;
    }
)

(define_expand "bltu"
    [(label_ref (match_operand 0 "" ""))]
    ""
    {
        generar_salt(LTU,operands[0]);
        DONE;
    }
)

(define_expand "bgt"
    [(label_ref (match_operand 0 "" ""))]
    ""
    {
        generar_salt(GT,operands[0]);
        DONE;
    }
)

(define_expand "bgtu"
    [(label_ref (match_operand 0 "" ""))]
    ""
    {
        generar_salt(GTU,operands[0]);
        DONE;
    }
)

(define_expand "bge"
    [(label_ref (match_operand 0 "" ""))]
    ""
    {
        generar_salt(GE,operands[0]);
        DONE;
    }
)

(define_expand "bgeu"
    [(label_ref (match_operand 0 "" ""))]
    ""
    {
        generar_salt(GEU,operands[0]);
        DONE;
    }
)

(define_expand "bne"
    [(label_ref (match_operand 0 "" ""))]
    ""
    {
        generar_salt(NE,operands[0]);
        DONE;
    }
)

(define_expand "beq"
    [(label_ref (match_operand 0 "" ""))]
    ""
    {
        generar_salt(EQ,operands[0]);
        DONE;
    }
)

(define_insn "inkel86_bnozero"
  [(set (pc) (if_then_else
                           (ne (match_operand:HI 0 "register_operand" "r")
                               (const_int 0)
                           )
                           (label_ref (match_operand 1 "" ""))
                           (pc)
             )
   )
  ]
  ""
  {
    if (get_attr_length(insn) == 2)
    {
        /* saltem a -32..31(PC) */
        return "bne\t%0,%l1";
    }
    else
    {
        /* salt llarg */
        return "mhi\tr5,(%l1>>8)\n\tmli\tr5,%l1&255\n\tjne\t%0,r5";

    }
  }
  [(set (attr "length") (if_then_else
                       (ior
                        (gt (match_dup 1) (plus (pc) (const_int 28)))
                        (le (match_dup 1) (plus (pc) (neg (const_int 32))))
                       )
                       (const_int 6)
                       (const_int 2)
                      )
   )
  ]
)

(define_insn "inkel86_bzero"
  [(set (pc) (if_then_else
                          (eq (match_operand:HI 0 "register_operand" "r")
                              (const_int 0)
                          )
                          (label_ref (match_operand 1 "" ""))
                          (pc)
             )
   )
  ]
  ""
  {
    if (get_attr_length(insn) == 2)
    {
        /* saltem a -32..31(PC) */
        return "beq\t%0,%l1";
    }
    else
    {
        /* salt llarg */
        return "mhi\tr5,(%l1>>8)\n\tmli\tr5,%l1&255\n\tjeq\t%0,r5";

    }
  }
  [(set (attr "length") (if_then_else
                       (ior
                        (gt (match_dup 1) (plus (pc) (const_int 28)))
                        (le (match_dup 1) (plus (pc) (neg (const_int 32))))
                       )
                       (const_int 6)
                       (const_int 2)
                      )
   )
 ]
)

(define_insn "jump"
  [(set (pc) (label_ref (match_operand 0 "" "")))
  ]
  ""
  {
    if (get_attr_length(insn) == 2)
    {
        /* saltem a -32..31(PC) */
        return "br\t%l0";
    }
    else
    {
        /* salt llarg */
        return "mhi\tr5,%l0>>8\n\tmli\tr5,%l0&255\n\tjmp\tr5";
    }
  }
  [(set (attr "length") (if_then_else
                       (ior
                        (gt (match_dup 0) (plus (pc) (const_int 28)))
                        (le (match_dup 0) (plus (pc) (neg (const_int 32))))
                       )
                       (const_int 6)
                       (const_int 2)
                      )
   )
 ]
)

(define_insn "indirect_jump"
  [(set (pc) (match_operand:HI 0 "register_operand" "r"))]
  ""
  "jmp\\t%0"
)

(define_expand "call"
  [ (call (match_operand:HI 0 "" "")
          (match_operand:HI 1 "" "")
    )
  ]
  ""
  {
     if (GET_CODE(operands[0]) == MEM && GET_CODE(XEXP(operands[0],0)) != REG)
     {
        rtx reg, mem;
        reg = force_reg(HImode,XEXP(operands[0],0));
        emit_call_insn(gen_inkel86_call(reg,operands[1]));
        DONE;
     }
  }
)

(define_insn "inkel86_call"
  [(call
    (mem:HI (match_operand:HI 0 "register_operand" "r"))   ;; si el registre no es HI no va
    (match_operand:HI 1 "" "i")
   )
  ]
  ""
  "jalr\\t%0,r5"
)


(define_expand "call_value"
  [(set (match_operand:HI 0 "register_operand" "=r")
        (call
          (match_operand:HI 1 "" "")
          (match_operand:HI 2 "" "")
        )
   )
  ]
  ""
  {
     if (GET_CODE(operands[1]) == MEM && GET_CODE(XEXP(operands[1],0)) != REG)
     {
        rtx reg, mem;
        reg = force_reg(HImode,XEXP(operands[1],0));
        emit_call_insn(gen_inkel86_call_value(operands[0],reg,operands[2]));
        DONE;
     }
  }
)


(define_insn "inkel86_call_value"
  [(set (match_operand:HI 0 "register_operand" "=r")
        (call
          (mem:HI (match_operand:HI 1 "register_operand" "r"))
          (match_operand:HI 2 "" "i")
        )
   )
  ]
  ""
  "jalr\\t%1,r5"
)


(define_expand "movhi"
  [(set (match_operand:HI 0 "nonimmediate_operand" "")
        (match_operand:HI 1 "general_operand" ""))]
  ""
  {
     /* Atencio: si els 2 operands son registres, hem de forsar que
      * l'operand font sigui un registre, no el desti, ja que si el desti el passem
      * a registre, no estem permetent les operacions de copia memoria-memoria que
      * es fan quan apiles parametres que ja estaven en memoria
      */
     if ((!register_operand(operands[0],HImode) && !register_operand(operands[1],HImode))
          && !(reload_completed | reload_in_progress))
     {
        /* evitem operacions memoria - memoria */
        operands[1] = force_reg (HImode,operands[1]);
     }
  }
)

(define_expand "movqi"
  [(set (match_operand:QI 0 "nonimmediate_operand" "")
        (match_operand:QI 1 "general_operand" ""))]
  ""
  {
     /* Atencio: si cap dels 2 operands son registres, hem de forsar que
      * l'operand font sigui un registre, no el desti, ja que si el desti el passem
      * a registre, no estem permetent les operacions de copia memoria-memoria que
      * es fan quan apiles parametres que ja estaven en memoria
      */
     if ((!register_operand(operands[0],QImode) && !register_operand(operands[1],QImode))
          && !(reload_completed | reload_in_progress))
     {
        /* evitem operacions memoria - memoria */
        operands[1] = force_reg (QImode,operands[1]);
     }
  }
)

(define_insn "movhi_zero"
  [(set (match_operand:HI 0 "register_operand" "=r")
        (const_int 0))]
  ""
  "xor\\t%0,%0,%0"
)

(define_insn "movqi_zero"
  [(set (match_operand:QI 0 "register_operand" "=r")
        (const_int 0))]
  ""
  "xor\\t%0,%0,%0"
)

;;diferents casos de loads
(define_insn "movhi_load"
  [(set (match_operand:HI 0 "register_operand" "=r,r,r,r,r,r,r")
        (match_operand:HI 1 "general_operand"   "r,I,K,S,Q,i,R"))]
  ""
  {
   switch(which_alternative)
   {
     case 0:
       return "addi\t%0,%1,0";
     case 1:
        return "xor\t%0,%0,%0\n\taddi\t%0,%0,%1";
     case 2:
        /* carreguem una constant de mes de 6 bits */
        return "mhi\t%0,(%1>>8)\n\tmli\t%0,(%1&255)";
     case 3:
        return "ldw\t%0,%O1(%B1)";
     case 4:
        /* el offset es de mes de 6 bits. Operacions extres per a sumar registres */
        return "mhi\t%0,(%O1>>8)\n\tmli\t%0,(%O1&255)\n\tadd\t%0,%B1,%0\n\tldw\t%0,0(%0)";
     case 5:
        return "mhi\t%0,(%1>>8)\n\tmli\t%0,(%1&255)";
     case 6:
        return "ldw\t%0,0(%R1)";
     default:
        abort();
   }
  }
  [(set_attr "length" "2,4,4,2,8,4,2")]
)

;;diferents casos de loads
(define_insn "movqi_load"
  [(set (match_operand:QI 0 "register_operand" "=r,r,r,r,r,r,r")
        (match_operand:QI 1 "general_operand"   "r,I,K,S,Q,i,R"))]
  ""
  {
   switch(which_alternative)
   {
     case 0:
       return "addi\t%0,%1,0";
     case 1:
        return "xor\t%0,%0,%0\n\taddi\t%0,%0,%1";
     case 2:
        /* carreguem una constant de mes de 6 bits */
        return "mhi\t%0,(%1>>8)\n\tmli\t%0,(%1&255)";
     case 3:
        return "ldb\t%0, %O1(%B1)";
     case 4:
        /* el offset es de mes de 6 bits. Operacions extres per a sumar registres */
        return "mhi\t%0,(%O1>>8)\n\tmli\t%0,(%O1&255)\n\tadd\t%0,%B1,%0\n\tldb\t%0,0(%0)";
     case 5:
        return "mhi\t%0,(%1>>8)\n\tmli\t%0,(%1&255)";
     case 6:
        return "ldb\t%0, 0(%R1)";
     default:
        abort();
   }
  }
  [(set_attr "length" "2,4,4,2,8,4,2")]
)


;;diferents casos de stores
(define_insn "movhi_store"
  [(set (match_operand:HI 0 "memory_operand" "=R,S,Q")
        (match_operand:HI 1 "register_operand" "r,r,r"))]
  ""
  "@
   stw\\t0(%R0),%1
   stw\\t%O0(%B0),%1
   mhi\\tr5,%O0>>8\\n\\tmli\\tr5,%O0&255\\n\\tadd\\tr5,%B0,r5\\n\\tstw\\t0(r5),%1"
  [(set_attr "length" "2,2,8")]
)


;;diferents casos de stores
(define_insn "movqi_store"
  [(set (match_operand:QI 0 "nonimmediate_operand" "=R,S,Q")
        (match_operand:QI 1 "nonmemory_operand" "r,r,r"))]
  ""
  "@
   stb\\t0(%R0),%1
   stb\\t%O0(%B0),%1
   mhi\\tr5,%O0>>8\\n\\tmli\\tr5,%O0&255\\n\\tadd\\tr5,%B0,r5\\n\\tstb\\t0(r5),%1"
  [(set_attr "length" "2,2,8")]
)

(define_expand "zero_extendqihi2"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (zero_extend:HI (match_operand:QI 1 "register_operand" "r"))
     )
    ]
   ""
   {
        rtx reg;

        if (GET_CODE(operands[1]) == SUBREG)
        {
            reg=XEXP(operands[1],0);
        }
        else
        {
            reg=operands[1];
        }

        if (GET_MODE(operands[0]) == GET_MODE(reg) &&
            REGNO(operands[0]) == REGNO(reg))
        {
            emit_insn(gen_inkel86_zero_extendqihi1(operands[0]));
        }
        else
        {
            if (GET_MODE(reg) == QImode)
            {
                emit_insn(gen_inkel86_zero_extendqihi2_reg(operands[0],reg));
            }
            else if (GET_MODE(reg) == HImode)
            {
                emit_insn(gen_inkel86_zero_extendqihi2_subreg(operands[0],reg));
            }
            else
            {
                abort();
            }
        }
        DONE;
   }
)

(define_insn "inkel86_zero_extendqihi1"
    [(set (subreg:QI (match_operand:HI 0 "register_operand" "=r") 2)
          (const_int 0)
     )
    ]
   ""
   "mhi\\t%0,0\\t\\t;inkel86_zero_extendqihi1"
)

(define_insn "inkel86_zero_extendqihi2_subreg"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (zero_extend:HI (subreg:QI (match_operand:HI 1 "register_operand" "r") 0))
     )
    ]
   ""
   "addi\\t%0,%1,0\\n\\tmhi\\t%0,0\\t\\t;inkel86_zero_extendqihi2_subreg"
  [(set_attr "length" "4")]
)

(define_insn "inkel86_zero_extendqihi2_reg"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (zero_extend:HI (match_operand:QI 1 "register_operand" "r"))
     )
    ]
   ""
   "addi\\t%0,%1,0\\n\\tmhi\\t%0,0\\t\\t;inkel86_zero_extendqihi2_reg"
  [(set_attr "length" "4")]
)


(define_expand "extendqihi2"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (zero_extend:HI (match_operand:QI 1 "register_operand" "r"))
     )
    ]
   ""
   {
        rtx reg;

        if (GET_CODE(operands[1]) == SUBREG)
        {
            reg=XEXP(operands[1],0);
        }
        else
        {
            reg=operands[1];
        }

        if (GET_MODE(operands[0]) == GET_MODE(reg) &&
            REGNO(operands[0]) == REGNO(reg))
        {
            emit_insn(gen_inkel86_extendqihi1(operands[0]));
        }
        else
        {
            if (GET_MODE(reg) == QImode)
            {
                emit_insn(gen_inkel86_extendqihi2_reg(operands[0],reg));
            }
            else if (GET_MODE(reg) == HImode)
            {
                emit_insn(gen_inkel86_extendqihi2_subreg(operands[0],reg));
            }
            else
            {
                abort();
            }
        }
        DONE;
   }
)

;;No fa res, es el comportament natural
(define_insn "inkel86_extendqihi1"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (zero_extend:HI (subreg:QI (match_dup 0) 0))
     )
    ]
   ""
   ""
   [(set_attr "length" "0")]
)

(define_insn "inkel86_extendqihi2_subreg"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (zero_extend:HI (subreg:QI (match_operand:HI 1 "register_operand" "r") 0))
     )
    ]
   ""
   "addi\\t%0,%1,0"
)

(define_insn "inkel86_extendqihi2_reg"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (zero_extend:HI (match_operand:QI 1 "register_operand" "r"))
     )
    ]
   ""
   "addi\\t%0,%1,0"
)



;;Aquest s'ha de definir obligatoriament
(define_insn "nop"
  [(const_int 0)]
  ""
  ""
)


(define_insn "tablejump"
  [(set (pc) (match_operand:HI 0 "register_operand" "r"))
   (use (label_ref (match_operand 1 "" "")))]
  ""
  "jmp\\t%0"
)


(define_insn "inkel86_ne"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (ne:HI (match_operand:HI 1 "register_operand" "%r")
                 (match_operand:HI 2 "register_operand" "r")
          )
     )
    ]
    ""
    "sub\\t%0,%1,%2\\n\\txor\\tr5,r5,r5\\n\\tcmpgtu\\t%0,%0,r5  ; comparacio"
    [(set_attr "length" "6")]
)

(define_insn "neghi2"
    [(set (match_operand:HI 0 "register_operand" "=r")
          (neg:HI (match_operand:HI 1 "register_operand" "r"))
     )
    ]
    ""
    "xor\\tr5,r5,r5\\n\\tsub\\t%0,r5,%1"
    [(set_attr "length" "4")]
)


