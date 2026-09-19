// ============================================================================
// File: headers/registers/rflags/cf.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the
//              logic of the Carry Flag bit (CF - RFLAGS[0]) and arithmetic/logical
//              operations involving unsigned overflow / shifts (Intel 64 / AMD64).
// ============================================================================

`ifndef RFLAGS_CF_SVH
`define RFLAGS_CF_SVH

package rflags_cf_pkg;
    localparam int RFLAGS_CF_BIT_INDEX = 0;

    // Modos de atualização do bit CF pela ALU ou instruções diretas (STC, CLC, CMC)
    typedef enum logic [2:0] {
        CF_OP_PASS        = 3'b000, // Mantém o valor atual do bit CF
        CF_OP_SET         = 3'b001, // Força o bit CF em 1 (ex: instrução STC)
        CF_OP_CLEAR       = 3'b010, // Zera o bit CF (0) (ex: instrução CLC, AND, OR, XOR)
        CF_OP_INVERT      = 3'b011, // Inverte o valor do bit CF (ex: instrução CMC)
        CF_OP_UPDATE_ALU  = 3 meb100, // Atualiza CF com o carry/borrow do MSB da ALU
        CF_OP_UPDATE_SHIFT= 3'b101  // Atualiza CF com o bit deslocado/rotacionado
    } cf_update_mode_e;

    // Estrutura de Entrada da ALU/Shift Unit para Cálculo de Carry/Borrow/Shift-out
    typedef struct packed {
        logic        carry_out_alu;   // Carry-out ou Borrow-out do bit mais significativo (MSB)
        logic        shift_out_bit;   // Bit ejetado durante operações de ROL, ROR, RCL, RCR, SHL, SHR
        logic        is_subtraction;  // Indica se a operação foi uma subtração/comparação
    } cf_alu_inputs_t;

    // Estrutura de Telemetria e Monitoramento do Bit CF
    typedef struct packed {
        logic cf_bit_value;    // Valor atual do RFLAGS.CF (bit 0)
        logic last_carry_out;  // Registra o último carry/borrow capturado da ALU
    } cf_telemetry_t;

endpackage : rflags_cf_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do Carry Flag (CF)
// ============================================================================
interface rflags_cf_if (
    input logic clk,
    input logic rst_n
);
    import rflags_cf_pkg::*;

    // Sinais de Controle
    logic               cf_write_en;   // Habilita escrita direta/atualização no bit CF
    cf_update_mode_e    update_mode;   // Modo de atualização (Set, Clear, Invert, ALU, Shift, Pass)
    logic               cf_direct_in;  // Valor de escrita direta no bit CF (ex: via POPF)
    logic               cf_out;        // Valor atual do bit CF
    
    // Interface com a ALU e Shifter Unit
    cf_alu_inputs_t     alu_inputs;
    
    // Telemetria
    cf_telemetry_t      telemetry;

    // Modport para o Submódulo do Bit CF
    modport CFUnit (
        input  clk, rst_n, cf_write_en, update_mode, cf_direct_in, alu_inputs,
        output cf_out, telemetry
    );

    // Modport para a ALU / Shifter / Unidade de Control / Microcódigo
    modport Controller (
        input  clk, rst_n, cf_out, telemetry,
        output cf_write_en, update_mode, cf_direct_in, alu_inputs
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, cf_write_en, update_mode, cf_direct_in, cf_out, alu_inputs, telemetry
    );
endinterface : rflags_cf_if


// ============================================================================
// Declaração do Módulo do Bit CF (Sem Implementação Interna)
// ============================================================================
module rflags_cf_bit (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          cf_write_en,
    input  rflags_cf_pkg::cf_update_mode_e update_mode,
    input  logic                          cf_direct_in,
    input  rflags_cf_pkg::cf_alu_inputs_t alu_inputs,
    output logic                          cf_out,
    output rflags_cf_pkg::cf_telemetry_t  telemetry
);

endmodule : rflags_cf_bit
`endif // RFLAGS_CF_SVH
