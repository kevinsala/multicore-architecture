
class Decodificador
{
    static final int taula [] =
    {
          0x1,    0x3,    0x7,    0xF,
         0x1F,   0x3F,   0x7F,   0xFF,
        0x1FF,  0x3FF,  0x7FF,  0xFFF,
       0x1FFF, 0x3FFF, 0x7FFF, 0xFFFF
    };
        
    static int Bits(int val, int ini, int num)
    {

        Simulador.Assert(val >= 0 && val < 65536);
        Simulador.Assert(ini >= 0 && ini < 16);
        Simulador.Assert(num >= 1);
        Simulador.Assert((ini + num) <= 16);

        int tmp = val >> ini;
        return tmp & taula[num-1];
    }


    static InterfaceIns Decodifica (Simulador simulador, int posicio)
    {
        Simulador.Assert((posicio%2)==0);

        byte b [] = new byte [2];
        int valor;

        b[0]=simulador.memoria[posicio];
        b[1]=simulador.memoria[posicio+1];

        valor = Simulador.DosBytes2Short(b);
        switch (Bits(valor,12,4))
        {
          case Constants.ARITMETIC:
            return DecodificaAritmetic(valor);
          case Constants.COMPARACIONS:
            return DecodificaComparacions(valor);
          case Constants.IN:
            return new In(Bits(valor,9,3),Bits(valor,0,6));
          case Constants.OUT:
            return new Out(Bits(valor,0,6),Bits(valor,6,3));
          case Constants.LDW:
            return new LdW(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,6));
          case Constants.STW:
            return new StW(Bits(valor,0,6),Bits(valor,6,3),Bits(valor,9,3));
          case Constants.SALTS:
            return DecodificaSalts(valor);
          case Constants.ADDI:
            return new AddI(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,6));
          case Constants.MLI:
            return new Mli(Bits(valor,9,3),Bits(valor,0,8));
          case Constants.MHI:
            return new Mhi(Bits(valor,9,3),Bits(valor,0,8));
          case Constants.LDB:
            return new LdB(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,6));
          case Constants.STB:
            return new StB(Bits(valor,0,6),Bits(valor,6,3),Bits(valor,9,3));
          case Constants.HALT:
            if (Bits(valor,0,12) == 0)
            {
                return new Halt();
            }
            else
            {
                return new Invalida();
            }
          default:
            return new Invalida();
        }
    }

    static InterfaceIns DecodificaAritmetic(int valor)
    {
        switch (Bits(valor,3,3))
        {
          case Constants.ADD:
            return new Add(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,3));
          case Constants.SUB:
            return new Sub(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,3));
          case Constants.SRA:
            return new Sra(Bits(valor,9,3),Bits(valor,6,3));
          case Constants.SRL:
            return new Srl(Bits(valor,9,3),Bits(valor,6,3));
          case Constants.AND:
            return new And(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,3));
          case Constants.OR:
            return new Or(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,3));
          case Constants.NOT:
            return new Not(Bits(valor,9,3),Bits(valor,6,3));
          case Constants.XOR:
            return new Xor(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,3));
          default:
            return new Invalida();
        }
    }

    static InterfaceIns DecodificaComparacions(int valor)
    {
        switch (Bits(valor,3,3))
        {
          case Constants.CMPLT:
            return new Cmplt(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,3));
          case Constants.CMPLE:
            return new Cmple(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,3));
          case Constants.CMPGT:
            return new Cmpgt(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,3));
          case Constants.CMPGE:
            return new Cmpge(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,3));
          case Constants.CMPLTU:
            return new Cmpltu(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,3));
          case Constants.CMPLEU:
            return new Cmpleu(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,3));
          case Constants.CMPGTU:
            return new Cmpgtu(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,3));
          case Constants.CMPGEU:
            return new Cmpgeu(Bits(valor,9,3),Bits(valor,6,3),Bits(valor,0,3));
          default:
            return new Invalida();
        }
    }

    static InterfaceIns DecodificaSalts(int valor)
    {
        switch (Bits(valor,6,3))
        {
          case Constants.BEQ:
            return new Beq(Bits(valor,9,3),Bits(valor,0,6));
          case Constants.BNE:
            return new Bne(Bits(valor,9,3),Bits(valor,0,6));
          case Constants.BR:
            return new Br(Bits(valor,0,6));
          case Constants.JMP:
            return new Jmp(Bits(valor,0,3));
          case Constants.JALR:
            return new Jalr(Bits(valor,0,3),Bits(valor,9,3));
          case Constants.JEQ:
            return new Jeq(Bits(valor,9,3),Bits(valor,0,3));
          case Constants.JNE:
            return new Jne(Bits(valor,9,3),Bits(valor,0,3));
          default:
            return new Invalida();
        }
    }
    
    interface InterfaceIns
    {
        void Executa(Simulador simulador);
        String GetString();
    }


}

