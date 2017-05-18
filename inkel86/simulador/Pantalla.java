import java.io.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

class Pantalla
{
    JFrame  frame;
    JLabel  caracter [][];
    Simulador sim;

    Pantalla (Simulador s)
    {
        sim = s;
        frame = new JFrame("Pantalla");

        frame.getContentPane().setLayout(new GridLayout(20,40));

        caracter = new JLabel[20][40];
        for (int i=0; i<20;i++)
        {
            for (int j=0; j<40; j++)
            {
                caracter[i][j] = new JLabel(" ");
                frame.getContentPane().add(caracter[i][j]);
            }
        }

        frame.setSize(420,250);
        frame.setVisible(true);

        frame.addKeyListener(
            new KeyListener()
            {
                public void keyPressed(KeyEvent e) {}
                public void keyReleased(KeyEvent e) {}
                public void keyTyped(KeyEvent e)
                {
                    sim.CanviRegistreEntrada(58,(short)(((short)e.getKeyChar())&0xFF));
                    sim.CanviRegistreEntrada(59,(short)1);
                }
            }
        );

    }

    void Escriu (int fila, int columna, char c)
    {
        char [] s = new char [1];
        s[0]=c;
        caracter[fila][columna].setText(new String(s));
        caracter[fila][columna].repaint();
    }
}
