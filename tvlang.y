%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern int yylineno;
extern FILE *yyin;
void yyerror(const char *s);

char *strdup_safe(const char *s) {
    if(!s) return NULL;
    char *r = malloc(strlen(s)+1);
    strcpy(r,s);
    return r;
}

char *concat(const char *a, const char *b) {
    if(!a && !b) return strdup("");
    if(!a) return strdup_safe(b);
    if(!b) return strdup_safe(a);
    size_t na = strlen(a), nb = strlen(b);
    char *res = malloc(na + nb + 1);
    strcpy(res, a);
    strcat(res, b);
    return res;
}
%}

%union {
    char *str;
    int num;
}

%token LIGAR DESLIGAR SETAR AUMENTAR DIMINUIR SLEEP_KW SE MODO HORARIO EXECUTAR
%token <str> NAME
%token <str> IDENT
%token <str> FONTE
%token <num> NUMERO HORA
%token EQ NE LE GE

/* tipos dos não-terminais que retornam strings */
%type <str> program items item bloco instrs instr modo_def setar_stmt incdec ligar_stmt desligar_stmt sleepbloco condicao expressao valor action chamadamodo

%%

program:
    items
    {
        printf("=== Programa Parseado ===\n%s\n", $1 && strlen($1) ? $1 : "(vazio)");
        free($1);
    }
;

items:
    /* empty */ { $$ = strdup(""); }
  | items item
    {
        if (strlen($1) == 0) {
            $$ = strdup($2);
        } else {
            char *tmp = concat($1, "\n");
            char *tmp2 = concat(tmp, $2);
            free(tmp);
            free($1);
            free($2);
            $$ = tmp2;
        }
    }
;

item:
    modo_def { $$ = $1; }
  | instr    { $$ = $1; }
;

modo_def:
    MODO NAME bloco
    {
        char *tmp = concat("modo ", $2);
        char *t2  = concat(tmp, " ");
        free(tmp);
        tmp = concat(t2, $3);
        free(t2);
        $$ = tmp;
        free($2);
        free($3);
    }
;

bloco:
    '{' instrs '}'
    {
        char *tmp  = concat("{\n", $2);
        char *tmp2 = concat(tmp, "}");
        free(tmp);
        free($2);
        $$ = tmp2;
    }
;

instrs:
    /* empty */ { $$ = strdup(""); }
  | instrs instr
    {
        if (strlen($1) == 0) {
            $$ = strdup($2);
            free($2);
            free($1);
        } else {
            char *tmp  = concat($1, "\n");
            char *tmp2 = concat(tmp, $2);
            free(tmp);
            free($1);
            free($2);
            $$ = tmp2;
        }
    }
;

/* action representa a ação SEM o ponto-e-vírgula */
action:
      ligar_stmt
    | desligar_stmt
    | setar_stmt
    | incdec
    | chamadamodo
;

/* instr exige exatamente um ';' por instrução:
   - action ';'  (ações simples)
   - sleepbloco ';' (sleep bloco seguido de ;)
   - condicao  (condicao já inclui o ';' internamente)
*/
/* instr:
   - action ';'        (ações simples)
   - sleepbloco        (já termina no '}'; sem ';')
   - condicao          (já inclui o ';' internamente)
*/
instr:
    action ';'
    {
        char *tmp = concat($1, ";");
        $$ = tmp;
        free($1);
    }
  | sleepbloco
  | condicao
;


/* statements produzem strings SEM o ';' */
ligar_stmt:
    LIGAR { $$ = strdup("ligar"); }
;

desligar_stmt:
    DESLIGAR { $$ = strdup("desligar"); }
;

setar_stmt:
    SETAR IDENT valor
    {
        char *tmp  = concat("setar ", $2);
        char *tmp2 = concat(tmp, " ");
        free(tmp);
        tmp = concat(tmp2, $3);
        free(tmp2);
        $$ = tmp;
        free($2);
        free($3);
    }
;

incdec:
    AUMENTAR IDENT
    {
        char *tmp = concat("aumentar ", $2);
        $$ = tmp;
        free($2);
    }
  | DIMINUIR IDENT
    {
        char *tmp = concat("diminuir ", $2);
        $$ = tmp;
        free($2);
    }
;

valor:
    NUMERO
    {
        char buf[64];
        snprintf(buf, sizeof(buf), "%d", $1);
        $$ = strdup(buf);
    }
  | FONTE
    {
        $$ = strdup($1);
        free($1);
    }
;

/* sleepbloco produz string sem ';' (instr pede sleepbloco ';') */
sleepbloco:
    SLEEP_KW '(' NUMERO ')' bloco
    {
        char buf[64];
        snprintf(buf, sizeof(buf), "sleep(%d) ", $3);
        char *tmp = concat(buf, $5);
        $$ = tmp;
        free($5);
    }
;

/* condicao consome uma action e o ';' internamente:
   se (expressao) : <action> ;
*/
condicao:
    SE '(' expressao ')' ':' action ';'
    {
        char *tmp1 = concat("se (", $3);
        char *tmp2 = concat(tmp1, ") : ");
        free(tmp1);
        char *tmp = concat(tmp2, $6);
        free(tmp2);
        char *res = concat(tmp, ";");
        free(tmp);
        $$ = res;
        free($3);
        free($6);
    }
;

/* chamada de modo: executar Nome */
chamadamodo:
    EXECUTAR NAME
    {
        char *tmp = concat("executar ", $2);
        $$ = tmp;
        free($2);
    }
;

expressao:
    HORARIO EQ HORA
    {
        char buf[80];
        snprintf(buf, sizeof(buf), "horario == %dh", $3);
        $$ = strdup(buf);
    }
  | HORARIO NE HORA
    {
        char buf[80];
        snprintf(buf, sizeof(buf), "horario != %dh", $3);
        $$ = strdup(buf);
    }
  | HORARIO '<' HORA
    {
        char buf[80];
        snprintf(buf, sizeof(buf), "horario < %dh", $3);
        $$ = strdup(buf);
    }
  | HORARIO '>' HORA
    {
        char buf[80];
        snprintf(buf, sizeof(buf), "horario > %dh", $3);
        $$ = strdup(buf);
    }
  | HORARIO LE HORA
    {
        char buf[80];
        snprintf(buf, sizeof(buf), "horario <= %dh", $3);
        $$ = strdup(buf);
    }
  | HORARIO GE HORA
    {
        char buf[80];
        snprintf(buf, sizeof(buf), "horario >= %dh", $3);
        $$ = strdup(buf);
    }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe (linha %d): %s\n", yylineno, s);
}

int main(int argc, char **argv) {
    if(argc > 1) {
        FILE *f = fopen(argv[1],"r");
        if(!f) {
            perror("Nao foi possivel abrir arquivo");
            return 1;
        }
        yyin = f;
    }
    if (yyparse() == 0) {
        return 0;
    } else {
        return 1;
    }
}
