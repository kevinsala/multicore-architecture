
extern rtx sisa_compare_op0;
extern rtx sisa_compare_op1;


/* 10.2 Controlling the Compilation Driver, 'gcc' */

/* opcions que li passem al cc1 */
/* -fno-common fa que les dades no inicialitzades vagin a la seccio de
 * dades en lloc de el BSS */
#define CC1_SPEC "-fno-common"
#define ASM_SPEC "-sisa-asm"
#define LINK_SPEC "-sisa-ld"
/* De moment no volem el crt0.o */
#define STARTFILE_SPEC ""
/* De moment no volem -lc */
#define LIB_SPEC ""

/* 10.3 Run-time Target Specification */
#define CPP_PREDEFINES "-Dsisa -DSISA"
#define TARGET_VERSION fprintf(stderr, " SISA 1.0");

/* 0 en aquest cas es el target_flags per defecte
 * Si no es defineix aixo, cc1 fa un segfault en l'inicialitzacio
 */
#define TARGET_SWITCHES {{"",0}}

#define OVERRIDE_OPTIONS sisa_override_options()

/* 10.4 Definng data structures for pre-function information */

/* 10.5 Stroage Layout */
#define BITS_PER_UNIT 8
#define BITS_BIG_ENDIAN 0
#define BYTES_BIG_ENDIAN 0
#define WORDS_BIG_ENDIAN 0
#define BITS_PER_WORD 16
#define UNITS_PER_WORD 2
#define POINTER_SIZE BITS_PER_WORD

/* Indica que els alineaments son forsosos, i.e. q no es que fan
 * que l'acces sigui mes lent, sino que es crea una excecio si
 * no es fa un acces alineat */
#define STRICT_ALIGNMENT 1

/* Accessos a memoria han d'estar alienats a word */
#define FUNCTION_BOUNDARY BITS_PER_WORD
#define BIGGEST_ALIGNMENT BITS_PER_WORD
#define STACK_BOUNDARY BITS_PER_WORD
#define PARM_BOUNDARY BITS_PER_UNIT

/* Mida en bits del mode mes gran que pot usar la maquina per a integers
 */ 
#define MAX_FIXED_MODE_SIZE 16

/* Nou mode que te una variable quan la volem guardar en un registre */
#define PROMOTE_MODE(MODE, UNSIGNEDP, TYPE) \
 if (GET_MODE_CLASS (MODE) == MODE_INT && GET_MODE_SIZE (MODE) < 2)\
 (MODE) = HImode, (UNSIGNEDP) = 0

/* Indica que la regla anterior de promocio tambe s'aplica al retorn
 * de resultats d'una funcio
 */
#define PROMOTE_FUNCTION_RETURN

/* 10.6 Layout of source Language Data Types */
#define SHORT_TYPE_SIZE BITS_PER_WORD
#define INT_TYPE_SIZE BITS_PER_WORD
#define LONG_TYPE_SIZE (BITS_PER_WORD*2)
#define LONG_LONG_TYPE_SIZE (BITS_PER_WORD*2)
#define CHAR_TYPE_SIZE BITS_PER_UNIT

/* definicio de flotants, de 32 i 64 (el 64 es per a que vagi libgcc) */
#define FLOAT_TYPE_SIZE (BITS_PER_WORD*2)
#define DOUBLE_TYPE_SIZE (BITS_PER_WORD*2)
#define LONG_DOUBLE_TYPE_SIZE (BITS_PER_WORD*4)

/* Especifica si per defecte char es signed o unsigned
 */
#define DEFAULT_SIGNED_CHAR 0

/* 10.7 Target Character Escape Sequences */

/* 10.8 Register Usage */
#define FIRST_PSEUDO_REGISTER 8 /* r0-r7 */
#define FIXED_REGISTERS \
  { 0, 0, 0, 0, 0, 1, 1, 1 } /* r5=scratch, r7=SP, r6=FP */

#define CALL_USED_REGISTERS \
  { 0, 1, 0, 0, 0, 1, 1, 1 } /* per r1 es retorna el resultat */

/* 10.8.2 Order of Allocation of Registers*/

/* 10.8.3 How Values Fit in Registers */

/* Numero de registres que necessita una dada del tipus MODE */
#define HARD_REGNO_NREGS(REGNO, MODE)                             \
   ((GET_MODE_SIZE (MODE) + UNITS_PER_WORD - 1) / UNITS_PER_WORD)

