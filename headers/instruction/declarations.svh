/* SPDX-License-Identifier: BSD-3-Clause OR GPL-3.0 */
`ifndef INSTRUCTION_DECLARATIONS_SVH
`define INSTRUCTION_DECLARATIONS_SVH

package instruction_declaration_pkg;
  
package isa_opcodes_pkg;

    typedef enum logic [7:0] {
        OP_ADC = 8'h00, OP_ADD = 8'h01, OP_AND = 8'h02, OP_CALL = 8'h03,
        OP_CBW = 8'h04, OP_CDQE = 8'h05, OP_CLC = 8'h06, OP_CLD = 8'h07,
        OP_CMC = 8'h08, OP_CMP = 8'h09, OP_CMOV = 8'h0A, OP_CMPXCHG = 8'h0B,
        OP_CPUID = 8'h0C, OP_CPUNAME = 8'h0D, OP_CPUNR = 8'h0E, OP_DEC = 8'h0F,
        OP_DIV = 8'h10, OP_IDIV = 8'h11, OP_IMUL = 8'h12, OP_INC = 8'h13,
        OP_INT32 = 8'h14, OP_INT64 = 8'h15, OP_JCC = 8'h16, OP_JMP = 8'h17,
        OP_KECALL = 8'h18, OP_LEA = 8'h19, OP_LEAVE = 8'h1A, OP_LOOP = 8'h1B,
        OP_MOV = 8'h1C, OP_MOVSTR = 8'h1D, OP_MOVZX = 8'h1E, OP_NEG = 8'h1F,
        OP_NOP = 8'h20, OP_NOR = 8'h21, OP_OR = 8'h22, OP_POP = 8'h23,
        OP_POPF = 8'h24, OP_POPQ = 8'h25, OP_PUSH = 8'h26, OP_PUSHF = 8'h27,
        OP_PUSHQ = 8'h28, OP_RCL = 8'h29, OP_RCR = 8'h2A, OP_RET = 8'h2B,
        OP_ROL = 8'h2C, OP_ROR = 8'h2D, OP_SAHF = 8'h2E, OP_SAL = 8'h2F,
        OP_SAR = 8'h30, OP_SBB = 8'h31, OP_SCONSTR = 8'h32, OP_SETCC = 8'h33,
        OP_SHL = 8'h34, OP_SHR = 8'h35, OP_STD = 8'h36, OP_STC = 8'h37,
        OP_STORE = 8'h38, OP_STORESTR = 8'h39, OP_SUB = 8'h3A, OP_SYSCALL = 8'h3B,
        OP_SYSMGR = 8'h3C, OP_TEST = 8'h3D, OP_CHG = 8'h3E, OP_XLAT = 8'h3F,
        OP_XOR = 8'h40
    } opcode_e;

endpackage : isa_opcodes_pkg

package prefix_modrm_pkg;

    // Decodificação x86_64 Padrão
    typedef struct packed {
        logic lock;
        logic rep;
        logic op_override;  // 0x66
        logic addr_override; // 0x67
    } legacy_prefixes_t;

    typedef struct packed {
        logic active;
        logic w; // 64-bit operand
        logic r; // Extension reg
        logic x; // Extension index
        logic b; // Extension base/rm
    } rex_prefix_t;

    typedef struct packed {
        logic [1:0] mod;
        logic [2:0] reg_op;
        logic [2:0] rm;
    } modrm_t;

endpackage : prefix_modrm_pkg

package uop_structure_pkg;

    import isa_opcodes_pkg::*;

    // Destino no Pipeline de Execução (Modelo Híbrido ALU/AGU)
    typedef enum logic [2:0] {
        EXEC_PORT_ALU   = 3'b000, // Aritmética/Lógica Inteira
        EXEC_PORT_AGU   = 3'b001, // Address Generation Unit (Loads/Stores)
        EXEC_PORT_BRU   = 3'b010, // Branch Unit
        EXEC_PORT_MUL   = 3'b011, // Multiplicador/Divisor
        EXEC_PORT_SYS   = 3'b100  // System/Microcode Engine (SYSCALL, KECALL, CPUID)
    } exec_port_e;

    typedef enum logic [1:0] {
        SZ_8B  = 2'b00,
        SZ_16B = 2'b01,
        SZ_32B = 2'b10,
        SZ_64B = 2'b11
    } operand_size_e;

    // Estrutura do Micro-Op ($\mu$op) Unificado
    typedef struct packed {
        opcode_e       opcode;
        exec_port_e    port;         // Roteamento de Execução
        operand_size_e size;
        
        // Registradores Lógicos/Físicos (GPRs R0-R15)
        logic [4:0]    dst_reg;
        logic [4:0]    src1_reg;
        logic [4:0]    src2_reg;
        
        // Dados Imediatos e Deslocamento
        logic [63:0]   immediate;
        logic [63:0]   displacement;
        logic          has_imm;
        logic          has_disp;

        // Flags de Controle Híbridas
        logic          update_flags; // Atualização de RFLAGS
        logic          is_memory;    // Requer AGU para cálculo de memória
        logic          is_microcode; // Decodificado via ROM de Microcódigo
    } uop_t;

endpackage : uop_structure_pkg

`endif
