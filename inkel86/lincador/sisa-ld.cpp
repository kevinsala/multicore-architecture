#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <sstream>
#include <unistd.h>
#include <assert.h>
#include "sisa-ld.h"

TAULA  simbols;
LLISTA llistaFitxers;
LLISTA llistaLlibreries;
LLISTA llistaPaths;
DEFS   dadesLib;
DEFS   rutinesLib;
int liniaActual;
bool lincant=false, parsing=false, enLlibreria=false, ferEcho=true;
const char * fitxerActual;
char fitxerSortida [200];
int modLink=0;
bool substitucio;

void yyerror(char *s)
{
    fprintf(stderr,"Error en linia %d del fitxer %s: %s\n",liniaActual,fitxerActual,s);
    exit(-1);
}

int main( int argc, char *argv[] )
{
    setbuf(stdout,NULL);
    setbuf(stderr,NULL);
    int i;

    for (i=1; i<argc; i++)
    {
        if (!strcmp("-sisa-asm",argv[i]))
        {
            parsing=1;
        }
        else if (!strcmp("-sisa-ld",argv[i]))
        {
            lincant=1;
            string * s = new string("sisalib.a");
            llistaLlibreries.insert(*s);
        }
        else if (!strcmp("-o",argv[i]) && i<argc-1)
        {
            ObreFitxer(&yyout,argv[++i],"w+");
            assert(strlen(argv[i]) < 200);
            strcpy(fitxerSortida,argv[i]);
        }
        else if (!strcmp("-lgcc",argv[i]))
        {
            llistaLlibreries.insert("libgcc.a");
        }
        else if (!strncmp(argv[i],"-L",2) && argv[i][2])
        {
            //Afegir llibreria al path
            llistaPaths.insert(argv[i]+2);
        }
        else if (argv[i][0] == '-')
        {
            fprintf(stderr,"Parametre desconegut: %s\n",argv[i]);
            exit(-1);
        }
        else
        {
            llistaFitxers.insert(argv[i]);
        }
    }

    if (!yyout && lincant)
    {
        ObreFitxer(&yyout,"a.out","w+");
        strcpy(fitxerSortida,"a.out");
    }

    if (yyout)
    {
        if (parsing)
        {
            Assembla();
        }
        else if (lincant)
        {
            Linca();
            Final();
        }
        else
        {
            fputs("Que faig, linco o assemblo?\n",stderr);
            exit(-1);
        }
        fclose(yyout);
        Neteja();
        exit(0);
    }
    else
    {
        fputs("Falta arxiu desti\n",stderr);
        exit(-1);
    }
}

void Final()
{
    ostringstream os;
    os << "asm " << fitxerSortida;

    system(os.str().c_str());
}


ostringstream * NovaEtiqueta(const char * nom)
{
    string s(nom);
    TAULA::iterator i = simbols.find(s);
    if (lincant && !enLlibreria)
    {
        if (i != simbols.end())
        {
            if ((*i).second->definit)
            {
                fprintf(stderr,
                    "Error en linia %d del fitxer %s: Re-definicio del simbol %s, "
                    "pre-definit en la linia %d del fitxer %s\n",
                    liniaActual,fitxerActual,nom,(*i).second->linia,(*i).second->fitxer.c_str());
                exit(-1);
            }
            else
            {
                (*i).second->definit=true;
            }
        }
        else
        {
            simbols[s] = new IDENTIFICADOR(nom,true);
        }
    }
    else if (enLlibreria)
    {
        ostringstream * tmp = new ostringstream();
        *tmp << "sisaLink" << modLink << nom;
        return tmp;
    }
    return NULL;
}

void NovaRutina(const char * nom, ostringstream * os)
{
    string s(nom);
    if (lincant && !enLlibreria)
    {
        TAULA::iterator i = simbols.find(s);
        if (i != simbols.end())
        {
            if ((*i).second->definit)
            {
                fprintf(stderr,
                    "Error en linia %d del fitxer %s: Re-definicio del simbol %s, "
                    "pre-definit en la linia %d del fitxer %s\n",
                    liniaActual,fitxerActual,nom,(*i).second->linia,(*i).second->fitxer.c_str());
                exit(-1);
            }
            else
            {
                (*i).second->definit=true;
            }
        }
        else
        {
            simbols[s] = new IDENTIFICADOR(nom,true);
        }
    }
    else if (enLlibreria)
    {
        ostringstream * tmp = new ostringstream;
        *tmp << ".subr " << nom << endl << os->str() << endl;
        delete os;
        rutinesLib[s] = tmp;
        modLink++;
    }
}