/* Indica si podem guardar una dada del mode MODE en una serie de registres
 * comensant per REGNO (necessitarem tants registres com digui HARD_REGNO_NREGS
 */
#define HARD_REGNO_MODE_OK(REGNO, MODE) 1


/* 1 si es pot accedir a mode1 com a mode2 sense haver de copiar la dada */
#define MODES_TIEABLE_P(MODE1, MODE2) \
    (((MODE1) == (MODE2)) || (GET_MODE_SIZE(MODE1) <= 2 && GET_MODE_SIZE(MODE2) <=2))

/* 10.8.4 Handling Leaf Functions */

/* 10.8.5 Registers That Form a Stack */

/* 10.9 Register Classes */
enum reg_class
{
    NO_REGS,
    GENERAL_REGS,
    ALL_REGS,
    LIM_REG_CLASSES
};
#define N_REG_CLASSES ((int) LIM_REG_CLASSES)


#define REG_CLASS_NAMES    \
{                          \
    "NO_REGS",             \
    "GENERAL_REGS",        \
    "ALL_REGS"             \
}

#define REG_CLASS_CONTENTS \
{                          \
    {0x00},                \
    {0xff},                \
    {0xff}                 \
}

#define REGNO_REG_CLASS(REG) GENERAL_REGS
#define BASE_REG_CLASS GENERAL_REGS
#define INDEX_REG_CLASS NO_REGS

/* A part de "r" no hi ha cap lletra que indiqui registres */
#define REG_CLASS_FROM_LETTER(CHAR) NO_REGS

#define REGNO_OK_FOR_BASE_P(REGNO)  \
((((REGNO) < FIRST_PSEUDO_REGISTER) && ((REGNO) >= 0))  \
|| \
((reg_renumber[REGNO] > 0) && (reg_renumber[REGNO] < FIRST_PSEUDO_REGISTER)))

/* No acceptem adresament indexat */
#define REGNO_OK_FOR_INDEX_P(REG) 0

#define PREFERRED_RELOAD_CLASS(X,CLASS) CLASS

/* Numero maxim de registres consecutius d'una classe que poden contenir una
 * dada del tipus MODE
 */
#define CLASS_MAX_NREGS(CLASS,MODE) \
    ((GET_MODE_SIZE (MODE) + UNITS_PER_WORD - 1) / UNITS_PER_WORD)

#define CONST_OK_FOR_LETTER_P(value,c) const_ok_for_letter_p (value, c)

#define CONST_DOUBLE_OK_FOR_LETTER_P(VALUE, C) 0

#define EXTRA_CONSTRAINT(value,c) extra_constraint (value, c)

/* 10.10 Stack Layout and Calling Conventions */

/* 10.10.1 Basic Stack Layout */

#define STACK_GROWS_DOWNWARD

#define FRAME_GROWS_DOWNWARD

/* Offset entre el frame pointer i la primera variable local */
#define STARTING_FRAME_OFFSET 0

/* Offset entre el argument pointer (frame pointer en SISA) i el primer argument */
#define FIRST_PARM_OFFSET(FNDECL) UNITS_PER_WORD

#define RETURN_ADDR_RTX(COUNT,FRAMEADDR)  \
 (((COUNT) == 0) ? gen_rtx_REG(Pmode,5) : NULL_RTX)

/* 10.10.2 Exception Handling Support */

/* 10.10.3 Specifying How Stack Checking is Done */

/* 10.10.4 Registers That Address the Stack Frame */
#define STACK_POINTER_REGNUM 7

#define FRAME_POINTER_REGNUM 6

#define ARG_POINTER_REGNUM FRAME_POINTER_REGNUM

/* 10.10.5 Eliminating Frame Pointer and Arg Pointer */
#define FRAME_POINTER_REQUIRED 1

#define INITIAL_FRAME_POINTER_OFFSET(VAR) { (VAR)=0; }

/* 10.10.6 Passing Function Arguments on the Stack */

#define PUSH_ARGS 0

#define RETURN_POPS_ARGS(fundecl,funtype,stack_size) 0

/* 10.10.7 Register Arguments */

/* no passem cap parametre per registre */
#define FUNCTION_ARG(cum,mode,type,named) 0

