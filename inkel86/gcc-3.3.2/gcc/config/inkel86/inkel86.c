#include "config.h"  /* inclou inkel86.h */
#include "system.h"  /* defineix coses com bool, que s'usen en target.h */
#include "machmode.h" /* defineix enum machine_mode */
#include "output.h" /* defineix parts del TARGET_INITIALIZER corresponents a la sortida en assemblador */
#include "rtl.h"  /* defineix tot el tema rtx */
#include "regs.h" /* defineix regs_ever_live */
#include "tree.h" /* defineix merge_decl_attributes */
#include "expr.h" /* defineix default_init_builtins */
#include "tm_p.h" /* inclou inkel86-protos.h */
#include "target-def.h" /* defineix TARGET_INITIALIZER */
#include "target.h"
#include "real.h" /* defineix real_format_for_mode */

int const_ok_for_letter_p (int value, char c)
{
    if (c == 'I')
    {
        return (value >= -32 && value <= 31);
    }
    else if (c == 'J')
    {
        return (value >= -128 && value <= 127);
    }
    else if (c == 'K')
    {
        return (value >= 0 && value <= 65535);
    }
    else if (c == 'N')
    {
        return (value >= -32768  && value <= 65535);  /* totes les constants que podem tenir en Inkel86 */
    }
    else
    {
        return 0;
    }
}

int extra_constraint (rtx value, char c)
{
    int code;

    code = GET_CODE(value);

    if (code != MEM) return 0;

    if ((c == 'Q') || (c == 'S') || (c == 'R')) /* adreca amb offset. Q offset gran, S offset petit (-32..31), R sense offset */
    {
	rtx reg, offset;
        rtx addr = XEXP(value,0);
	int offset_gran;
        code = GET_CODE(addr);

        switch (code)
        {
          case REG:
            return (c == 'R');
	    break;
          case CONST_INT:
            return 0;
	    break;
          case PLUS:
            reg = XEXP(addr,0);
            offset = XEXP(addr,1);
            if (GET_CODE(reg) != REG)
            {
                reg = XEXP(addr,1);
                offset = XEXP(addr,0);
            }
            if (GET_CODE(reg) != REG || GET_CODE(offset) != CONST_INT)
            {
                /* error */
                abort();
            }
            offset_gran = (INTVAL(offset) < -32 || INTVAL(offset) > 31);
            return (((c == 'Q') && offset_gran) || ((c == 'S') && !offset_gran));
          default:
            /* error */
            abort();
        }
    }
    else
    {
        return 0;
    }
}

void inkel86_function_prologue (FILE *file, HOST_WIDE_INT size)
{
    int i;
    int num_reg_salvar = 0;
    int offset;
    int espai;

    for (i=0; i< FIRST_PSEUDO_REGISTER; i++)
    {
        if (regs_ever_live[i] && !call_used_regs[i])
        {
            num_reg_salvar++;
        }
    }
   /* hack!! salvem sempre r5 per a poder usar-lo com a scratch */
    num_reg_salvar++;

    fputs("\taddi\tr7,r7,-2\t\t;salvem r6 a la pila\n",file);
    fputs("\tstw\t0(r7),r6\n",file);
    fputs("\n\taddi\tr6,r7,0\t\t;assignem el FP\n",file);

    espai=size+num_reg_salvar*UNITS_PER_WORD;
    if (espai)
    {
        if (espai <= 32)
        {
            fprintf(
                file,"\taddi\tr7,r7,-%d\t\t;Espai per a registres i variables locals\n",
                espai);
        }
        else
        {
            fprintf(file,"\tmhi\tr7,-%d>>8\n\tmli\tr7,-%d&255\n\tadd\tr7,r7,r6\n",espai,espai);
        }
    }

    offset=size+UNITS_PER_WORD;
    for (i=0; i< FIRST_PSEUDO_REGISTER; i++)
    {
       /* hack!! salvem sempre r5 per a poder usar-lo com a scratch */
        if ((regs_ever_live[i] && !call_used_regs[i]) || i==5)
        {
            if (offset <= 32)
            {
                fprintf(file,"\tstw\t-%d(r6),%s\n",offset,reg_names[i]);
            }
            else
            {
                fprintf(file,"\tstw\t%d(r7),%s\n",espai-offset,reg_names[i]);
            }
            offset+=UNITS_PER_WORD;
        }
    }
}

