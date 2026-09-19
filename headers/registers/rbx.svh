// =============================================================================
// SPDX License Indentifier: GPL-3.0
// Copyright (C) Pedro Emanuel
// file : headers/registers/rbx.svh
// =============================================================================

`ifndef HEADERS_REGISTERS_RBX_SVH
`define HEADERS_REGISTERS_RBX_SVH

package rbx_pkg;

    // ------------------------------------------------------------------------
    // Definição de Modos de Acesso ao Registrador RBX (64-bit, 32-bit, 16-bit, 8-bit)
    // ------------------------------------------------------------------------
    typedef enum logic [2:0] {
        ACCESS_RBX = 3'b000, // Acesso completo de 64 bits (RBX)
        ACCESS_EBX = 3 me 3'b001, // Acesso aos 32 bits inferiores (EBX - limpa os 32 bits superiores)
        ACCESS_BX  = 3'b010, // Acesso aos 16 bits inferiores (BX)
        ACCESS_BH  = 3'b011, // Acesso aos bits [15:8] (BH)
        ACCESS_BL  = 3'b100  // Acesso aos bits [7:0]  (BL)
    } rbx_access_mode_e;

    // ------------------------------------------------------------------------
    // Estrutura representando os sub-registradores do RBX
    // ------------------------------------------------------------------------
    typedef struct packed {
        logic [31:0] high_dword; // Bits [63:32] (Apenas no modo 64-bit)
        logic [15:0] high_word;  // Bits [31:16] (Parte superior do EBX)
        logic [7:0]  bh;         // Bits [15:8]  (Registrador BH)
        logic [7:0]  bl;         // Bits [7:0]   (Registrador BL)
    } rbx_struct_t;

    // Union para mapear os sub-registradores em views de fácil acesso
    typedef union packed {
        logic [63:0] rbx;        // Visão completa de 64 bits
        logic [31:0] ebx;        // Visão dos 32 bits inferiores
        logic [15:0] bx;         // Visão dos 16 bits inferiores
        rbx_struct_t parts;      // Visão estruturada (BH, BL, etc.)
    } rbx_reg_u;

endpackage : rbx_pkg


// ============================================================================
// Interface do Registrador RBX
// ============================================================================
interface rbx_if (input logic clk, input logic rst_n);
    import rbx_pkg::*;

    logic               wr_en;        // Sinal de escrita
    rbx_access_mode_e   access_mode;  // Modo de acesso (RBX, EBX, BX, BH, BL)
    logic [63:0]        din;          // Dado de entrada
    logic [63:0]        dout;         // Dado de saída (valor atual do RBX)

    // Modport para o módulo registrador (Componente)
    modport Register (
        input  clk, rst_n, wr_en, access_mode, din,
        output dout
    );

    // Modport para quem vai controlar/acessar o registrador (Ex: Unidade Executora / CPU Core)
    modport Controller (
        output wr_en, access_mode, din,
        input  clk, rst_n, dout
    );
endinterface : rbx_if


// ============================================================================
// Declaração do Módulo do Registrador RBX (Sem Implementação)
// ============================================================================
module rbx_register (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   wr_en,
    input  rbx_pkg::rbx_access_mode_e access_mode,
    input  logic [63:0]            din,
    output logic [63:0]            dout
);
    // A implementação interna do módulo fica num arquivo .sv separado.
endmodule : rbx_register

`endif // RBX_REGISTER_PKG_SVH