/* Passem per referencia els tipus que no sabem passar per valor per la pila */
/* Passar sols variables de 16 bits per valor
   La resta les passarem per referencia */
#define FUNCTION_ARG_PASS_BY_REFERENCE(CUM,MODE,TYPE,NAMED) (GET_MODE_SIZE(MODE) > GET_MODE_SIZE(HImode))

#define CUMULATIVE_ARGS int

#define INIT_CUMULATIVE_ARGS(cum,fntype,libname,indirect) { (cum) = 0; }

/* Com accedir al seguent parametre t'una funcio si no es passa per la pila
   Nosaltres ho passem tot per la pila, aixi que no ha de fer res
*/
#define FUNCTION_ARG_ADVANCE(cum,mode,type,named) {}

/* tots els parametres es passen per la pila */
#define FUNCTION_ARG_REGNO_P(regno) 0

/* com s'alineen els parametres a funcions*/
#define FUNCTION_ARG_BOUNDARY(MODE, TYPE)         \
(MODE == QImode ? BITS_PER_UNIT : BITS_PER_WORD)

/* 10.10.8 How ScalarFunction Values Are Returned */

/* per on es retornen els resultats de les funcions (r1) */
#define FUNCTION_VALUE(valtype,func) sisa_function_value(valtype,func)

/* per on es retornen els resultats de les funcions
 * de llibreries de compilacio (r1)
 */
#define LIBCALL_VALUE(mode) sisa_lib_value(mode)

/* indica els registres que retornen valors d'una funcio */
#define FUNCTION_VALUE_REGNO_P(regno) ((regno) == 1)

/* 10.10.9 How Large Values Are Returned */

/* retornem per memoria en lloc de per r1 totes aquelles dades de
 * mes de 16 bits
 * Nota: el GET_MODE_SIZE(TYPE_MODE(type)) no funciona!!!
 * S'ha d'usar int_size_in_bytes
 */
#define RETURN_IN_MEMORY(type) (int_size_in_bytes(type) > UNITS_PER_WORD)

/* les funcions que retornen algo no escalar, necessiten que se'ls hi passi
 * per parametre l'adreca d'on han de guardar el resultat en concret
 * Aqui ho passarem per r1
 */
#define STRUCT_VALUE_REGNUM 1

/* 10.10.10 Caller-Saves Register Allocation */

/* 10.10.11 Function Entry and Exit */

/* Adreca de retorn d'una funcio no depen del frame pointer
 */
#define EXIT_IGNORE_STACK 0

/* registres usats en l'epileg. */
#define EPILOGUE_USES(regno) ((regno)==5?1:0)

/* registres usats en excepcions: cap */
#define EH_USES(regno) 0

/* 10.10.12 Profiling */

/* Codi per a cridar una rutina de profile: De moment no fa res */
#define FUNCTION_PROFILER(file,labelno)

/* 10.10.13 Tail Calls */

/* 10.11 Varargs */

/* 10.12 Trampolines */

/* TODO: De moment no tractem trampolins. */
#define TRAMPOLINE_SIZE 0
#define INITIALIZE_TRAMPOLINE(addr,fnaddr,static_chain) abort();

/* 10.13 Library Calls */

#define MULHI3_LIBCALL  "__sisa_mulhi3"
#define UDIVHI3_LIBCALL "__sisa_udivhi3"
#define SDIVHI3_LIBCALL "__sisa_sdivhi3"
#define SMODHI3_LIBCALL "__sisa_smodhi3"
#define UMODHI3_LIBCALL "__sisa_umodhi3"

#define INIT_TARGET_OPTABS \
    smul_optab->handlers[(int) HImode].libfunc = init_one_libfunc (MULHI3_LIBCALL);  \
    umod_optab->handlers[(int) HImode].libfunc = init_one_libfunc (UMODHI3_LIBCALL); \
    smod_optab->handlers[(int) HImode].libfunc = init_one_libfunc (SMODHI3_LIBCALL); \
    udiv_optab->handlers[(int) HImode].libfunc = init_one_libfunc (UDIVHI3_LIBCALL); \
    sdiv_optab->handlers[(int) HImode].libfunc = init_one_libfunc (SDIVHI3_LIBCALL);

/* 10.14 Addressing Modes */

/* Adreca constant valida. CONSTANT_P esta definida per defecte
 * i accepta els casos correctes */
