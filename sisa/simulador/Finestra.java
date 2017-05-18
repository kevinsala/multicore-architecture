import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;
import javax.swing.event.*;
import java.io.*;

class EtiquetaRegs extends JLabel
{
    static int base=10;
    static int digits=6;
    static boolean natural=true;
    static boolean hexPrefix=false;

    EtiquetaRegs(String s)
    {
        super(s);
    }

    void nouValor(int i)
    {
        setText(Visualitzador.MostraNum(i,base,digits,natural,hexPrefix));
    }
}

class Finestra extends JFrame
{
    VisualitzadorMemCodi codi;
    VisualitzadorMemDades pila;
    VisualitzadorMemDades dades;
    VisualitzadorRegsEntrada regsEntrada;
    VisualitzadorRegsSortida regsSortida;
    VisualitzadorRegs regs;
    Simulador simulador;
    JLabel nomRegs [];
    EtiquetaRegs valRegs [];
    JLabel insExec;
    JTextField insPerExec;

    Finestra(Simulador s)
    {
        super("Simulador SISA");
        simulador = s;
        codi = new VisualitzadorMemCodi(simulador,Simulador.mida_memoria/2,true,true,true);
        pila = new VisualitzadorMemDades(simulador,Simulador.mida_memoria/2,false,true,false);
        dades = new VisualitzadorMemDades(simulador,Simulador.mida_memoria/2,false,false,false);
        regsEntrada = new VisualitzadorRegsEntrada(simulador,64,false,false,false);
        regsSortida = new VisualitzadorRegsSortida(simulador,64,false,false,false);
        regs = new VisualitzadorRegs(simulador,9,false,false,false);

        getContentPane().setLayout(new BorderLayout());

        JPanel panellSuperior = new JPanel();
        JPanel panellCentral = new JPanel ();
        JPanel panellRegsES = new JPanel ();

        panellRegsES.setLayout(new GridLayout(2,1));
        panellRegsES.add(new PanellScroll(regsEntrada,"Entrada"));
        panellRegsES.add(new PanellScroll(regsSortida,"Sortida"));

        panellCentral.setLayout(new GridLayout(1,3));

        panellCentral.add(new PanellScroll(pila,"Pila"));
        panellCentral.add(new PanellScroll(dades,"Dades"));
        panellCentral.add(panellRegsES);


        JMenuBar menu = ConstrueixMenu();
        JToolBar barra = ConstrueixBarra();
        panellSuperior.setLayout(new GridLayout(2,1));
        panellSuperior.add(menu);
        panellSuperior.add(barra);

        getContentPane().add(new PanellScroll(codi,"Codi"), BorderLayout.WEST);
        getContentPane().add(panellSuperior, BorderLayout.NORTH);
        getContentPane().add(panellCentral, BorderLayout.CENTER);
        getContentPane().add(new PanellScroll(regs,"Registres"), BorderLayout.EAST);
        
        setSize(800,600);
        setVisible(true);

        addWindowListener(
          new WindowAdapter()
          {
            public void windowClosing(WindowEvent evt)
            {
                System.exit(0);
            }
          });
    }

    class PanellScroll extends JPanel
    {
        PanellScroll(JComponent c, String titol)
        {
            setLayout(new BorderLayout());
            add(new JLabel(titol),BorderLayout.NORTH);
            add(new JScrollPane(c),BorderLayout.CENTER);
        }
    }

