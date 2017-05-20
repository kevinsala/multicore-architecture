void inkel86_override_options PARAMS ((void));

#ifdef RTX_CODE
void print_operand PARAMS ((FILE *, rtx, int));
void print_operand_address PARAMS ((FILE *, rtx));
void generar_salt PARAMS ((enum rtx_code, rtx));
int extra_constraint PARAMS ((rtx, char));
rtx inkel86_function_value PARAMS ((tree, tree));
rtx inkel86_lib_value PARAMS ((enum machine_mode));
bool inkel86_target_asm_integer PARAMS ((rtx, unsigned int, int));
void emit_inkel86_lshrhi3 PARAMS ((rtx, rtx, rtx));
void emit_inkel86_ashrhi3 PARAMS ((rtx, rtx, rtx));
void emit_inkel86_ashlhi3 PARAMS ((rtx, rtx, rtx));
#endif

void inkel86_function_prologue PARAMS ((FILE *, HOST_WIDE_INT));
void inkel86_function_epilogue PARAMS ((FILE *, HOST_WIDE_INT));
int const_ok_for_letter_p PARAMS ((int, char));
void inkel86_globalize_label PARAMS ((FILE *, const char *));