abstract class Instruccio implements Decodificador.InterfaceIns
{
    String string;
    public abstract void Executa(Simulador simulador);
    public String GetString()
    {
        return string;
    }
}


class Add extends Instruccio
{
    int regDesti, regA, regB;
    Add (int rD, int rA, int rB)
    {
        regDesti = rD;
        regA = rA;
        regB = rB;
        string = new String ("ADD    " + "R" + regDesti + ",R" + regA + ",R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        short valor = (short)(simulador.registres[regA] + simulador.registres[regB]);
        simulador.CanviRegistre(regDesti,valor);
    }
}

class Sub extends Instruccio
{
    int regDesti, regA, regB;
    Sub (int rD, int rA, int rB)
    {
        regDesti = rD;
        regA = rA;
        regB = rB;
        string = new String ("SUB    " + "R" + regDesti + ",R" + regA + ",R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        short valor = (short)(simulador.registres[regA] - simulador.registres[regB]);
        simulador.CanviRegistre(regDesti,valor);
    }
}

class Sra extends Instruccio
{
    int regDesti, regA;
    Sra (int rD, int rA)
    {
        regDesti = rD;
        regA = rA;
        string = new String ("SRA    " + "R" + regDesti + ",R" + regA);
    }

    public void Executa(Simulador simulador)
    {
        short valor = (short)(simulador.registres[regA] >> 1);
        simulador.CanviRegistre(regDesti,valor);
    }
}

class Srl extends Instruccio
{
    int regDesti, regA;
    Srl (int rD, int rA)
    {
        regDesti = rD;
        regA = rA;
        string = new String ("SRL    " + "R" + regDesti + ",R" + regA);
    }

    public void Executa(Simulador simulador)
    {
        short valor = (short)((simulador.registres[regA] >> 1) & ~Short.MIN_VALUE);
        simulador.CanviRegistre(regDesti,valor);
    }
}

class And extends Instruccio
{
    int regDesti, regA, regB;
    And (int rD, int rA, int rB)
    {
        regDesti = rD;
        regA = rA;
        regB = rB;
        string = new String ("AND    " + "R" + regDesti + ",R" + regA + ",R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        short valor = (short)(simulador.registres[regA] & simulador.registres[regB]);
        simulador.CanviRegistre(regDesti,valor);
    }
}

class Or extends Instruccio
{
    int regDesti, regA, regB;
    Or (int rD, int rA, int rB)
    {
        regDesti = rD;
        regA = rA;
        regB = rB;
        string = new String ("OR     " + "R" + regDesti + ",R" + regA + ",R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        short valor = (short)(simulador.registres[regA] | simulador.registres[regB]);
        simulador.CanviRegistre(regDesti,valor);
    }
}

class Not extends Instruccio
{
    int regDesti, regA;
    Not (int rD, int rA)
    {
        regDesti = rD;
        regA = rA;
        string = new String ("NOT    " + "R" + regDesti + ",R" + regA);
    }