void inkel86_function_epilogue (FILE *file, HOST_WIDE_INT size)
{
    int i;
    int num_reg_restaurar = 0;
    int offset;
    int espai;

    for (i=0; i< FIRST_PSEUDO_REGISTER; i++)
    {
        if (regs_ever_live[i] && !call_used_regs[i])
        {
            num_reg_restaurar++;
        }
    }
    /* hack!! salvem sempre r5 per a poder usar-lo com a scratch */
    num_reg_restaurar++;

    espai=size+num_reg_restaurar*UNITS_PER_WORD;
    offset=size+UNITS_PER_WORD;

    for (i=0; i< FIRST_PSEUDO_REGISTER; i++)
    {
        /* hack!! salvem sempre r5 per a poder usar-lo com a scratch */
        if ((regs_ever_live[i] && !call_used_regs[i]) || i==5)
        {
            if (offset <= 32)
            {
                fprintf(file,"\tldw\t%s,-%d(r6)\n",reg_names[i],offset);
            }
            else
            {

                fprintf(file,"\tldw\t%s,%d(r7)\n",reg_names[i],espai-offset);
            }
            offset+=UNITS_PER_WORD;
        }
    }

    fputs("\taddi\tr7,r6,2\n",file);
    fputs("\tldw\tr6,0(r6)\n",file);
    fputs("\tjmp\tr5\n\n",file);

}

void print_operand (FILE * stream, rtx x, int code)
{
    int rtx_code;
    rtx addr, offset, reg;

    if (x == 0)
    {
        /* error, de moment no ho faig servir aixo */
        fputs("Error de print operand: rtx null\n",stream);
        abort();
        return;
    }

    rtx_code = GET_CODE(x);

    switch (code)
    {
      case 0:
        switch (rtx_code)
        {
          case LABEL_REF:
            if (GET_CODE(XEXP(x,0)) != CODE_LABEL)
            {
                abort();
            }
            output_addr_const (stream, XEXP(x,0));
            break;
          case SYMBOL_REF:
            fputs(XSTR(x,0),stream);
            break;
          case REG:
            fputs(reg_names[REGNO(x)],stream);
            break;
          default:
            fprintf(stream,"%d",INTVAL(x));
            break;
        }
        break;
      case 'R':
        reg = XEXP(x,0);
        fputs(reg_names[REGNO(reg)],stream);
        break;
      case 'B':   /* registre base d'una adreca amb offset */
        addr = XEXP(x,0);
        reg = XEXP(addr,0);
        if (GET_CODE(reg) != REG)
        {
            reg = XEXP(addr,1);
        }
        fputs(reg_names[REGNO(reg)],stream);
        break;
      case 'O':   /* offset d'una adreca amb offset */
        addr = XEXP(x,0);
        offset = XEXP(addr,0);
        if (GET_CODE(offset) != CONST_INT)
        {
            offset = XEXP(addr,1);
        }
        fprintf(stream,"%d",INTVAL(offset));
        break;
      case 'C':   /* comparacions */
        switch (rtx_code)
        {
          case LE:  fputs("le",stream);  break;
          case LEU: fputs("leu",stream); break;
          case LT:  fputs("lt",stream);  break;
          case LTU: fputs("ltu",stream); break;
          case GT:  fputs("gt",stream);  break;
          case GTU: fputs("gtu",stream); break;
          case GE:  fputs("ge",stream);  break;
          case GEU: fputs("geu",stream); break;
          default: abort();
        }
        break;
      case 'S':    /* seguent registre */
        if (rtx_code != REG || GET_MODE(x) != SImode || REGNO(x) == 7)
        {
            abort();
        }
        fputs(reg_names[REGNO(x)+1],stream);
        break;
      default:
        /* error */
        fputs("Error de print_operand: opcio no coneguda\n",stream);
        abort();
        break;
    }
    return;
}

