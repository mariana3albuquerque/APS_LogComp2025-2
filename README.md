# TVLang

A structured, TV-inspired programming language with simple instructions for **canal**, **volume**, **entrada**, **energia**, and **sleep timer**, designed to demonstrate compiler construction and computational models in an intuitive way.  

---

## 🎯 Overview

**TVLang** é uma linguagem educacional projetada para mostrar como construir linguagens e compiladores simples, tomando como metáfora o uso de uma televisão.  
Com apenas alguns registradores e instruções básicas, é possível expressar:  

- **Educação em Ciência da Computação**: aprendendo sobre linguagens e máquinas virtuais  
- **Desenvolvimento de Compiladores**: traduzindo alto nível para assembly da TVVM  
- **Exploração de Algoritmos**: controle de loops e condicionais  
- **Pesquisa Teórica**: modelando máquinas de estado e completude computacional  

---

## 🏗️ Arquitetura

### Registradores Mutáveis
- **`CANAL`**: Canal atual da TV  
- **`VOLUME`**: Volume atual (nível inteiro)  
- **`ENTRADA`**: Fonte de entrada (TV, HDMI, Satélite, AV)  
- **`ENERGIA`**: Estado da TV (0 = desligada, 1 = ligada)  
- **`SLEEP`**: Temporizador regressivo até desligar  

### Modelo de Memória
- Sem memória endereçável além dos registradores  
- Contador de programa (PC) para execução sequencial  
- Labels e saltos condicionais  
- Blocos `{ ... }` para loops e modos  

### Modelo de Execução
- Execução sequencial  
- Condicionais baseados em comparação de valores  
- Loops controlados por `sleep(n){...}` ou condições `se(...)`  
- Definição de **modos nomeados** para reutilização de comportamento  

---

## 📝 Estrutura da Linguagem (EBNF)

```ebnf
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
