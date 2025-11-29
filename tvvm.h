#ifndef TVVM_H
#define TVVM_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PROG   1024
#define MAX_STACK  256
#define MAX_LABELS 128

typedef struct {
    char op[16];        // opcode: SET, INC, CALL, RET, GOTO, PRINT, HALT, ...
    char args[2][32];   // até 2 argumentos (reg, valor, label, nome de modo)
} Instr;

typedef struct {
    // "registradores" da TV
    int canal;
    int volume;
    int entrada;
    int energia;
    int sleep;

    // sensor read-only
    int horario;

    // programa carregado
    Instr program[MAX_PROG];
    int   pc;
    int   program_size;

    // tabela de labels: [flag_existe, posição_no_programa]
    int labels[MAX_LABELS][2];
    int label_count;

    // pilha para CALL/RET
    int stack[MAX_STACK];
    int sp;

    // estado de execução
    int halted;
    int steps;

    // nome do "modo" atual (para debug / impressão)
    char modo_atual[32];
} TVVM;

// criação / destruição
TVVM* tvvm_new(void);
void   tvvm_free(TVVM* vm);

// carga de programa .asm
int  tvvm_load_program(TVVM* vm, const char* filename);

// controle da VM
void tvvm_reset(TVVM* vm);
void tvvm_run(TVVM* vm, int max_steps);
void tvvm_step(TVVM* vm);

// debug
void tvvm_print_state(TVVM* vm);

#endif
