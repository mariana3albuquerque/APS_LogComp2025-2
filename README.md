# APS LogComp2025-2

#EBNF TVLang 

Arquivo        = { Instrucao | ModoDef } ;

ModoDef        = "modo" Nome Bloco ;

Bloco          = "{" { Instrucao } "}" ;

Instrucao      = Ligar ";"
               | Desligar ";"
               | Setar ";"
               | Incremento ";"
               | Decremento ";"
               | SleepBloco
               | Condicao ;

Ligar          = "ligar" ;
Desligar       = "desligar" ;

Setar          = "setar" Identificador Valor ;

Incremento     = "aumentar" Identificador ;
Decremento     = "diminuir" Identificador ;

Identificador  = "canal" | "volume" | "entrada" | "energia" | "sleep" ;

Valor          = Numero | Fonte ;

Fonte          = "tv" | "hdmi" | "satelite" | "av" ;

Numero         = Digito { Digito } ;
Digito         = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;

SleepBloco     = "sleep" "(" Numero ")" Bloco ;

Condicao       = "se" "(" ExpressaoCond ")" ":" Instrucao ;

ExpressaoCond  = "horario" OperadorRel Hora ;

OperadorRel    = "==" | "!=" | "<" | ">" | "<=" | ">=" ;

Hora           = Numero "h" ;

Nome           = Letter { Letter | Digit | "_" } ;
Letter         = "A" | "B" | ... | "Z" | "a" | ... | "z" ;

##Exemplos :
bash´´ 
ligar;
setar canal 12;
aumentar volume;
desligar;´´

