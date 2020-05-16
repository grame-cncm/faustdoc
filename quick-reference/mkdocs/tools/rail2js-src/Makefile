

OBJS   = rail2js.o gram.o lex.o
TARGET = ../rail2js

CC=g++
CXXFLAGS= -std=c++11
YACC=bison -y
LEX=flex

all: $(TARGET) 

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@

$(OBJS): rail2js.h

rail2js.o lex.o: gram.hpp

gram.cpp : gram.y
gram.hpp : gram.y
	$(YACC) -d -o gram.cpp  gram.y

lex.cpp : lex.l gram.hpp 
	$(LEX)  -olex.cpp -I lex.l

clean:
	-rm -f $(OBJS) rail2js gram.hpp gram.cpp lex.cpp $(TARGET)

install:
	cp rail2js $(HOME)/bin