void print_operand_address (FILE * stream, rtx x)
{
    if (!x)
    {
        abort();
    }

    switch (GET_CODE(x))
    {
      case SYMBOL_REF:
        fputs(XSTR(x,0),stream);
        break;
      case CONST_INT:
        fprintf(stream,"%d",INTVAL(x));
        break;
      default:
        abort();
        break;
    }
}


rtx inkel86_compare_op0;
rtx inkel86_compare_op1;
void generar_salt (enum rtx_code tipus, rtx operand)
{
    int canvi_condicio = 0;
    /* registre temporal on guardem el resultat de la comparacio */
    rtx tmp_reg = gen_reg_rtx(HImode);

    rtx tst_insn, inkel86_cmp_insn;
    switch (tipus)
    {
      case EQ:
        /* cridem a inkel86_ne, pero despres canviem la condicio de salt */
        inkel86_cmp_insn = gen_inkel86_ne(tmp_reg,inkel86_compare_op0,inkel86_compare_op1);
        canvi_condicio = 1;
        break;
      case NE:
        inkel86_cmp_insn = gen_inkel86_ne(tmp_reg,inkel86_compare_op0,inkel86_compare_op1);
        break;
      default:
        tst_insn = gen_rtx(tipus,HImode,inkel86_compare_op0,inkel86_compare_op1);
        inkel86_cmp_insn = gen_rtx(SET,HImode,tmp_reg,tst_insn);
        break;
    }

    emit_insn(inkel86_cmp_insn);

    /* Ara ens queda fer el salt */
    /* ATENCIO!!! usant emit_insn no funciona, ja que no te en compte
     * que per aqui dins hi ha una etiqueta!!!
     */
     if (canvi_condicio)
     {
        emit_jump_insn(gen_inkel86_bzero(tmp_reg,operand));
     }
     else
     {
        emit_jump_insn(gen_inkel86_bnozero(tmp_reg,operand));
     }
}

/* Undefs i defs del Target Hook */
#undef TARGET_ASM_BYTE_OP
#define TARGET_ASM_BYTE_OP "\t.DB\t"
#undef TARGET_ASM_ALIGNED_HI_OP
#define TARGET_ASM_ALIGNED_HI_OP "\t.DW\t"
#undef TARGET_ASM_ALIGNED_SI_OP
#define TARGET_ASM_ALIGNED_SI_OP "\t.DD\t"

/* codi assemblador del proleg i epilog */
#undef TARGET_ASM_FUNCTION_PROLOGUE
#define TARGET_ASM_FUNCTION_PROLOGUE inkel86_function_prologue
#undef TARGET_ASM_FUNCTION_EPILOGUE
#define TARGET_ASM_FUNCTION_EPILOGUE inkel86_function_epilogue

#undef TARGET_ASM_INTEGER
#define TARGET_ASM_INTEGER inkel86_target_asm_integer


/* Aqui hi aniran les variables que son del tipus Target Hook */
struct gcc_target targetm = TARGET_INITIALIZER;

void inkel86_override_options (void)
{
  memset (real_format_for_mode, 0, sizeof(real_format_for_mode));
  real_format_for_mode[SFmode - QFmode] = &ieee_single_format;
  real_format_for_mode[DFmode - QFmode] = &ieee_double_format;
}

rtx inkel86_function_value (tree type, tree func)
{
    if (int_size_in_bytes(type) <= UNITS_PER_WORD)
    {
        /* promocionem els possibles retorns de char a int */
        return gen_rtx_REG(HImode,1);
    }
    else
    {
        return gen_rtx_MEM(TYPE_MODE(type),gen_rtx_REG(Pmode,1));
    }
}