    public void Executa(Simulador simulador)
    {
        short valor = (short)(~simulador.registres[regA]);
        simulador.CanviRegistre(regDesti,valor);
    }
}

class Xor extends Instruccio
{
    int regDesti, regA, regB;
    Xor (int rD, int rA, int rB)
    {
        regDesti = rD;
        regA = rA;
        regB = rB;
        string = new String ("XOR    " + "R" + regDesti + ",R" + regA + ",R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        short valor = (short)(simulador.registres[regA] ^ simulador.registres[regB]);
        simulador.CanviRegistre(regDesti,valor);
    }
}

class Cmplt extends Instruccio
{
    int regDesti, regA, regB;
    Cmplt (int rD, int rA, int rB)
    {
        regDesti = rD;
        regA = rA;
        regB = rB;
        string = new String ("CMPLT  " + "R" + regDesti + ",R" + regA + ",R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        boolean valor = (simulador.registres[regA] < simulador.registres[regB]);
        simulador.CanviRegistre(regDesti,(short)(valor?1:0));
    }
}

class Cmple extends Instruccio
{
    int regDesti, regA, regB;
    Cmple (int rD, int rA, int rB)
    {
        regDesti = rD;
        regA = rA;
        regB = rB;
        string = new String ("CMPLE  " + "R" + regDesti + ",R" + regA + ",R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        boolean valor = (simulador.registres[regA] <= simulador.registres[regB]);
        simulador.CanviRegistre(regDesti,(short)(valor?1:0));
    }
}

class Cmpgt extends Instruccio
{
    int regDesti, regA, regB;
    Cmpgt (int rD, int rA, int rB)
    {
        regDesti = rD;
        regA = rA;
        regB = rB;
        string = new String ("CMPGT  " + "R" + regDesti + ",R" + regA + ",R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        boolean valor = simulador.registres[regA] > simulador.registres[regB];
        simulador.CanviRegistre(regDesti,(short)(valor?1:0));
    }
}

class Cmpge extends Instruccio
{
    int regDesti, regA, regB;
    Cmpge (int rD, int rA, int rB)
    {
        regDesti = rD;
        regA = rA;
        regB = rB;
        string = new String ("CMPGE  " + "R" + regDesti + ",R" + regA + ",R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        boolean valor = simulador.registres[regA] >= simulador.registres[regB];
        simulador.CanviRegistre(regDesti,(short)(valor?1:0));
    }
}

class Cmpltu extends Instruccio
{
    int regDesti, regA, regB;
    Cmpltu (int rD, int rA, int rB)
    {
        regDesti = rD;
        regA = rA;
        regB = rB;
        string = new String ("CMPLTU " + "R" + regDesti + ",R" + regA + ",R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        int u_val1, u_val2;
        u_val1 = simulador.registres[regA] & 0xFFFF;
        u_val2 = simulador.registres[regB] & 0xFFFF;
        boolean valor = u_val1 < u_val2;
        simulador.CanviRegistre(regDesti,(short)(valor?1:0));
    }
}

class Cmpleu extends Instruccio
{
    int regDesti, regA, regB;
    Cmpleu (int rD, int rA, int rB)
    {
        regDesti = rD;
        regA = rA;
        regB = rB;
        string = new String ("CMPLEU " + "R" + regDesti + ",R" + regA + ",R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        int u_val1, u_val2;
        u_val1 = simulador.registres[regA] & 0xFFFF;
        u_val2 = simulador.registres[regB] & 0xFFFF;
        boolean valor = u_val1 <= u_val2;
        simulador.CanviRegistre(regDesti,(short)(valor?1:0));
    }
}

class Cmpgtu extends Instruccio
{
    int regDesti, regA, regB;
    Cmpgtu (int rD, int rA, int rB)
    {
        regDesti = rD;
        regA = rA;
        regB = rB;
        string = new String ("CMPGTU " + "R" + regDesti + ",R" + regA + ",R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        int u_val1, u_val2;
        u_val1 = simulador.registres[regA] & 0xFFFF;
        u_val2 = simulador.registres[regB] & 0xFFFF;
        boolean valor = u_val1 > u_val2;
        simulador.CanviRegistre(regDesti,(short)(valor?1:0));
    }
}

class Cmpgeu extends Instruccio
{
    int regDesti, regA, regB;
    Cmpgeu (int rD, int rA, int rB)
    {
        regDesti = rD;
        regA = rA;
        regB = rB;
        string = new String ("CMPGEU " + "R" + regDesti + ",R" + regA + ",R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        int u_val1, u_val2;
        u_val1 = simulador.registres[regA] & 0xFFFF;
        u_val2 = simulador.registres[regB] & 0xFFFF;
        boolean valor = u_val1 >= u_val2;
        simulador.CanviRegistre(regDesti,(short)(valor?1:0));
    }
}

class In extends Instruccio
{
    int regDesti, imm;
    public In (int rD, int i)
    {
        regDesti = rD;
        imm = i;
        string = new String ("IN     " + "R" + regDesti + "," + imm);
    }

