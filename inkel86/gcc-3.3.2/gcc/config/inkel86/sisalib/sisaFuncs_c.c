#include "sisalib.h"

void SisaOut(int, int);
int SisaIn(int);
void SisaHalt(void);
void EscriureChar(int, int, char);

void SisaExit (int value)
{
    SisaOut(63,value);
    SisaHalt();
}

int fila=0;
int columna=0;

void EscriureUnsignedInt(unsigned int numero)
{
    int i, primers_zeros=1;
    char tmp [5];
    for (i=0;i<5;i++)
    {
        tmp[4-i]=(char)(numero%10+'0');
        numero/=10;
    }

    for (i=0;i<5;i++)
    {
        if (tmp[i] == '0')
        {
            if (primers_zeros) continue;
            EscriureChar(fila,columna++,tmp[i]);
        }
        else
        {
            primers_zeros=0;
            EscriureChar(fila,columna++,tmp[i]);
        }
    }
    if (primers_zeros)
    {
        EscriureChar(fila,columna++,'0');
    }
}

void EscriureUnsignedLong(unsigned long numero)
{
    int i, primers_zeros=1;
    char tmp [10];
    for (i=0;i<10;i++)
    {
        tmp[9-i]=(char)(numero%10+'0');
        numero/=10;
    }

    for (i=0;i<10;i++)
    {
        if (tmp[i] == '0')
        {
            if (primers_zeros) continue;
            EscriureChar(fila,columna++,tmp[i]);
        }
        else
        {
            primers_zeros=0;
            EscriureChar(fila,columna++,tmp[i]);
        }
    }
    if (primers_zeros)
    {
        EscriureChar(fila,columna++,'0');
    }
}

void EscriureInt(int numero)
{
    int i, neg=0, primers_zeros=1;
    char tmp [5];
    
    if (numero<0)
    {
        numero=-numero;
        neg=1;
    }
    
    for (i=0;i<5;i++)
    {
        tmp[4-i]=(char)(numero%10+'0');
        numero/=10;
    }

    if (neg)
    {
        EscriureChar(fila,columna++,'-');
    }
    for (i=0;i<5;i++)
    {
        if (tmp[i] == '0')
        {
            if (primers_zeros) continue;
            EscriureChar(fila,columna++,tmp[i]);
        }
        else
        {
            primers_zeros=0;
            EscriureChar(fila,columna++,tmp[i]);
        }
        
    }
    if (primers_zeros)
    {
        EscriureChar(fila,columna++,'0');
    }
}

void EscriureLong(long numero)
{
    int i, neg=0, primers_zeros=1;
    char tmp [10];
    
    if (numero<0)
    {
        numero=-numero;
        neg=1;
    }
    
    for (i=0;i<10;i++)
    {
        tmp[9-i]=(char)(numero%10+'0');
        numero/=10;
    }

    if (neg)
    {
        EscriureChar(fila,columna++,'-');
    }
    for (i=0;i<10;i++)
    {
        if (tmp[i] == '0')
        {
            if (primers_zeros) continue;
            EscriureChar(fila,columna++,tmp[i]);
        }
        else
        {
            primers_zeros=0;
            EscriureChar(fila,columna++,tmp[i]);
        }
    }
    if (primers_zeros)
    {
        EscriureChar(fila,columna++,'0');
    }
}

void SaltLinia()
{
    fila++;
    columna=0;
}

void EscriureChar(int fila, int columna, char c)
{
    SisaOut(61,fila);
    SisaOut(62,columna);
    SisaOut(63,(int)c);
    SisaOut(60,1);
}

unsigned int GetUnsignedInt()
{
    char tmp [6] = {0,0,0,0,0,0};
    int key, pos = 0, i;
    unsigned int result=0;

    EscriureChar(fila,columna,'_');

    while (SisaIn(59) == 0);
    key = SisaIn(58);
    SisaOut(59,0);
    EscriureChar(fila,columna++,(char)key);
    EscriureChar(fila,columna,'_');

    while (key != 10)
    {
        tmp[pos++]=(char)key;
        while (SisaIn(59) == 0);
        key = SisaIn(58);
        SisaOut(59,0);
        EscriureChar(fila,columna++,(char)key);
        EscriureChar(fila,columna,'_');
    }
    EscriureChar(fila,columna,' ');

    i=0;
    while (tmp[i])
    {
        result=tmp[i++]-'0'+result*10;
    }
    return result;
}

unsigned long GetUnsignedLong()
{
    char tmp [11] = {0,0,0,0,0,0,0,0,0,0,0};
    int key, pos = 0, i;
    unsigned long result=0;

    EscriureChar(fila,columna,'_');

    while (SisaIn(59) == 0);
    key = SisaIn(58);
    SisaOut(59,0);
    EscriureChar(fila,columna++,(char)key);
    EscriureChar(fila,columna,'_');

    while (key != 10)
    {
        tmp[pos++]=(char)key;
        while (SisaIn(59) == 0);
        key = SisaIn(58);
        SisaOut(59,0);
        EscriureChar(fila,columna++,(char)key);
        EscriureChar(fila,columna,'_');
    }
    EscriureChar(fila,columna,' ');

    i=0;
    while (tmp[i])
    {
        result=tmp[i++]-'0'+result*10;
    }
    return result;
}

