#include "tvvm.h"
#include <stdio.h>

int main(int argc, char** argv) {
    if (argc < 2) {
        printf("Uso: %s programa.asm\n", argv[0]);
        printf("Exemplo: %s teste.asm\n", argv[0]);
        return 1;
    }
    
    TVVM* vm = tvvm_new();
    if (tvvm_load_program(vm, argv[1]) < 0) {
        fprintf(stderr, "Erro ao carregar %s\n", argv[1]);
        tvvm_free(vm);
        return 1;
    }
    
    printf("Programa '%s' carregado (%d instrs)\n", argv[1], vm->program_size);
    tvvm_print_state(vm);
    printf("\n--- Executando ---\n");
    
    tvvm_run(vm, 10000);
    tvvm_print_state(vm);
    
    tvvm_free(vm);
    return 0;
}
