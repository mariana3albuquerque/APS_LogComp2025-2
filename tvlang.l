%{
#include "tvlang.tab.h"
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
extern int yylineno;
%}

DIGITO      [0-9]
NUM         {DIGITO}+
IDCHAR      [A-Za-z_][A-Za-z0-9_]*

%%

[ \t\r]+               { /* ignora espacos */ }
\n                     { yylineno++; }

"ligar"                { return LIGAR; }
"desligar"             { return DESLIGAR; }
"setar"                { return SETAR; }
"aumentar"             { return AUMENTAR; }
"diminuir"             { return DIMINUIR; }
"sleep"                { return SLEEP_KW; }
"se"                   { return SE; }
"modo"                 { return MODO; }
"horario"              { return HORARIO; }
"executar"             { return EXECUTAR; }

"("                    { return '('; }
")"                    { return ')'; }
"{"                    { return '{'; }
"}"                    { return '}'; }
";"                    { return ';'; }
":"                    { return ':'; }

"=="                   { return EQ; }
"!="                   { return NE; }
"<="                   { return LE; }
">="                   { return GE; }
"<"                    { return '<'; }
">"                    { return '>'; }

"tv"                   { yylval.str = strdup("tv"); return FONTE; }
"hdmi"                 { yylval.str = strdup("hdmi"); return FONTE; }
"satelite"             { yylval.str = strdup("satelite"); return FONTE; }
"av"                   { yylval.str = strdup("av"); return FONTE; }

"canal"                { yylval.str = strdup("canal"); return IDENT; }
"volume"               { yylval.str = strdup("volume"); return IDENT; }
"entrada"              { yylval.str = strdup("entrada"); return IDENT; }
"energia"              { yylval.str = strdup("energia"); return IDENT; }
"sleep"                { yylval.str = strdup("sleep"); return IDENT; }

{NUM}"h"               { yylval.num = atoi(yytext); return HORA; }
{NUM}                  { yylval.num = atoi(yytext); return NUMERO; }

{IDCHAR}               { yylval.str = strdup(yytext); return NAME; }

.                      {
                          char err[80];
                          snprintf(err, sizeof(err), "Caracter invalido: %s", yytext);
                          yyerror(err);
                        }

%%

int yywrap(void) { return 1; }
