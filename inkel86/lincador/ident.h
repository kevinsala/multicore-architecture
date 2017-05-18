#include <string>
#include <string.h>

using namespace::std;

extern int liniaActual;
extern const char * fitxerActual;

class IDENTIFICADOR
{
  public:
    string idStr;
    int linia;
    bool definit;
    string fitxer;

    IDENTIFICADOR(const char * str, bool def)
    : idStr(str),
      linia(liniaActual),
      definit(def),
      fitxer(fitxerActual)
    {}

    IDENTIFICADOR(const char * str, const char * modul)
    : idStr(str),
      fitxer(modul)
    {}


};

typedef class IDENTIFICADOR * ID_PTR;

