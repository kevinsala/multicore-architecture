void sisa_override_options PARAMS ((void));

#ifdef RTX_CODE
void print_operand PARAMS ((FILE *, rtx, int));
void print_operand_address PARAMS ((FILE *, rtx));
void generar_salt PARAMS ((enum rtx_code, rtx));
int extra_constraint PARAMS ((rtx, char));
rtx sisa_function_value PARAMS ((tree, tree));
rtx sisa_lib_value PARAMS ((enum machine_mode));
bool sisa_target_asm_integer PARAMS ((rtx, unsigned int, int));
void emit_sisa_lshrhi3 PARAMS ((rtx, rtx, rtx));
void emit_sisa_ashrhi3 PARAMS ((rtx, rtx, rtx));
void emit_sisa_ashlhi3 PARAMS ((rtx, rtx, rtx));
#endif

void sisa_function_prologue PARAMS ((FILE *, HOST_WIDE_INT));
void sisa_function_epilogue PARAMS ((FILE *, HOST_WIDE_INT));
int const_ok_for_letter_p PARAMS ((int, char));
void sisa_globalize_label PARAMS ((FILE *, const char *));