    JToolBar ConstrueixBarra()
    {
        JButton b1 = new JButton("Step");
        JButton b2 = new JButton("Run");
        JButton b3 = new JButton("Stop");
        JButton b4 = new JButton("Break");
        JButton b6 = new JButton("Restart");
        JButton b5 = new JButton("Go");

        JToolBar tmp = new JToolBar();

        tmp.add(b1);
        tmp.add(b2);
        tmp.add(b3);
        tmp.add(b4);
        tmp.add(b6);
        tmp.add(new JToolBar.Separator());
        tmp.add(new JLabel("Executar instruccions: "));
        insPerExec = new JTextField(10);
        tmp.add(insPerExec);
        tmp.add(b5);
        tmp.add(new JToolBar.Separator());
        tmp.add(new JLabel("Instruccions executades: "));
        insExec = new JLabel(Integer.toString(simulador.insExec));
        tmp.add(insExec);
        tmp.add(new JToolBar.Separator());

        b1.addActionListener(
            new ActionListener()
            {
                public void actionPerformed(ActionEvent evt)
                {
                    simulador.Cicle();
                }
            }
        );

        b2.addActionListener(
            new ActionListener()
            {
                public void actionPerformed(ActionEvent evt)
                {
                    simulador.Executa(-1);
                }
            }
        );

        b3.addActionListener(
            new ActionListener()
            {
                public void actionPerformed(ActionEvent evt)
                {
                    simulador.Para();
                }
            }
        );
        
        b4.addActionListener(
            new ActionListener()
            {
                public void actionPerformed(ActionEvent evt)
                {
                    int i = codi.getSelectedIndex();
                    if (i == -1)
                    {
                        simulador.CanviBreakPoint(simulador.PC/2);
                    }
                    else
                    {
                        simulador.CanviBreakPoint(i);
                    }
                }
            }
        );
        
        b5.addActionListener(
            new ActionListener()
            {
                public void actionPerformed(ActionEvent evt)
                {
                    Integer i = new Integer(insPerExec.getText());
                    if (i != null)
                    {
                        simulador.Executa(i.intValue());
                    }
                }
            }
        );

        b6.addActionListener(
            new ActionListener()
            {
                public void actionPerformed(ActionEvent evt)
                {
                    simulador.LlegeixFitxer(null);
                    Finestra.this.codi.ReCarrega();
                    Finestra.this.dades.ReCarrega();
                    Finestra.this.pila.ReCarrega();
                    Finestra.this.regs.ReCarrega();
                    Finestra.this.regsEntrada.ReCarrega();
                    Finestra.this.regsSortida.ReCarrega();
                    Finestra.this.insExec.setText(Integer.toString(simulador.insExec));
                    Finestra.this.repaint();
                }
            }
        );

        return tmp;
    }

    JMenuBar ConstrueixMenu()
    {
        JMenuBar tmp = new JMenuBar();
        JMenu arxiu = new JMenu("Arxiu");
        JMenu ajuda = new JMenu("Ajuda");

        tmp.add(arxiu);
        tmp.add(ajuda);

        JMenuItem mi = new JMenuItem("Obre");
        mi.addActionListener(
            new ActionListener()
            {
                public void actionPerformed(ActionEvent e)
                {
                    JFileChooser fc = new JFileChooser();
                    fc.setCurrentDirectory(fc.getCurrentDirectory());
                    int returnVal = fc.showOpenDialog(Finestra.this);
                    if (returnVal == JFileChooser.APPROVE_OPTION)
                    {
                        File file = fc.getSelectedFile();
                        simulador.LlegeixFitxer(file.toString());
                        Finestra.this.codi.ReCarrega();
                        Finestra.this.dades.ReCarrega();
                        Finestra.this.pila.ReCarrega();
                        Finestra.this.regs.ReCarrega();
                        Finestra.this.regsEntrada.ReCarrega();
                        Finestra.this.regsSortida.ReCarrega();
                        Finestra.this.insExec.setText(Integer.toString(simulador.insExec));
                        Finestra.this.repaint();
                    }
                }
            }
        );
        arxiu.add(mi);
        mi = new JMenuItem("Sortir");
        mi.addActionListener(
            new ActionListener()
            {
                public void actionPerformed(ActionEvent e)
                {
                    int i = JOptionPane.showConfirmDialog(
                        Finestra.this, "Vols sortir?", "", JOptionPane.YES_NO_OPTION); 

                    if (i == JOptionPane.YES_OPTION)
                    {
                        System.exit(0);
                    }
                }
            }
        );

        arxiu.add(mi);
        mi = new JMenuItem("Sobre");
        ajuda.add(mi);
        mi = new JMenuItem("Versio");
        ajuda.add(mi);

        return tmp;
    }
}

class ModelLlista implements ListModel
{
    String llista [];

