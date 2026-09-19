// ===========================================================================
// File: headers/registers/rflags/ac.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Declaration of packages, data types, bit structures,
// telemetry, interfaces and module signature for the logger
// RFLAGS, with special emphasis on the Alignment Check (AC) bit
// and state/control flags (Intel 64 / AMD64 Architecture).
// ===========================================================================

`ifndef RFLAGS_AC_SV
`define RFLAGS_AC_SV

package rflags_pkg;

    // ------------------------------------------------------------------------
    // Posições dos Bits no Registrador RFLAGS (x86_64 Layout)
    // ------------------------------------------------------------------------
    localparam int BIT_CF   = 0;  // Carry Flag
    localparam int BIT_PF   = 2;  // Parity Flag
    localparam int BIT_AF   = 4;  // Auxiliary Carry Flag
    localparam int BIT_ZF   = 6;  // Zero Flag
    localparam int BIT_SF   = 7;  // Sign Flag
    localparam int BIT_TF   = 8;  // Trap Flag
    localparam int BIT_IF   = 9;  // Interrupt Enable Flag
    localparam int BIT_DF   = 10; // Direction Flag
    localparam int BIT_OF   = 11; // Overflow Flag
    localparam int BIT_IOPL = 12; // I/O Privilege Level (2 bits: 13:12)
    localparam int BIT_NT   = 14; // Nested Task
    localparam int BIT_RF   = 16; // Resume Flag
    localparam int BIT_VM   = 17; // Virtual-8086 Mode
    localparam int BIT_AC   = 18; // Alignment Check / SMAP Access Check
    localparam int BIT_VIF  = 19; // Virtual Interrupt Flag
    localparam int BIT_VIP  = 20; // Virtual Interrupt Pending
    localparam int BIT_ID   = 21; // ID Flag (CPUID Instruction Support)

    // ------------------------------------------------------------------------
    // Mapeamento dos Modos de Acesso ao Registrador RFLAGS
    // ------------------------------------------------------------------------
    typedef enum logic [1:0] {
        RFLAGS_ACCESS_64BIT = 2'b00, // RFLAGS  : Acesso completo [63:0]
        RFLAGS_ACCESS_32BIT = 2'b01, // EFLAGS  : Acesso aos 32 bits inferiores [31:0]
        RFLAGS_ACCESS_16BIT = 2'b10  // FLAGS   : Acesso aos 16 bits inferiores [15:0]
    } rflags_access_mode_e;

    // ------------------------------------------------------------------------
    // Estrutura Detalhada dos Bits do RFLAGS (Packed Struct)
    // ------------------------------------------------------------------------
    typedef struct packed {
        logic [31:0] reserved_high; // Bits [63:32] - Reservados (devem ser mantidos em zero)
        logic [9:0]  reserved_22_31;// Bits [31:22] - Reservados
        logic        id;            // Bit  [21]    - ID Flag
        logic        vip;           // Bit  [20]    - Virtual Interrupt Pending
        logic        vif;           // Bit  [19]    - Virtual Interrupt Flag
        logic        ac;            // Bit  [18]    - Alignment Check (AC)
        logic        vm;            // Bit  [17]    - Virtual-8086 Mode
        logic        rf;            // Bit  [16]    - Resume Flag
        logic        reserved_15;   // Bit  [15]    - Reservado (0)
        logic        nt;            // Bit  [14]    - Nested Task
        logic [1:0]  iopl;          // Bits [13:12] - I/O Privilege Level
        logic        of;            // Bit  [11]    - Overflow Flag
        logic        df;            // Bit  [10]    - Direction Flag
        logic        if_val;        // Bit  [9]     - Interrupt Enable Flag
        logic        tf;            // Bit  [8]     - Trap Flag
        logic        sf;            // Bit  [7]     - Sign Flag
        logic        zf;            // Bit  [6]     - Zero Flag
        logic        reserved_5;    // Bit  [5]     - Reservado (0)
        logic        af;            // Bit  [4]     - Auxiliary Carry Flag
        logic        reserved_3;    // Bit  [3]     - Reservado (0)
        logic        pf;            // Bit  [2]     - Parity Flag
        logic        always_one;    // Bit  [1]     - Sempre 1 na arquitetura x86
        logic        cf;            // Bit  [0]     - Carry Flag
    } rflags_bits_t;

    // União para Visão de Palavra / Estrutura
    typedef union packed {
        logic [63:0]  raw;
        rflags_bits_t bits;
    } rflags_reg_u;

    // ------------------------------------------------------------------------
    // Estrutura de Telemetria e Status Específico do Bit AC
    // ------------------------------------------------------------------------
    typedef struct packed {
        logic        ac_enabled;      // Status direto do bit AC (RFLAGS[18])
        logic        alignment_fault; // Sinalizador de exceção #AC (Alignment Check Fault)
        logic [63:0] value;           // Valor atual do RFLAGS
    } rflags_status_t;

endpackage : rflags_pkg


// ============================================================================
// Interface SystemVerilog para o Registrador RFLAGS
// ============================================================================
interface rflags_if (
    input logic clk,
    input logic rst_n
);
    import rflags_pkg::*;

    // Sinais da Interface
    logic                 wr_en;
    rflags_access_mode_e  access_mode;
    logic [63:0]          din;
    logic [63:0]          dout;
    rflags_status_t       status;

    // Modport para o Registrador
    modport Register (
        input  clk,
        input  rst_n,
        input  wr_en,
        input  access_mode,
        input  din,
        output dout,
        output status
    );

    // Modport para a ALU / Unidade de Exceções / Decodificador
    modport Controller (
        input  clk,
        input  rst_n,
        output wr_en,
        output access_mode,
        output din,
        input  dout,
        input  status
    );

    // Modport para Monitor e Testbench
    modport Monitor (
        input clk,
        input rst_n,
        input wr_en,
        input access_mode,
        input din,
        input dout,
        input status
    );
endinterface : rflags_if


// ============================================================================
// Declaração do Módulo Principal (Sem Implementação Interna)
// ============================================================================
module rflags_register (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     wr_en,
    input  rflags_pkg::rflags_access_mode_e access_mode,
    input  logic [63:0]              din,
    output logic [63:0]              dout,
    output rflags_pkg::rflags_status_t status
);
    // A implementação da atualização das flags de condição (ALU status),
    // gravação via POPF/POPFD/POPFQ e geração de exceção #AC em desalinhamento
    // de memória deve ser mantida num arquivo separado (.sv).
endmodule : rflags_register

`endif // RFLAGS_AC_SV
