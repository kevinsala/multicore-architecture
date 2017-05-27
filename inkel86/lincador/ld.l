%{
#include <string.h>
#include <assert.h>
#include "defi.h"
#include "ld.tab.hpp"

#define SISA_ECHO                                             \
{                                                             \
  if (strlen(yylval.text) >= MAX_STRING_LENGTH)               \
  {                                                           \
     fprintf(stderr,"Simbol massa llarg: %s\n",yylval.text);  \
     exit(-1);                                                \
  }                                                           \
  strcpy(yylval.text,yytext);                                 \
  if (ferEcho) ECHO;                                          \
}
%}


%option noyywrap

digit                                   [0-9]
lletra                                  [a-zA-Z_]
llsimb                                  [a-zA-Z_\.\-]


%%

"."code                                 {SISA_ECHO; return(CODE);}
"."data                                 {SISA_ECHO; return(DATA);}
"."subr                                 {SISA_ECHO; return(SUBR);}
"."main                                 {SISA_ECHO; return(MAIN);}
"."d[bwdl]                              {SISA_ECHO; return(DEFINE);}

","                                     {SISA_ECHO; return(COMA);}
"`"                                     {SISA_ECHO; return(APOSTROF);}
"?"                                     {SISA_ECHO; return(INTERROGANT);}

r[0-9]+                                 {SISA_ECHO; return(REG);}

addi                                    {SISA_ECHO; return(ADDI);}
add                                     {SISA_ECHO; return(OP3REGS);}
sub                                     {SISA_ECHO; return(OP3REGS);}
srl                                     {SISA_ECHO; return(OP2REGS);}
sra                                     {SISA_ECHO; return(OP2REGS);}
and                                     {SISA_ECHO; return(OP3REGS);}
(x)?or                                  {SISA_ECHO; return(OP3REGS);}
not                                     {SISA_ECHO; return(OP2REGS);}
cmp(lt|le|gt|ge)(u)?                    {SISA_ECHO; return(OP3REGS);}
beq                                     {SISA_ECHO; return(BRANCH);}
bne                                     {SISA_ECHO; return(BRANCH);}
br                                      {SISA_ECHO; return(BRANCH_IN);}
jalr                                    {SISA_ECHO; return(OP2REGS);}
jmp                                     {SISA_ECHO; return(OP1REGS);}
j(eq|ne)                                {SISA_ECHO; return(OP2REGS);}
dup                                     {SISA_ECHO; return(DUP);}
halt                                    {SISA_ECHO; return(HALT);}
in                                      {SISA_ECHO; return(IN);}
out                                     {SISA_ECHO; return(OUT);}

ld(b|w)                                 {SISA_ECHO; return(LOAD);}
st(b|w)                                 {SISA_ECHO; return(STORE);}
m[hl]i                                  {SISA_ECHO; return(MOVE);}


"("                                     {SISA_ECHO; return(PAR_ESQ);}
")"                                     {SISA_ECHO; return(PAR_DRET);}
"&"                                     {SISA_ECHO; return(AND);}
">>"                                    {SISA_ECHO; return(SHIFT);}
"+"                                     {SISA_ECHO; return(SUMA);}
"/"                                     {SISA_ECHO; return(BARRA);}

":"                                     {SISA_ECHO; return(DOSPUNTS);}

{lletra}({digit}|{lletra})*             {SISA_ECHO; return(IDENTIFICADOR);}
{lletra}({digit}|{llsimb})*             {SISA_ECHO; return(NOM_FITXER);}
("-"?){digit}+                          {SISA_ECHO; return(CONST_INT);}

\'([^\'])*\'                            {SISA_ECHO; return(STRING);}

[ \t]+                                  {SISA_ECHO;}
"\n"                                    {SISA_ECHO; liniaActual++;}

";".*$                                  {SISA_ECHO; /* es un comentari */}

.                                       {fprintf(stderr,
                                            "Error lexic en  el caracter: %c en linia %d del fitxer %s\n",
                                            *yytext,liniaActual,fitxerActual);
                                         exit(-1);}

"!<arch>"                               {SISA_ECHO; return(AR_HEADER);}
"//".*$                                 {SISA_ECHO; return(AR_HEADER2);}

%%