    public void Executa(Simulador simulador)
    {
        short valor = simulador.registres_entrada[imm];
        simulador.CanviRegistre(regDesti,valor);
    }
}

class Out extends Instruccio
{
    int regFont, imm;
    public Out (int i, int rF)
    {
        regFont = rF;
        imm = i;
        string = new String ("OUT    " + imm + ",R" + regFont);
    }

    public void Executa(Simulador simulador)
    {
        short valor = simulador.registres[regFont];
        simulador.CanviRegistreSortida(imm,valor);
    }
}

class LdW extends Instruccio
{
    int regDesti, regA, offset;
    public LdW (int rD, int rA, int o)
    {
        regDesti = rD;
        regA = rA;
        offset = (o > 31 ? -64+o : o);
        string = new String ("LDW    " + "R" + regDesti + "," + offset + "(R" + regA + ")");
    }

    public void Executa(Simulador simulador)
    {
        byte b [] = {0,0};
        int tmp = (int)simulador.registres[regA] & 0xFFFF;
        if ((offset+tmp)%2 != 0)
        {
            simulador.Error("Acces desalienat");
            return;
        }
        b[0] = simulador.memoria[offset+tmp];
        b[1] = simulador.memoria[offset+tmp+1];
        simulador.CanviRegistre(regDesti,(short)Simulador.DosBytes2Short(b));
    }
}

class StW extends Instruccio
{
    int regA, regB, offset;
    public StW (int o, int rA, int rB)
    {
        regA = rA;
        regB = rB;
        offset = (o > 31 ? -64+o : o);
        string = new String ("STW    " + offset + "(R" + regA + "),R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        int tmp = (int)simulador.registres[regA] & 0xFFFF;
        int direccio = tmp + offset;
        if ((offset+tmp)%2 != 0)
        {
            simulador.Error("Acces desalienat");
            return;
        }
        short val = simulador.registres[regB];
        simulador.CanviWordMem(direccio,val);
    }
}

class Beq extends Instruccio
{
    int regA, offset;
    public Beq (int rA, int o)
    {
        regA = rA;
        offset = (o > 31 ? -64+o : o);
        string = new String ("BEQ    " + "R" + regA + "," + offset);
    }

    public void Executa(Simulador simulador)
    {
        if (simulador.registres[regA] == 0)
        {
            simulador.CanviPC(simulador.PC-2+offset);
        }
    }
}

class Bne extends Instruccio
{
    int regA, offset;
    public Bne (int rA, int o)
    {
        regA = rA;
        offset = (o > 31 ? -64+o : o);
        string = new String ("BNE    " + "R" + regA + "," + offset);
    }

    public void Executa(Simulador simulador)
    {
        if (simulador.registres[regA] != 0)
        {
            simulador.CanviPC(simulador.PC-2+offset);
        }
    }
}

class Br extends Instruccio
{
    int offset;
    public Br (int o)
    {
        offset = (o > 31 ? -64+o : o);
        string = new String ("BR     " + offset);
    }

    public void Executa(Simulador simulador)
    {
        simulador.CanviPC(simulador.PC-2+offset);
    }
}

class Jmp extends Instruccio
{
    int regSalt;
    public Jmp (int rS)
    {
        regSalt = rS;
        string = new String ("JMP    " + "R" + regSalt);
    }

    public void Executa(Simulador simulador)
    {
        simulador.CanviPC(simulador.registres[regSalt]);
    }
}

class Jalr extends Instruccio
{
    int regLink;
    int regSalt;
    public Jalr (int rS, int rL)
    {
        regSalt = rS;
        regLink = rL;
        string = new String ("JALR   " + "R" + regSalt + ",R" + regLink);
    }

    public void Executa(Simulador simulador)
    {
        simulador.CanviRegistre(regLink,(short)simulador.PC);
        simulador.CanviPC(simulador.registres[regSalt]);
    }
}

class Jeq extends Instruccio
{
    int regA;
    int regSalt;
    public Jeq (int rA, int rS)
    {
        regA = rA;
        regSalt = rS;
        string = new String ("JEQ    " + "R" + regA + ",R" + regSalt);
    }

    public void Executa(Simulador simulador)
    {
        if (simulador.registres[regA] == 0)
        {
            simulador.CanviPC(simulador.registres[regSalt]);
        }
    }
}

class Jne extends Instruccio
{
    int regA;
    int regSalt;
    public Jne (int rA, int rS)
    {
        regA = rA;
        regSalt = rS;
        string = new String ("JNE    " + "R" + regA + ",R" + regSalt);
    }

