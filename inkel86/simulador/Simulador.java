import java.io.*;
import javax.swing.*;

class Simulador
{
    String liniesCodi [];
    String etiquetes [];
    static final int mida_memoria = 65536;
    static final int num_regs = 8;
    static final int num_regs_io = 64;
    boolean breakPoints [];
    byte memoria [];
    short registres [];
    short registres_entrada [];
    short registres_sortida [];
    int PC;
    boolean simulacioAcabada;
    boolean pausa;
    boolean modeRapid;
    boolean paraBreakPoint;
    int insExec;
    String fitxerActual;
    int midaMem;

    Finestra finestra;
    Pantalla pantalla;

    Simulador (String nom_fitxer)
    {
        liniesCodi = new String [mida_memoria];
        etiquetes = new String [mida_memoria];
        memoria = new byte [mida_memoria];
        registres = new short [num_regs];
        registres_entrada = new short [num_regs_io];
        registres_sortida = new short [num_regs_io];
        breakPoints = new boolean [mida_memoria/2];

        Init(true);
        if (nom_fitxer != null)
        {
            LlegeixFitxer(nom_fitxer);
        }

        finestra = new Finestra(this);
        pantalla = new Pantalla(this);
    }

    void Init(boolean borraBreaks)
    {
        int i;
        for (i = 0; i < num_regs; i++)
        {
            registres[i] = (short)0;
        }
        for (i = 0; i < num_regs_io; i++)
        {
            registres_entrada[i] = (short)0;
            registres_sortida[i] = (short)0;
        }
        for (i = 0; i < mida_memoria; i++)
        {
            memoria[i] = (byte)0;
        }
        if (borraBreaks)
        {
            for (i = 0; i < mida_memoria/2; i++)
            {
                breakPoints[i] = false;
            }
        }
        simulacioAcabada = false;
        pausa = false;
        modeRapid = false;
        insExec = 0;
    }

    void CanviBreakPoint(int posicio)
    {
        breakPoints[posicio] = !breakPoints[posicio];
        finestra.codi.repaint();
    }

    boolean Cicle()
    {
        if (pausa)
        {
            pausa = false;
            return false;
        }
        
        if (paraBreakPoint && breakPoints[PC/2])
        {
            modeRapid=false;
            ActualitzaImatge();
            paraBreakPoint = false;
            return false;
        }
        else
        {
            paraBreakPoint = true;
        }
        
        if (simulacioAcabada)
        {
            modeRapid = false;
            ActualitzaImatge();
            return false;
        }
        Decodificador.InterfaceIns ins = Decodificador.Decodifica(this,PC);
        PC+=2;
        ins.Executa(this);
        insExec++;
        CanviPC(PC);
        return true;
    }

    void Para()
    {
        pausa=true;
        modeRapid=false;
        ActualitzaImatge();
    }

    void ActualitzaImatge()
    {
        finestra.codi.Focus(PC/2,modeRapid);
        int tmp = registres[7] & 0xFFFF;
        finestra.pila.Focus(tmp/2,modeRapid);
        finestra.codi.repaint();
        finestra.dades.repaint();
        finestra.pila.repaint();
        finestra.regsEntrada.repaint();
        finestra.regsSortida.repaint();
        finestra.regs.repaint();
    }

    void Executa(int i)
    {
        modeRapid=true;
        Thread exec = new Thread(new Execucio(this,i));
        exec.start();
    }

    static void Assert (boolean b)
    {
        if (!b)
        {
            System.err.println("Ha petat un assert. Ves a saber on!!");
            System.exit(-1);
        }
    }

    public static void main (String args [])
    {

        new Simulador(args.length > 0 ? args[0] : null);

    }

    void LlegeixFitxer(String nom)
    {
        if (nom != null)
        {
            fitxerActual = nom;
            Init(true);
        }
        else
        {
            nom = fitxerActual;
            Init(false);
        }

        try
        {
            FileInputStream fis = new FileInputStream(nom);

            byte [] midaMemArr = new byte [2];
            byte [] numEntradesArr = new byte [2];
            byte [] liniesCodiArr = new byte [2];
            int numEntrades, numLiniesCodi;
            int i;

            i = fis.read(midaMemArr); Assert (i == 2);
            i = fis.read(numEntradesArr); Assert (i == 2);
            i = fis.read(liniesCodiArr); Assert (i == 2);

            midaMem = DosBytes2Short(midaMemArr);
            numEntrades = DosBytes2Short(numEntradesArr);
            numLiniesCodi = DosBytes2Short(liniesCodiArr);
            for (int j = 0; j < midaMem; j++)
            {
                i = fis.read(); Assert (i != -1);
                memoria[j]=(byte)i;
            }

            for (short j = 0; j < numEntrades; j++)
            {
                CarregaEtiquetes(fis);
            }

            for (short j = 0; j < numLiniesCodi; j++)
            {
                CarregaCodi(fis);
            }
        }
        catch (Exception e)
        {
            System.err.println("Error llegint el fitxer: " + e);
        }
    }

    static int DosBytes2Short(byte array [])
    {
        int v1 = (int) array[0] & 0xFF;
        int v2 = (int) array[1] & 0xFF;
        return ((v2 << 8) + v1);
    }