rtx inkel86_lib_value (enum machine_mode mode)
{
    if (GET_MODE_SIZE(mode) <= UNITS_PER_WORD)
    {
        return gen_rtx_REG(mode,1);
    }
    else
    {
        return gen_rtx_MEM(mode,gen_rtx_REG(Pmode,1));
    }
}


/* Target Hook per a fer una variable global. No aplicable en Inkel86 */
void inkel86_globalize_label (FILE * stream, const char * name)
{
}

bool inkel86_target_asm_integer (rtx x, unsigned int size, int aligned_p)
{
    switch (size)
    {
      case 1:
        fputs("\t.DB\t",asm_out_file);
        break;
      case 2:
        fputs("\t.DW\t",asm_out_file);
        break;
      case 4:
        fputs("\t.DL\t",asm_out_file);
        break;
      default:
        return false;
    }
    output_addr_const(asm_out_file,x);
    fputs("\n",asm_out_file);
    return true;
}

void emit_inkel86_ashrhi3(rtx desti, rtx font, rtx quant)
{
    rtx inici, fi, tmp;

    inici = gen_label_rtx();
    fi = gen_label_rtx();
    tmp = gen_reg_rtx(HImode);

    emit_move_insn(tmp,font);
    emit_move_insn(desti,quant);
    inkel86_compare_op0 = desti;
    inkel86_compare_op1 = gen_reg_rtx(HImode);
    emit_insn(gen_xorhi3(inkel86_compare_op1,inkel86_compare_op1,inkel86_compare_op1));
    emit_label(inici);
    generar_salt(EQ,fi);
    emit_insn(gen_inkel86_ashrhi1(tmp,tmp));
    emit_insn(gen_addhi3(desti,desti,gen_rtx_CONST_INT(HImode,-1)));
    emit_jump_insn(gen_jump(inici));
    emit_label(fi);
    /* Ha d'acabar amb un SET per a poder assignar el REG_EQUAL */
    emit_move_insn(desti,tmp);
}

void emit_inkel86_lshrhi3(rtx desti, rtx font, rtx quant)
{
    rtx inici, fi, tmp;

    inici = gen_label_rtx();
    fi = gen_label_rtx();
    tmp = gen_reg_rtx(HImode);

    emit_move_insn(tmp,font);
    emit_move_insn(desti,quant);
    inkel86_compare_op0 = desti;
    inkel86_compare_op1 = gen_reg_rtx(HImode);
    emit_insn(gen_xorhi3(inkel86_compare_op1,inkel86_compare_op1,inkel86_compare_op1));
    emit_label(inici);
    generar_salt(EQ,fi);
    emit_insn(gen_inkel86_lshrhi1(tmp,tmp));
    emit_insn(gen_addhi3(desti,desti,gen_rtx_CONST_INT(HImode,-1)));
    emit_jump_insn(gen_jump(inici));
    emit_label(fi);
    /* Ha d'acabar amb un SET per a poder assignar el REG_EQUAL */
    emit_move_insn(desti,tmp);
}


void emit_inkel86_ashlhi3(rtx desti, rtx font, rtx quant)
{
    rtx inici, fi, tmp;

    inici = gen_label_rtx();
    fi = gen_label_rtx();
    tmp = gen_reg_rtx(HImode);

    emit_move_insn(tmp,font);
    emit_move_insn(desti,quant);
    inkel86_compare_op0 = desti;
    inkel86_compare_op1 = gen_reg_rtx(HImode);
    emit_insn(gen_xorhi3(inkel86_compare_op1,inkel86_compare_op1,inkel86_compare_op1));
    emit_label(inici);
    generar_salt(EQ,fi);
    emit_insn(gen_inkel86_ashlhi1(tmp,tmp));
    emit_insn(gen_addhi3(desti,desti,gen_rtx_CONST_INT(HImode,-1)));
    emit_jump_insn(gen_jump(inici));
    emit_label(fi);
    /* Ha d'acabar amb un SET per a poder assignar el REG_EQUAL */
    emit_move_insn(desti,tmp);
}

