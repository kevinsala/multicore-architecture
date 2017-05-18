ifeq "$(DEBUG)" "1"
FLEX_DEBUG_FLAGS=-d
BISON_DEBUG_FLAGS=--debug
endif

ifeq "$(OPT)" "1"
OPT_FLAGS=-O3
endif

FLAGS= -ansi -pedantic -W -Wall -g

OBJS=lexic.o ld.tab.o sisa-ld.o

all : sisa-ld

sisa-ld : $(OBJS)
	g++ $(FLAGS) $(OPT_FLAGS) -o sisa-ld $^

sisa-ld.cpp : sisa-ld.h ident.h
	touch sisa-ld.cpp

%.o : %.cpp
	g++ $(FLAGS) $(OPT_FLAGS) -c $< -o $@

lexic.cpp : ld.l ld.tab.hpp defi.h
	flex -t $(FLEX_DEBUG_FLAGS) -i ld.l > lexic.cpp

ld.tab.cpp ld.tab.hpp : ld.ypp
	bison $(BISON_DEBUG_FLAGS) -vd ld.ypp

clean :
	-rm *.o ld.tab.cpp ld.tab.hpp lexic.cpp sisa-ld

