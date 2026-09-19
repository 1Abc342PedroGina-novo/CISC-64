`ifndef RBX_SV
`define RBX_SV

package rbx_defs_pkg;

    // 1. Enumeração dos Sub-registradores do RBX
    // Mapeia exatamente como o decodificador CISC ou as uops RISC enxergam as subdivisões
    typedef enum logic [2:0] {
        RBX_FULL  = 3'b000,  // RBX (64 bits - Escrita/Leitura total)
        EBX_DWORD = 3'b001,  // EBX (32 bits - ATENÇÃO: Zera os 32 bits superiores)
        BX_WORD   = 3'b010,  // BX  (16 bits - Preserva o restante do registrador)
        BH_BYTE   = 3'b011,  // BH  (Bits 15:8 - Preserva o restante do registrador)
        BL_BYTE   = 3'b100   // BL  (Bits 7:0  - Preserva o restante do registrador)
    } rbx_subreg_sel_e;

    // 2. Estrutura de Comando de Micro-operação (uop) para o RBX
    // Esta estrutura é o que o seu decodificador envia para o módulo do registrador
    typedef struct packed {
        logic               uop_valid;   // Indica se a uop atual vai escrever no RBX
        rbx_subreg_sel_e    uop_sel;     // Qual porção do RBX a uop está modificando
        logic [63:0]        uop_data;    // Dado vindo da sua unidade de execução RISC
    } rbx_uop_ctrl_t;

    // 3. Estrutura de Visualização Arquitetural (Para fins de Debug/Simulação)
    // Permite que ferramentas de simulação ou o próprio processador leiam as partes do RBX
    typedef struct packed {
        logic [63:0] rbx;  // Conteúdo completo de 64 bits
        logic [31:0] ebx;  // Bits [31:0]
        logic [15:0] bx;   // Bits [15:0]
        logic [7:0]  bh;   // Bits [15:8]
        logic [7:0]  bl;   // Bits [7:0]
    } rbx_view_t;

endpackage

`endif // RBX_DEFS_SVH