    public void Executa(Simulador simulador)
    {
        if (simulador.registres[regA] != 0)
        {
            simulador.CanviPC(simulador.registres[regSalt]);
        }
    }
}

class AddI extends Instruccio
{
    int regDesti, regA, imm;
    public AddI (int rD, int rA, int i)
    {
        regDesti = rD;
        regA = rA;
        imm = (i > 31 ? -64+i : i);
        string = new String ("ADDI   " + "R" + regDesti + ",R" + regA + "," + imm);
    }

    public void Executa(Simulador simulador)
    {
        short valor = (short)(simulador.registres[regA] + imm);
        simulador.CanviRegistre(regDesti,valor);
    }
}

class Mli extends Instruccio
{
    int regDesti, imm;
    public Mli (int rD, int i)
    {
        regDesti = rD;
        imm = i;
        string = new String ("MLI    " + "R" + regDesti + "," + imm);
    }

    public void Executa(Simulador simulador)
    {
        short valor = (short)((simulador.registres[regDesti] & 0xFF00) | imm);
        simulador.CanviRegistre(regDesti,valor);
    }
}

class Mhi extends Instruccio
{
    int regDesti, imm;
    public Mhi (int rD, int i)
    {
        regDesti = rD;
        imm = i;
        string = new String ("MHI    " + "R" + regDesti + "," + imm);
    }

    public void Executa(Simulador simulador)
    {
        short valor = (short)((simulador.registres[regDesti] & 0xFF) | (imm<<8));
        simulador.CanviRegistre(regDesti,valor);
    }
}

class LdB extends Instruccio
{
    int regDesti, regA, offset;
    public LdB (int rD, int rA, int o)
    {
        regDesti = rD;
        regA = rA;
        offset = (o > 31 ? -64+o : o);
        string = new String ("LDB    " + "R" + regDesti + "," + offset + "(R" + regA + ")");
    }

    public void Executa(Simulador simulador)
    {
        byte b;
        int tmp = (int)simulador.registres[regA] & 0xFFFF;
        b = simulador.memoria[offset+tmp];
        simulador.CanviRegistre(regDesti,(short)b);
    }
}

class StB extends Instruccio
{
    int regA, regB, offset;
    public StB (int o, int rA, int rB)
    {
        regA = rA;
        regB = rB;
        offset = (o > 31 ? -64+o : o);
        string = new String ("STB    " + offset + "(R" + regA + "),R" + regB);
    }

    public void Executa(Simulador simulador)
    {
        int tmp = (int)simulador.registres[regA] & 0xFFFF;
        int direccio = tmp + offset;
        byte val = (byte)simulador.registres[regB];
        simulador.CanviByteMem(direccio,val);
    }
}

class Halt extends Instruccio
{
    public Halt()
    {
        string = new String ("HALT");
    }
    
    public void Executa(Simulador simulador)
    {
        simulador.Halt();
    }
}

class Invalida extends  Instruccio
{
    public Invalida()
    {
        string = new String ("INVALID");
    }

    public void Executa(Simulador simulador)
    {
        simulador.Error("Execucio d'una instruccio invalida");
    }
}

interface Constants
{
    static final int ARITMETIC = 0;
    static final int COMPARACIONS = 1;
    static final int IN = 2;
    static final int OUT = 3;
    static final int LDW = 4;
    static final int STW = 5;
    static final int SALTS = 6;
    static final int ADDI = 7;
    static final int MLI = 8;
    static final int MHI = 9;
    static final int LDB = 12;
    static final int STB = 13;
    static final int HALT = 15;
    
    static final int ADD = 0;
    static final int SUB = 1;
    static final int SRA = 2;
    static final int SRL = 3;
    static final int AND = 4;
    static final int OR = 5;
    static final int NOT = 6;
    static final int XOR = 7;

    static final int CMPLT = 0;
    static final int CMPLE = 1;
    static final int CMPGT = 2;
    static final int CMPGE = 3;
    static final int CMPLTU = 4;
    static final int CMPLEU = 5;
    static final int CMPGTU = 6;
    static final int CMPGEU = 7;

    static final int BEQ = 0;
    static final int BNE = 1;
    static final int BR = 2;
    static final int JMP = 3;
    static final int JALR = 4;
    static final int JEQ = 6;
    static final int JNE = 7;
}