    ModelLlista(int mida)
    {
        llista = new String [mida];
    }

    public Object getElementAt(int index)
    {
        return llista[index];
    }

    public int getSize()
    {
        return llista.length;
    }

    public void addListDataListener(ListDataListener l) {}
    public void removeListDataListener(ListDataListener l) {}

    void set(int index, String s)
    {
        llista[index] = s;
    }
}


abstract class Visualitzador extends JList
{
    int base;
    int digits;
    boolean natural;
    boolean hexPrefix;

    Simulador simulador;
    ModelLlista ml;
    boolean focus;
    JPopupMenu popup;

    Visualitzador(Simulador sim, int mida, boolean pcFocus, boolean f, boolean breaks)
    {
        base=10;
        digits=5;
        natural=true;
        hexPrefix=false;

        ml = new ModelLlista(mida);
        simulador = sim;
        focus=f;

        for (int i = 0; i < ml.getSize(); i++)
        {
            ml.set(i,ObteString(i));
        }
        setModel(ml);

        setCellRenderer(new Renderejador(simulador,pcFocus,focus,breaks));
        setSelectionMode(ListSelectionModel.SINGLE_SELECTION);

        popup = CreaPopUp();

    }

    void ReCarrega()
    {
        for (int i = 0; i < ml.getSize(); i++)
        {
            ml.set(i,ObteString(i));
        }
    }

    abstract String ObteString(int i);

    class Renderejador extends JLabel implements ListCellRenderer
    {
        Simulador simulador;
        boolean pcFocus;
        boolean focus;
        boolean breaks;
        public Renderejador(Simulador sim, boolean pcF, boolean f, boolean b)
        {
            setOpaque(true);
            simulador = sim;
            pcFocus = pcF;
            focus = f;
            breaks = b;
            setFont(new Font("Courier", Font.BOLD, 12));
        }
        
        public Component getListCellRendererComponent(
            JList list, Object value, int index, boolean isSelected, boolean cellHasFocus)
        {
            setText(value.toString());
            setBackground(isSelected ? Color.blue : Color.white);
            setForeground(isSelected ? Color.white : Color.black);
            int referencia = (pcFocus ? simulador.PC : simulador.registres[7]);
            referencia &= 0xFFFF;
            boolean canviColor = false;
            if (breaks && (simulador.breakPoints[index]))
            {
                setBackground(Color.red);
                canviColor = true;
            }
            if (focus && (index == (referencia/2)))
            {
                setBackground(Color.green);
                if (canviColor)
                {
                    setForeground(Color.red);
                }
            }
            return this;
        }
    }

    String MostraNumAdreca(int i)
    {
        return MostraNum(i,base,digits,true,hexPrefix);
    }

    String MostraNum (int i)
    {
        return MostraNum(i,base,digits,natural,hexPrefix) + " ";
    }

    static String MostraNum (int i, int base, int digits, boolean natural, boolean hexPrefix)
    {
        Simulador.Assert(base == 16 || base == 10);

        String s;
        if (base == 16)
        {
            s = Integer.toHexString(i).toUpperCase();
            s = s.substring(s.length() > 4 ? s.length()-4 : 0,s.length());
            s = taulaZeros[digits-s.length()]+s;
            return (hexPrefix ? "0x" + s : s);
        }
        if (base == 10)
        {
            int valor = (natural? i & 0xFFFF : (int)((short)i) );
            boolean signe = valor < 0;
            s = Integer.toString(Math.abs(valor));
            String prefix = (signe? "-" : (digits == 5 ? " " : ""));
            return prefix + taulaZeros[digits-s.length()] + s;
        }
        return null;
    }

    static final String taulaZeros []= { "", "0", "00", "000", "0000", "00000", "000000"};

    void Canvi(int posicio, boolean modeRapid)
    {
        ml.set(posicio,ObteString(posicio));
        if (!modeRapid && (posicio >= getFirstVisibleIndex() && posicio <= getLastVisibleIndex()))
        {
            repaint();
        }
    }

    void Focus (int index, boolean modeRapid)
    {
        if (focus && !modeRapid)
        {
            ensureIndexIsVisible(index);
            repaint();
        }
    }

