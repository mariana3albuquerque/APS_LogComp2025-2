#include "tvvm.h"


TVVM* tvvm_new(void) {
    TVVM* vm = calloc(1, sizeof(TVVM));
    tvvm_reset(vm);
    return vm;
}

void tvvm_free(TVVM* vm) {
    free(vm);
}

void tvvm_reset(TVVM* vm) {
    memset(vm, 0, sizeof(TVVM));
    vm->horario = 14;      // horário default
    vm->energia = 0;
    vm->pc      = 0;
    vm->sp      = 0;
    vm->halted  = 0;
    vm->steps   = 0;
    vm->program_size = 0;
    vm->label_count  = 0;
    vm->modo_atual[0] = '\0';
    // zera labels
    for (int i = 0; i < MAX_LABELS; i++) {
        vm->labels[i][0] = 0; // flag_existe
        vm->labels[i][1] = 0; // pos
    }
}

// hash simples para labels
static int hash_label(const char* s) {
    int h = 0;
    while (*s) {
        h = h * 31 + tolower((unsigned char)*s++);
    }
    if (h < 0) h = -h;
    return h % MAX_LABELS;
}

int tvvm_load_program(TVVM* vm, const char* filename) {
    FILE* f = fopen(filename, "r");
    if (!f) return -1;

    tvvm_reset(vm);

    char line[256];
    int line_idx = 0;

    // Primeira passada: coletar labels
    while (fgets(line, sizeof(line), f)) {
        char* comment = strchr(line, ';');
        if (comment) *comment = 0;
        char* end = line + strlen(line) - 1;
        while (end >= line && isspace((unsigned char)*end)) *end-- = 0;

        char* start = line;
        while (isspace((unsigned char)*start)) start++;

        if (!*start) continue;

        // linha com label: "nome:"
        size_t len = strlen(start);
        if (len > 0 && start[len-1] == ':') {
            char label[64];
            if (sscanf(start, "%63[^:]:", label) == 1) {
                int h = hash_label(label);
                vm->labels[h][0] = 1;       // existe
                vm->labels[h][1] = line_idx; // posição da próxima instrução
                vm->label_count++;
            }
        } else {
            // conta instrução
            line_idx++;
        }
    }

    // Segunda passada: parse das instruções
    rewind(f);
    vm->program_size = 0;
    while (fgets(line, sizeof(line), f) && vm->program_size < MAX_PROG) {
        char* comment = strchr(line, ';');
        if (comment) *comment = 0;
        char* end = line + strlen(line) - 1;
        while (end >= line && isspace((unsigned char)*end)) *end-- = 0;

        char* start = line;
        while (isspace((unsigned char)*start)) start++;

        if (!*start) continue;
        // ignora definição de label
        size_t len = strlen(start);
        if (len > 0 && start[len-1] == ':') continue;

        Instr* i = &vm->program[vm->program_size++];
        i->op[0] = i->args[0][0] = i->args[1][0] = '\0';
        // lê op e até 2 args
        sscanf(start, "%15s %31s %31s", i->op, i->args[0], i->args[1]);
        for (int j = 0; i->op[j]; j++) {
            i->op[j] = toupper((unsigned char)i->op[j]);
        }
    }

    fclose(f);
    return 0;
}

// mapeia nome de registrador para ID
static int get_reg_id(const char* reg) {
    if (!strcmp(reg, "CANAL"))   return 0;
    if (!strcmp(reg, "VOLUME"))  return 1;
    if (!strcmp(reg, "ENTRADA")) return 2;
    if (!strcmp(reg, "ENERGIA")) return 3;
    if (!strcmp(reg, "SLEEP"))   return 4;
    return -1;
}

static int* get_reg_ptr(TVVM* vm, int reg_id) {
    switch (reg_id) {
        case 0: return &vm->canal;
        case 1: return &vm->volume;
        case 2: return &vm->entrada;
        case 3: return &vm->energia;
        case 4: return &vm->sleep;
        default: return NULL;
    }
}

