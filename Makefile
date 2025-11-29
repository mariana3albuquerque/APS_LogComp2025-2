CC = gcc
LEX = flex
YACC = bison
CFLAGS = -Wall -Wextra -g
LDFLAGS = -lfl

.PHONY: all clean tvlang tvvm

all: tvlang tvvm

# TVLang Parser
tvlang: tvlang
tvlang: tvlang.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o tvlang tvlang.tab.c lex.yy.c $(LDFLAGS)

tvlang.tab.c tvlang.tab.h: tvlang.y
	$(YACC) -d tvlang.y

lex.yy.c: tvlang.l tvlang.tab.h
	$(LEX) tvlang.l

# TVVM
tvvm: tvvm_main.o tvvm.o
	$(CC) $(CFLAGS) -o tvvm $^

tvvm.o: tvvm.c tvvm.h
	$(CC) $(CFLAGS) -c tvvm.c

tvvm_main.o: tvvm_main.c tvvm.h
	$(CC) $(CFLAGS) -c tvvm_main.c

clean:
	rm -f tvlang tvvm *.o tvlang.tab.* lex.yy.c

