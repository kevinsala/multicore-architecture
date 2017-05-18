#include <map>
#include <set>
#include "ident.h"


using namespace std;
typedef class map<string, ID_PTR> TAULA;
typedef class set<string> LLISTA;
typedef class map<string, ostringstream *> DEFS;

extern int yyparse();
extern FILE * yyin, * yyout;

void Assembla(void);
void Linca(void);
void Final(void);
bool MostraSimbols(void);
bool ObreFitxer(FILE **,const char *, const char *, bool = false);
void Neteja(void);
void ProcessaLlibreries(void);
string PrimerSimbolNoDefinit(void);
void NetejaTaula(TAULA *);
