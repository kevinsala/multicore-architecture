
all:	sisalib.a

sisalib.a:	sisaFuncs.o sisaFuncs_c.o
	test -f sisalib.a && rm sisalib.a; ar q sisalib.a sisaFuncs.o sisaFuncs_c.o

sisaFuncs.o:	sisaFuncs.s
	sisa-gcc -W -Wall -O3 -c sisaFuncs.s
	
sisaFuncs_c.o:	sisaFuncs_c.c
	sisa-gcc -W -Wall -O3 -c sisaFuncs_c.c

clean:
	rm sisalib.a sisaFuncs.o sisaFuncs_c.o