#define CONSTANT_ADDRESS_P(X) CONSTANT_P(X)

/* numero maxim de registres que te una adreca valida */
#define MAX_REGS_PER_ADDRESS 1

#ifdef REG_OK_STRICT
/* Durant el reload no acceptem pseudoregistres */
#define REG_OK_FOR_BASE_P(X) REGNO_OK_FOR_BASE_P(REGNO(X))
#else
/* Accepta qualsevol registre */
#define REG_OK_FOR_BASE_P(X) 1
#endif

#define SIS_BIT_INT(X) (INTVAL(X) >= -32 && INTVAL(X) <= 31)

#define SETZE_BITS(X) (INTVAL(X) >= -32768 && INTVAL(X) <= 65535)

#define LEGITIMATE_ADDRESS_INTEGER_P(X) (GET_CODE(X) == CONST_INT)

#define LEGITIMATE_OFFSET_ADDRESS_P(MODE,X)             \
 ((GET_CODE(X) == PLUS)                                 \
  && (GET_CODE(XEXP(X, 0)) == REG)                      \
  && REG_OK_FOR_BASE_P(XEXP(X, 0))                      \
  && LEGITIMATE_ADDRESS_INTEGER_P(XEXP(X, 1)))

#define LEGITIMATE_REG_ADDRESS_P(MODE,X) 		        \
             (GET_CODE(X) == REG && REG_OK_FOR_BASE_P(X))
/*
 * SISA sols te un mode d'adrecament:
 * registre + 6 bit offset.
 */
#define GO_IF_LEGITIMATE_ADDRESS(MODE,X,ADDR)           \
  if(LEGITIMATE_OFFSET_ADDRESS_P(MODE,X)) goto ADDR;    \
  if(LEGITIMATE_REG_ADDRESS_P(MODE,X)) goto ADDR;

/* no s'accepta l'adrecament indexat */
#define REG_OK_FOR_INDEX_P(X) 0

#define LEGITIMIZE_ADDRESS(X,OLDX,MODE,WIN)

/*
 * Les adreces no depenen del mode de la maquina
 */
#define GO_IF_MODE_DEPENDENT_ADDRESS(addr,label)

/* Considerem que tots els immediats son valids */
#define LEGITIMATE_CONSTANT_P(X) 1

/* 10.15 Condition Code */

/* 10.16 Costs*/

/* El compilador assumeix que el cost d'una operacio
 * senzilla es de 2.
 * Per a operar amb aquestes constants necessitem
 * dues operacions per a carregar la constant mes
 * l'operacio en si.
 * 
 */
#define CONST_COSTS(X, CODE, OUTER_CODE)        \
  case CONST_INT:                               \
    if (SIS_BIT_INT(X) && OUTER_CODE == PLUS)   \
      return (COSTS_N_INSNS(1));                \
  case CONST:                                   \
  case SYMBOL_REF:                              \
  case LABEL_REF:                               \
  case CONST_DOUBLE:                            \
   return COSTS_N_INSNS(2);

/* Accedir a un byte costa igual que accedir a un word
 * El 1 vol dir que es el mateix accedir a un byte que
 * a un word, encara q sembli el contrari
 */
#define SLOW_BYTE_ACCESS 1

/* 10.17 Scheduling */

/* 10.18 Sections */

#define TEXT_SECTION_ASM_OP "\n.code"
#define DATA_SECTION_ASM_OP "\n.data"
#define READONLY_DATA_SECTION_ASM_OP "\n.data"

/* 10.19 PIC*/

/* 10.20 Assembler Format*/
/* 10.20.1 File Framework */

#define ASM_COMMENT_START ";"

/* text introduit abans d'un block asm */
#define ASM_APP_ON "#APP"

/* text introduit despres d'un block asm */
#define ASM_APP_OFF "#NO_APP"

#define OUTPUT_QUOTED_STRING(stream, string) fprintf(stream,"%s",string);
#define TARGET_HAVE_NAMED_SECTIONS false /* es Target Hook */

/* 10.20.2 Data Output */

#define ASM_OUTPUT_ASCII(stream, ptr, len) fprintf(stream,"\t.DB\t'%s'\n",ptr)

/* es C un separador de linia per a l'assemblador? */
#define IS_ASM_LOGICAL_LINE_SEPARATOR(C) ((C) == '\n')

