FLEX = flex
BISON = bison
CC = g++
CFLAGS = -Wall -g -std=c++11
FLEX_LIBS = -lfl
TARGET = rx-cc

LEX_SRC = new_project.lex
YACC_SRC = new_project.ypp
HELPERS_SRC = part3_helpers.cpp
HELPERS_HDR = part3_helpers.hpp

LEX_OUT_C = lex.yy.c
YACC_OUT_C = new_project.tab.cpp  # Changed to .cpp
YACC_OUT_H = new_project.tab.hpp
HELPERS_OBJ = part3_helpers.o

OBJS = lex.yy.o new_project.tab.o $(HELPERS_OBJ)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(FLEX_LIBS)

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(LEX_OUT_C): $(LEX_SRC) $(YACC_OUT_H)
	$(FLEX) $<

$(YACC_OUT_C) $(YACC_OUT_H): $(YACC_SRC)
	$(BISON) -d $< -o $(YACC_OUT_C)

clean:
	rm -f $(TARGET) $(OBJS) $(LEX_OUT_C) $(YACC_OUT_C) $(YACC_OUT_H)