void NovaVariable(const char * nom, ostringstream * os)
{
    string s(nom);
    TAULA::iterator i = simbols.find(s);
    if (lincant && !enLlibreria)
    {
        if (i != simbols.end())
        {
            if ((*i).second->definit)
            {
                fprintf(stderr,
                    "Error en linia %d del fitxer %s: Re-definicio del simbol %s, "
                    "pre-definit en la linia %d del fitxer %s\n",
                    liniaActual,fitxerActual,nom,(*i).second->linia,(*i).second->fitxer.c_str());
                exit(-1);
            }
            else
            {
                (*i).second->definit=true;
            }
        }
        else
        {
            simbols[s] = new IDENTIFICADOR(nom,true);
        }
    }
    else if (enLlibreria)
    {
        ostringstream * tmp = new ostringstream();
        *tmp << nom << ":" << os->str() << endl;
        delete os;
        dadesLib[s] = tmp;
    }
}

ostringstream * UsIdentificador (const char * nom)
{
    if (enLlibreria)
    {
        ostringstream * tmp;
        tmp = new ostringstream();
        if (nom[0] == 'L')
        {
            *tmp << "sisaLink" << modLink << nom;
        }
        else
        {
            *tmp << nom;
        }
        return tmp;
    }
    else
    {
        string s(nom);
        TAULA::iterator i = simbols.find(s);
        if (lincant && i == simbols.end())
        {
            simbols[s] = new IDENTIFICADOR(nom,false);
        }
    }
    return NULL;
}


void Linca(void)
{
    LLISTA::iterator i = llistaFitxers.begin();

    for (;i != llistaFitxers.end(); ++i)
    {
        ObreFitxer(&yyin,(*i).c_str(),"r");
        liniaActual=1;
        fitxerActual=(*i).c_str();
        yyparse();
        fclose(yyin);
    }

    if (!MostraSimbols())
    {
        ProcessaLlibreries();
        yyin=yyout;
    }
    else
    {
        return;
    }

    enLlibreria=false;
    bool canvis=true;
    while (!MostraSimbols() && canvis)
    {
        //Buscar rutines no definides
        DEFS::iterator j = rutinesLib.find(PrimerSimbolNoDefinit());
        canvis=false;
        if (j != rutinesLib.end())
        {
            fwrite((*j).second->str().c_str(),strlen((*j).second->str().c_str()),1,yyout);
            canvis=true;
        }

        //Busca dades no definides
        if (!canvis)
        {
            j = dadesLib.find(PrimerSimbolNoDefinit());
            if (j != dadesLib.end())
            {
                fwrite((*j).second->str().c_str(),strlen((*j).second->str().c_str()),1,yyout);
                canvis=true;
            }
        }

        rewind(yyin);
        NetejaTaula(&simbols);
        yyparse();
    }

    if (!canvis)
    {
        fprintf(stderr,"Falta la definicio del seguent simbol: %s\n",(PrimerSimbolNoDefinit().c_str()));
        exit(-1);
    }
}


void ProcessaLlibreries(void)
{
    LLISTA::iterator i = llistaLlibreries.begin();

    for (;i != llistaLlibreries.end(); ++i)
    {
        LLISTA::iterator j = llistaPaths.begin();
        for (;j != llistaPaths.end(); ++j)
        {
            ostringstream os;
            os << (*j) << "/" << (*i);
            if (ObreFitxer(&yyin,os.str().c_str(),"r",true))
            {
                liniaActual=1;
                fitxerActual=(*i).c_str();
                enLlibreria=true;
                ferEcho=false;
                yyparse();
                fclose(yyin);
                break;
            }
        }
        if (j == llistaPaths.end())
        {
            fprintf(stderr,"No s'ha trobat la seguent llibreria: %s\n",(*i).c_str());
            exit(-1);
        }
    }
}


void Assembla(void)
{
    if (llistaFitxers.size() != 1)
    {
        fprintf(stderr,"Sols se ensamblar un fitxer a la vegada, me'n fas ensamblar %d\n",llistaFitxers.size());
        exit(-1);
    }
    ObreFitxer(&yyin,(*llistaFitxers.begin()).c_str(),"r");
    liniaActual=1;
    fitxerActual=(*llistaFitxers.begin()).c_str();
    yyparse();
    fclose(yyin);
}

bool ObreFitxer(FILE ** f,const char * nom, const char * mode, bool prova)
{
    *f = fopen(nom,mode);
    if (*f == NULL)
    {
        if (prova)
        {
            return false;
        }
        else
        {
            fprintf(stderr,"Error en obrir l'arxiu d'entrada %s: ",nom);
            perror("");
            exit(-1);
        }
    }
    return true;
}

bool MostraSimbols(void)
{
    TAULA::iterator i = simbols.begin();
    bool ok=true;

    for (;i != simbols.end(); ++i)
    {
        ok = ok && (*i).second->definit;
    }

    return ok;
}