    void CarregaEtiquetes(FileInputStream fis)
    {
        byte [] b = new byte [1];
        byte [] b2 = new byte [2];
        char [] nom = new char [200];
        int i, j=0;

        try
        {
            i = fis.read(b); Assert(i == 1);
            i = fis.read(b2); Assert(i == 2);
            i = fis.read(); Assert(i != -1);
            nom[j]=(char)i;
            while (i != 0)
            {
                i = fis.read(); Assert(i != -1);
                nom[++j]=(char)i;
            }
        }
        catch (Exception e)
        {
            System.err.println("Error llegint el fitxer: " + e);
        }
        int tipus = b[0] & 0xFF; Assert(tipus >= 1 && tipus <= 6);
        int posicio = DosBytes2Short(b2);
        if (tipus != 1)
        {
            etiquetes[posicio] = new String(nom,0,j);
            if (etiquetes[posicio].equals("main"))
            {
                PC = posicio;
            }
        }
    }
    
    void CarregaCodi(FileInputStream fis)
    {
        byte [] b = new byte [2];
        char [] linia = new char [1000];
        int i, j=0;

        try
        {
            i = fis.read(b); Assert(i == 2);
            i = fis.read(); Assert(i != -1);
            linia[j]=(char)i;
            while (i != 0)
            {
                i = fis.read(); Assert(i != -1);
                linia[++j]=(char)i;
            }
        }
        catch (Exception e)
        {
            System.err.println("Error llegint el fitxer: " + e);
        }
        int posicio = DosBytes2Short(b);
        liniesCodi[posicio] = new String(linia,0,j);
    }

    void CanviRegistre(int numRegistre, short nouValor)
    {
        registres[numRegistre]=nouValor;
        finestra.regs.Canvi(numRegistre,modeRapid);
        if (numRegistre == 7)
        {
            int tmp = nouValor;
            tmp &= 0xFFFF;
            finestra.pila.Focus(tmp/2,modeRapid);
        }
    }
    
    void CanviRegistreEntrada(int numRegistre, short nouValor)
    {
        registres_entrada[numRegistre] = nouValor;
        finestra.regsEntrada.Canvi(numRegistre,modeRapid);
    }
    
    void CanviRegistreSortida(int numRegistre, short nouValor)
    {
        registres_sortida[numRegistre] = nouValor;
        finestra.regsSortida.Canvi(numRegistre,modeRapid);
        switch (numRegistre)
        {
          case 60:
            pantalla.Escriu((int)registres_sortida[61],(int)registres_sortida[62],(char)registres_sortida[63]);
            break;
          case 59:
            CanviRegistreEntrada(59,nouValor);
            break;
          default:
            break;
        }
    }

    void CanviPC(int nouValor)
    {
        nouValor &= 0xFFFF;
        if ((nouValor%2)!=0)
        {
            simulacioAcabada=true;
            JOptionPane.showMessageDialog(finestra, "PC desalienat", "", JOptionPane.PLAIN_MESSAGE);
            PC=PC-2; //Per a mantenir resaltada la instruccio que ha provocat la fallada
            finestra.regs.Canvi(8,modeRapid);
            return;
        }
        PC=nouValor;
        finestra.regs.Canvi(8,modeRapid);
        finestra.codi.Focus(nouValor/2,modeRapid);
        finestra.insExec.setText(Integer.toString(insExec));
        finestra.insExec.repaint();
    }
    void CanviWordMem(int posicio, short nouValor)
    {
        memoria[posicio] = (byte)nouValor;
        memoria[posicio+1] = (byte)(nouValor>>8);
        finestra.codi.Canvi(posicio/2,modeRapid);
        finestra.dades.Canvi(posicio/2,modeRapid);
        finestra.pila.Canvi(posicio/2,modeRapid);
    }
    void CanviByteMem(int posicio, byte nouValor)
    {
        if (posicio < midaMem)
        {
            simulacioAcabada=true;
            JOptionPane.showMessageDialog(finestra, "Modificacio de codi", "", JOptionPane.PLAIN_MESSAGE);
            PC=PC-2; //Per a mantenir resaltada la instruccio que ha provocat la fallada
            finestra.regs.Canvi(8,modeRapid);
            return;
        }
        memoria[posicio] = nouValor;
        finestra.codi.Canvi(posicio/2,modeRapid);
        finestra.dades.Canvi(posicio/2,modeRapid);
        finestra.pila.Canvi(posicio/2,modeRapid);
    }
    void Halt()
    {
        simulacioAcabada=true;
        JOptionPane.showMessageDialog(finestra, "Final Simulacio", "", JOptionPane.PLAIN_MESSAGE);
        PC=PC-2; //Per a mantenir resaltada la instruccio que ha provocat la fallada
    }

    void Error(String s)
    {
        simulacioAcabada=true;
        JOptionPane.showMessageDialog(finestra, s, "", JOptionPane.PLAIN_MESSAGE);
        PC=PC-2; //Per a mantenir resaltada la instruccio que ha provocat la fallada
    }
}


class Execucio implements Runnable
{
    Simulador simulador;
    int numIns;

    public void run ()
    {
        if (numIns == 0) return;
    
        if (numIns == -1)
        {
            while (simulador.Cicle());
            return;
        }

        while (simulador.Cicle())
        {
            if (--numIns == 0)
            {
                simulador.Para();
            }
        }
    }

    Execucio (Simulador sim, int n)
    {
        simulador = sim;
        numIns = n;
    }
}