static int get_label_addr(TVVM* vm, const char* label) {
    int h = hash_label(label);
    if (vm->labels[h][0]) return vm->labels[h][1];
    return -1;
}

void tvvm_step(TVVM* vm) {
    if (vm->halted || vm->pc < 0 || vm->pc >= vm->program_size) {
        vm->halted = 1;
        return;
    }

    Instr* i = &vm->program[vm->pc];
    vm->steps++;

    if (!strcmp(i->op, "SET")) {
        int reg_id = get_reg_id(i->args[0]);
        int* reg = get_reg_ptr(vm, reg_id);
        if (reg) *reg = atoi(i->args[1]);
        vm->pc++;
    }
    else if (!strcmp(i->op, "INC")) {
        int reg_id = get_reg_id(i->args[0]);
        int* reg = get_reg_ptr(vm, reg_id);
        if (reg) (*reg)++;
        vm->pc++;
    }
    else if (!strcmp(i->op, "DEC")) {
        int reg_id = get_reg_id(i->args[0]);
        int* reg = get_reg_ptr(vm, reg_id);
        if (reg) (*reg)--;
        vm->pc++;
    }
    else if (!strcmp(i->op, "GOTO")) {
        int addr = get_label_addr(vm, i->args[0]);
        if (addr >= 0) vm->pc = addr;
        else vm->halted = 1;
    }
    else if (!strcmp(i->op, "CALL")) {
        // chamada de "função"/modo
        if (vm->sp < MAX_STACK - 1) {
            vm->stack[vm->sp++] = vm->pc + 1;
            int addr = get_label_addr(vm, i->args[0]);
            if (addr >= 0) {
                vm->pc = addr;
                // atualiza modo_atual para debug
                strncpy(vm->modo_atual, i->args[0], sizeof(vm->modo_atual) - 1);
                vm->modo_atual[sizeof(vm->modo_atual) - 1] = '\0';
            } else {
                vm->halted = 1;
            }
        } else {
            vm->halted = 1;
        }
    }
    else if (!strcmp(i->op, "RET")) {
        if (vm->sp > 0) {
            vm->pc = vm->stack[--vm->sp];
        } else {
            vm->halted = 1;
        }
        vm->modo_atual[0] = '\0'; // saiu do modo
    }
    else if (!strcmp(i->op, "PRINT")) {
        printf("[PRINT] Modo: %s | Canal=%d | Volume=%d | Energia=%d | Sleep=%d\n",
               vm->modo_atual[0] ? vm->modo_atual : "(sem modo)",
               vm->canal, vm->volume, vm->energia, vm->sleep);
        vm->pc++;
    }
    else if (!strcmp(i->op, "HALT")) {
        printf("TV desligada! BEEP!\n");
        vm->halted = 1;
    }
    else {
        // instrução desconhecida → ignora e avança
        fprintf(stderr, "Instrucao desconhecida: %s\n", i->op);
        vm->pc++;
    }
}

void tvvm_run(TVVM* vm, int max_steps) {
    int limit = (max_steps > 0) ? max_steps : 1000000;
    while (!vm->halted && vm->steps < limit) {
        tvvm_step(vm);
    }
    if (vm->halted) {
        printf("VM halted apos %d steps\n", vm->steps);
    } else {
        printf("VM parou por limite de steps (%d)\n", vm->steps);
    }
}

void tvvm_print_state(TVVM* vm) {
    printf("=== Estado TVVM ===\n");
    printf("Modo: %s\n", vm->modo_atual[0] ? vm->modo_atual : "(sem modo)");
    printf("CANAL=%d VOLUME=%d ENTRADA=%d ENERGIA=%d SLEEP=%d\n",
           vm->canal, vm->volume, vm->entrada, vm->energia, vm->sleep);
    printf("HORARIO=%d PC=%d STEPS=%d SP=%d HALTED=%d\n",
           vm->horario, vm->pc, vm->steps, vm->sp, vm->halted);
}