int GetInt()
{
    char tmp [6] = {0,0,0,0,0,0};
    int key, pos = 0, i, neg=0;
    int result=0;

    EscriureChar(fila,columna,'_');

    while (SisaIn(59) == 0);
    key = SisaIn(58);
    SisaOut(59,0);
    EscriureChar(fila,columna++,(char)key);
    EscriureChar(fila,columna,'_');
    if (key == (int)'-')
    {
        neg=1;
    }
    else
    {
        tmp[pos++]=(char)key;
    }

    for (;;)
    {
        while (SisaIn(59) == 0);
        key = SisaIn(58);
        SisaOut(59,0);
        if (key == 10) break;
        EscriureChar(fila,columna++,(char)key);
        EscriureChar(fila,columna,'_');
        tmp[pos++]=(char)key;
    }
    EscriureChar(fila,columna,' ');

    i=0;
    while (tmp[i])
    {
        result=tmp[i++]-'0'+result*10;
    }
    return (neg?-result:result);
}

long GetLong()
{
    char tmp [11] = {0,0,0,0,0,0,0,0,0,0,0};
    int key, pos = 0, i, neg=0;
    long result=0;

    EscriureChar(fila,columna,'_');

    while (SisaIn(59) == 0);
    key = SisaIn(58);
    SisaOut(59,0);
    EscriureChar(fila,columna++,(char)key);
    EscriureChar(fila,columna,'_');
    if (key == (int)'-')
    {
        neg=1;
    }
    else
    {
        tmp[pos++]=(char)key;
    }

    for (;;)
    {
        while (SisaIn(59) == 0);
        key = SisaIn(58);
        SisaOut(59,0);
        if (key == 10) break;
        EscriureChar(fila,columna++,(char)key);
        EscriureChar(fila,columna,'_');
        tmp[pos++]=(char)key;
    }
    EscriureChar(fila,columna,' ');

    i=0;
    while (tmp[i])
    {
        result=tmp[i++]-'0'+result*10;
    }
    return (neg?-result:result);
}

char GetCaracter()
{
    int key;
    EscriureChar(fila,columna,'_');

    while (SisaIn(59) == 0);
    key = SisaIn(58);
    SisaOut(59,0);
    EscriureChar(fila,columna++,(char)key);
    EscriureChar(fila,columna,' ');

    return (char)key;
}

void EscriureCaracter(char c)
{
    EscriureChar(fila,columna++,c);
}


void EscriureFloat(float f, unsigned int num_decimals)
{
    unsigned int i;
    char tmp [10];
    float m1;
    long m, n;
    /* Aixo esta aqui dintre perque el ensamblador no ho suporta fora */
    float multiples_deu [7] = {
        10.0, 100.0, 1000.0, 10000.0,
        100000.0, 1000000.0, 10000000.0
    };

    m=(long)f;

    m1=(float)m;

    m1 = ((m>0) ? (f-m1) : (m1-f)) * multiples_deu[num_decimals-1];

    n = (long) m1;
    for (i=0;i<num_decimals;i++)
    {
        tmp[num_decimals-1-i]=(char)(n%10+'0');
        n/=10;
    }
    EscriureLong(m);
    EscriureCaracter('.');
    for (i=0;i<num_decimals;i++)
    {
        EscriureChar(fila,columna++,tmp[i]);
    }
}

float GetFloat()
{
    char tmp [11] = {0,0,0,0,0,0,0,0,0,0,0};
    char tmp2 [11] = {0,0,0,0};
    int key, pos = 0, i, neg=0;
    long result=0;
    float enter, decimal;
    /* Aixo esta aqui dintre perque el ensamblador no ho suporta fora */
    float multiples_deu [7] = {
        10.0, 100.0, 1000.0, 10000.0,
        10000.0, 1000000.0, 10000000.0
    };

    EscriureChar(fila,columna,'_');

    while (SisaIn(59) == 0);
    key = SisaIn(58);
    SisaOut(59,0);
    EscriureChar(fila,columna++,(char)key);
    EscriureChar(fila,columna,'_');
    if (key == (int)'-')
    {
        neg=1;
    }
    else
    {
        tmp[pos++]=(char)key;
    }

    for (;;)
    {
        while (SisaIn(59) == 0);
        key = SisaIn(58);
        SisaOut(59,0);
        if (key == '.') break;
        EscriureChar(fila,columna++,(char)key);
        EscriureChar(fila,columna,'_');
        tmp[pos++]=(char)key;
    }
    EscriureChar(fila,columna++,(char)key);
    EscriureChar(fila,columna,'_');
    pos=0;
    for (;;)
    {
        while (SisaIn(59) == 0);
        key = SisaIn(58);
        SisaOut(59,0);
        if (key == 10) break;
        EscriureChar(fila,columna++,(char)key);
        EscriureChar(fila,columna,'_');
        tmp2[pos++]=(char)key;
    }
    EscriureChar(fila,columna,' ');

    i=0;
    while (tmp[i])
    {
        result=tmp[i++]-'0'+result*10;
    }
    enter = (float)(neg?-result:result);
    i=0;
    result=0;
    while (tmp2[i])
    {
        result=tmp2[i++]-'0'+result*10;
    }
    decimal = (float)result;

    return (neg?-decimal:decimal)/multiples_deu[pos-1]+enter;

}
