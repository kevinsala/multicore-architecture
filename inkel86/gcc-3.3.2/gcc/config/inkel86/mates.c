
int __sisa_sdivhi3(int, int);
int __sisa_smodhi3(int, int);
unsigned int __sisa_udivhi3(unsigned int, unsigned int);
unsigned int __sisa_umodhi3(unsigned int, unsigned int);
int __sisa_mulhi3(int, int);
void SisaExit (int);

/* Funcio temporal per al calcul de la divisio de dues
 * dades enteres de 16 bits. Aquesta implementacio es lenta i
 * s'ha de substituir
 */
int __sisa_sdivhi3 (int a, int b)
{
    if (a < 0 && b > 0)
    {
        return - __sisa_udivhi3(-a,b);
    }
    else if (a > 0 && b < 0)
    {
        return - __sisa_udivhi3(a,-b);
    }
    else if (a < 0 && b < 0)
    {
        return __sisa_udivhi3(-a,-b);
    }
    else
    {
        return __sisa_udivhi3(a,b);
    }
}

/* Funcio temporal per al calcul del modul de dues
 * dades enteres de 16 bits. Aquesta implementacio es lenta i
 * s'ha de substituir
 */
int __sisa_smodhi3 (int a, int b)
{
    int c=0;
    int result;
    if (a < 0)
    {
        c=1;
        a=-a;
    }
    if (b < 0)
    {
        b=-b;
    }
    result = __sisa_umodhi3(a,b);
    return (c?-result:result);
}

/* Funcio temporal per al calcul de la divisio de dues
 * dades naturals de 16 bits. Aquesta implementacio es lenta i
 * s'ha de substituir
 */
unsigned int __sisa_udivhi3 (unsigned int a, unsigned int b)
{
    unsigned int q = 0;
    unsigned int c = b;

    if (b == 0)
    {
        SisaExit(-6);
    }

    while (b<=a) q++,b+=c;

    return q;
}

/* Funcio temporal per al calcul del modul de dues
 * dades naturals de 16 bits. Aquesta implementacio es lenta i
 * s'ha de substituir
 */
unsigned int __sisa_umodhi3 (unsigned int a, unsigned int b)
{
    unsigned int c = b;

    if (b == 0)
    {
        SisaExit(-6);
    }

    while (b<=a) b+=c;

    return (a-(b-c));
}

/* Funcio temporal per al calcul de la multiplicacio de dues
 * dades de 16 bits. Aquesta implementacio es lenta i
 * s'ha de substituir
 */
int __sisa_mulhi3 (int f1, int f2)
{
    int tmp = f1;

    if (f1==0 || f2==0) return 0;
    
    while(f2-- != 1) f1+=tmp;

    return f1;
}