/* 10.20.3 Uninitialized data */

/* com imprimir dades no inicialitzades */
#define ASM_OUTPUT_COMMON(stream, name, size, rounded)  \
    fprintf(stream,"%s:\t.DB %d DUP (?)  ;variable common\n",name,size)

#define ASM_OUTPUT_LOCAL(stream, name, size, rounded)  \
    fprintf(stream,"%s:\t.DB %d DUP (?)  ;variable local\n",name,size)

/* 10.20.4 Label Output */

#define ASM_OUTPUT_LABEL(stream, name) fprintf(stream,"%s:",name)

#define ASM_DECLARE_FUNCTION_NAME(stream,name,decl)      \
{                                                        \
    if (!(strcmp(name,"SisaMain"))) fputs(".main\n",stream); \
    else fprintf(stream,".subr %s\n",name);              \
}

/* Target Hook per a fer una variable global. No aplicable en SISA */
#define TARGET_ASM_GLOBALIZE_LABEL sisa_globalize_label

/* Com mostrar un symbol_ref */
#define ASM_OUTPUT_SYMBOL_REF(stream, sym) fprintf(stream,"%s",sym)

#define ASM_OUTPUT_INTERNAL_LABEL(stream,prefix,num)    \
  fprintf(stream, "%s%d:\n", prefix, num)

#define ASM_GENERATE_INTERNAL_LABEL(string,prefix,num)  \
  sprintf(string, "%s%d",prefix, num)

/* Crea espai i construeix un string amb un nom i un mumero
 * el +11 es per a poder tenir numeros de fins a 10 xifres
 * i sumem 1 per al \0 */
#define ASM_FORMAT_PRIVATE_NAME(OUTPUT, NAME, LABELNO)                  \
( (OUTPUT) = (char *) alloca (strlen ((NAME)) + 11),                    \
  sprintf ((OUTPUT), "%s%d", (NAME), (LABELNO)))

#define ASM_OUTPUT_DEF(stream, name, value) fprintf(stream,"(%d)",value)


/* 10.20.5 Initialization */

/* 10.20.6 Macros for Initialization */

/* 10.20.7 Output of Assembler Instructions */

#define REGISTER_NAMES                                          \
{ "r0" , "r1" , "r2" , "r3" , "r4" , "r5" , "r6" , "r7" }


#define PRINT_OPERAND(stream, x, code) print_operand(stream, x, code)

#define PRINT_OPERAND_ADDRESS(stream, x) print_operand_address(stream, x)

#define ASM_OUTPUT_ADDR_VEC_ELT(stream,value)    \
  fprintf(stream, "\t.DW\tL%d\n", value)

/* 10.20.9 Assembler Commands for Exception Regions */

/* 10.20.10 Assembler Commands for Alignment */

/* Com saltar un n bytes per a tenir una dada alineada */
#define ASM_OUTPUT_SKIP(stream,nbytes) \
  fprintf(stream,"\t.DB %d DUP (0)\n",nbytes)
  
/* Com mostrar alineament de dades: no usem alineamnet */
#define ASM_OUTPUT_ALIGN(stream,power)

/* 10.21 Controlling Debugging Information Format */

/* 10.21.1 Macros Affecting All Debugging Formats */

/* 10.21.2 Specific Options for DBX Output */

/* 10.21.3 Open-Ended Hooks for DBX Format */

/* 10.21.4 File Names in DBX Format */

/* 10.21.5 Macros for SDB and DWARF Output */

/* 10.21.6 Macros for VMS Debug Format */

/* 10.22 Cross Compilation and Floating Point */

/* 10.23 Mode Switching Instructions */

/* 10.24 Defining target-specific uses of __attribute__ */

/* 10.25 Defining coprocessor specifics for MIPS targets */

/* 10.26 Miscellaneous Parameters */

/* Tipus usat en les taules de salts */
#define CASE_VECTOR_MODE HImode
  
/* numero maxim de bytes que es poden moure rapidament amb una sola instruccio */
#define MOVE_MAX 2

/* mode dels punters */
#define Pmode HImode

/* mode de les adreces de funcions */
#define FUNCTION_MODE HImode

/* Indica quan un int de inprec bits es pot convertir de forma segura a un 
   int de outprec bits
 */
#define TRULY_NOOP_TRUNCATION(outprec, inprec) 1