void NetejaTaula(TAULA * t)
{
    TAULA::iterator i = t->begin();
    for (; i != t->end(); ++i)
    {
        delete (*i).second;
    }
    t->clear();
}


void Neteja (void)
{
    llistaFitxers.clear();
    llistaLlibreries.clear();
    llistaPaths.clear();

    NetejaTaula(&simbols);

    DEFS::iterator j = dadesLib.begin();
    for (;j != dadesLib.end(); ++j)
    {
        delete (*j).second;
    }
    dadesLib.clear();

    DEFS::iterator i = rutinesLib.begin();
    for (;i != rutinesLib.end(); ++i)
    {
        delete (*i).second;
    }
    rutinesLib.clear();
}

ostringstream * Concat (
    const char * pre, ostringstream * o1, const char * s1, ostringstream * o2, const char * s2,
    ostringstream * o3, const char * s3, ostringstream * o4, const char * s4,
    ostringstream * o5, const char * s5, ostringstream * o6, const char * s6)
{
    if (enLlibreria)
    {
        ostringstream * tmp = new ostringstream();

        if (o1)
        {
            *tmp << pre << o1->str() << s1;
            delete o1;
        }
        if (o2)
        {
            *tmp << o2->str() << s2;
            delete o2;
        }
        if (o3)
        {
            *tmp << o3->str() << s3;
            delete o3;
        }
        if (o4)
        {
            *tmp << o4->str() << s4;
            delete o4;
        }
        if (o5)
        {
            *tmp << o5->str() << s5;
            delete o5;
        }
        if (o6)
        {
            *tmp << o6->str() << s6;
            delete o6;
        }
        return tmp;
    }
    return NULL;
}

ostringstream * Concat (
    const char * pre, const char * o1, const char * s1 = "", const char * o2 = NULL, const char * s2 = "",
    const char * o3 = NULL, const char * s3 = "", const char * o4 = NULL, const char * s4 = "",
    const char * o5 = NULL, const char * s5 = "", const char * o6 = NULL, const char * s6 = "")
{
    if (enLlibreria)
    {
        ostringstream * tmp = new ostringstream();
        *tmp << pre << o1 << s1;

        if (o2)
        {
            *tmp << o2 << s2;
        }
        if (o3)
        {
            *tmp << o3 << s3;
        }
        if (o4)
        {
            *tmp << o4 << s4;
        }
        if (o5)
        {
            *tmp << o5 << s5;
        }
        if (o6)
        {
            *tmp << o6 << s6;
        }
        return tmp;
    }
    return NULL;
}

ostringstream * Concat (
    const char * pre, const char * o1, const char * s1, const char * o2, const char * s2,
    const char * o3, const char * s3, ostringstream * o4, const char * s4)
{
    if (enLlibreria)
    {
        ostringstream * tmp = new ostringstream();
        *tmp << pre << o1 << s1;

        if (o2)
        {
            *tmp << o2 << s2;
        }
        if (o3)
        {
            *tmp << o3 << s3;
        }
        if (o4)
        {
            *tmp << o4->str() << s4;
            delete o4;
        }
        return tmp;
    }
    return NULL;
}

ostringstream * Concat (
    const char * pre, const char * o1, const char * s1, ostringstream * o2, const char * s2,
    const char * o3, const char * s3, const char * o4, const char * s4)
{
    if (enLlibreria)
    {
        ostringstream * tmp = new ostringstream();
        *tmp << pre << o1 << s1;

        if (o2)
        {
            *tmp << o2->str() << s2;
            delete o2;
        }
        if (o3)
        {
            *tmp << o3 << s3;
        }
        if (o4)
        {
            *tmp << o4 << s4;
        }
        return tmp;
    }
    return NULL;
}

ostringstream * Concat (
    const char * pre, ostringstream * o1, const char * s1, const char * o2, const char * s2,
    const char * o3 = NULL, const char * s3 = "", const char * o4 = NULL, const char * s4 =NULL)
{
    if (enLlibreria)
    {
        ostringstream * tmp = new ostringstream();
        if (o1)
        {
            *tmp << pre << o1->str() << s1;
            delete o1;
        }

        if (o2)
        {
            *tmp << o2 << s2;
        }
        if (o3)
        {
            *tmp << o3 << s3;
        }
        if (o4)
        {
            *tmp << o4 << s4;
        }
        return tmp;
    }
    return NULL;
}



string PrimerSimbolNoDefinit(void)
{
    TAULA::iterator i = simbols.begin();

    for (;i != simbols.end(); ++i)
    {
        if (!(*i).second->definit)
        {
            return (*i).first;
        }
    }

    assert(false);
    return NULL;
}