    JPopupMenu CreaPopUp()
    {
        Escoltador e = new Escoltador(this);
        JPopupMenu tmp = new JPopupMenu("Tipus dades");
        JMenuItem mi = new JMenuItem("Hexa");
        mi.addActionListener(e);
        tmp.add(mi);
        mi = new JMenuItem("Natural");
        mi.addActionListener(e);
        tmp.add(mi);
        mi = new JMenuItem("Ca2");
        mi.addActionListener(e);
        tmp.add(mi);

        return tmp;
    }

    protected void processMouseEvent(MouseEvent evt)
    {
        if (evt.isPopupTrigger())
        {
            popup.show(evt.getComponent(),evt.getX(),evt.getY());
        }
        else
        {
            super.processMouseEvent(evt);
        }
    }

    class Escoltador implements ActionListener
    {
        Visualitzador visualitzador;

        Escoltador(Visualitzador vis)
        {
            visualitzador=vis;
        }
        
        public void actionPerformed(ActionEvent evt)
        {
            String s = ((JMenuItem)evt.getSource()).getText();

            if (s.equals("Hexa"))
            {
                base=16;
                digits=4;
                hexPrefix=true;
            }
            else if (s.equals("Natural"))
            {
                base=10;
                digits=5;
                natural=true;
            }
            else if (s.equals("Ca2"))
            {
                base=10;
                digits=5;
                natural=false;
            }
            
            for (int i = 0; i < visualitzador.ml.getSize(); i++)
            {
                visualitzador.ml.set(i,ObteString(i));
            }
            visualitzador.repaint();
        }
    }
}



class VisualitzadorMemCodi extends Visualitzador
{
    VisualitzadorMemCodi(Simulador sim, int mida, boolean pcFocus, boolean f, boolean b)
    {
        super(sim,mida,pcFocus,f,b);
        setFixedCellWidth(230);
        setFixedCellHeight(16);
    }
    
    String ObteString(int posicio)
    {
        return " " + MostraNumAdreca(posicio*2) + " : " + Decodificador.Decodifica(simulador,posicio*2).GetString();
    }
}

class VisualitzadorMemDades extends Visualitzador
{
    VisualitzadorMemDades(Simulador sim, int mida, boolean pcFocus, boolean f, boolean b)
    {
        super(sim,mida,pcFocus,f,b);
    }
    
    String ObteString(int posicio)
    {
        byte b [] = new byte [2];
        b[0] = simulador.memoria[posicio*2];
        b[1] = simulador.memoria[posicio*2+1];
        return " " + MostraNumAdreca(posicio*2) + " : " + MostraNum(Simulador.DosBytes2Short(b));
    }
}

class VisualitzadorRegsEntrada extends Visualitzador
{
    VisualitzadorRegsEntrada(Simulador sim, int mida, boolean pcFocus, boolean f, boolean b)
    {
        super(sim,mida,pcFocus,f,b);
    }
    
    String ObteString(int posicio)
    {
        return " " + MostraNumAdreca(posicio) + " : " + MostraNum(simulador.registres_entrada[posicio]);
    }
}

class VisualitzadorRegsSortida extends Visualitzador
{
    VisualitzadorRegsSortida(Simulador sim, int mida, boolean pcFocus, boolean f, boolean b)
    {
        super(sim,mida,pcFocus,f,b);
    }
    
    String ObteString(int posicio)
    {
        return " " + MostraNumAdreca(posicio) + " : " + MostraNum(simulador.registres_sortida[posicio]);
    }
}

class VisualitzadorRegs extends Visualitzador
{
    VisualitzadorRegs(Simulador sim, int mida, boolean pcFocus, boolean f, boolean b)
    {
        super(sim,mida,pcFocus,f,b);
        setFixedCellWidth(95);
        setFixedCellHeight(30);
        setOpaque(false);
    }

    String ObteString(int posicio)
    {
        if (posicio == 8)
        {
            return " PC : " + MostraNumAdreca(simulador.PC);
        }
        else
        {
            return " R" + posicio + " : " + MostraNum(simulador.registres[posicio]);
        }
    }
}

