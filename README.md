# TVLang



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
```

---

## 📝 Instruction Set (TVLang)

| Instrução        | Exemplo                 | Descrição                           |
|------------------|-------------------------|-------------------------------------|
| **ligar**        | `ligar;`               | Liga a TV                           |
| **desligar**     | `desligar;`            | Desliga a TV e encerra execução     |
| **setar**        | `setar canal 12;`      | Define valor de registrador         |
| **aumentar**     | `aumentar volume;`     | Incrementa valor de registrador     |
| **diminuir**     | `diminuir volume;`     | Decrementa valor de registrador     |
| **sleep**        | `sleep(3){...}`        | Executa bloco até sleep zerar       |
| **se**           | `se (horario == 23h)`  | Executa instrução condicional       |
| **modo**         | `modo noturno {...}`   | Define um programa reutilizável     |

---

## 🚀 Quick Start

### Exemplo 1 — Código direto
```bash
ligar;
setar canal 12;
aumentar volume;
desligar;
```

---

### Exemplo 2 — Definição de modo noturno
```bash
modo noturno {
    ligar;
    setar canal 45;
    setar volume 5;
    se (horario == 23h): desligar;
}
```

---

### Exemplo 3 — Sleep timer (loop por tempo)
```bash
modo maratona {
    ligar;
    sleep(5) {
        aumentar volume;
        aumentar canal;
    }
    desligar;
}
```

---

### Exemplo 4 — Mistura de instruções soltas e modos
```bash
ligar;
setar canal 10;
desligar;

modo infantil {
    ligar;
    setar canal 34;
    setar volume 8;
}
```

---

## 📚 Teoria

TVLang é **Turing-complete**, pois:  
- possui registradores de tamanho arbitrário  
- permite loops (`sleep`, `se`) e saltos condicionais  
- suporta definição de blocos reutilizáveis (modos)  

---

 
