// ============================================================================
// File: headers/registers/r8.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Unified declaration of packages, data types, structures,
//              masks, telemetry, interfaces, and module signatures for the
//              64-bit extended registers (R8 through R15) of the
//              Intel 64 / AMD64 architecture.
// ============================================================================

`ifndef __HEADERS_REGISTERS_R8_SV__
`define __HEADERS_REGISTERS_R8_SV__

package r8_r15_pkg;

    // ------------------------------------------------------------------------
    // Enumeração do Índice do Registrador Estendido (R8d-R15d, R8w-R15w, R8b-R15b)
    // ------------------------------------------------------------------------
    typedef enum logic [3:0] {
        REG_R8  = 4'h8,
        REG_R9  = 4'h9,
        REG_R10 = 4'hA,
        REG_R11 = 4'hB,
        REG_R12 = 4'hC,
        REG_R13 = 4'hD,
        REG_R14 = 4'hE,
        REG_R15 = 4'hF
    } r_ext_id_e;

    // ------------------------------------------------------------------------
    // Modos de Acesso Genéricos para Registradores R8-R15
    // ------------------------------------------------------------------------
    typedef enum logic [1:0] {
        EXT_ACCESS_64BIT = 2'b00, // R8-R15   : Acesso completo [63:0]
        EXT_ACCESS_32BIT = 2'b01, // R8D-R15D : Acesso [31:0] (Zera bits superiores [63:32])
        EXT_ACCESS_16BIT = 2'b10, // R8W-R15W : Acesso [15:0] (Preserva bits superiores)
        EXT_ACCESS_8BIT  = 2'b11  // R8B-R15B : Acesso [7:0]  (Preserva bits superiores)
    } ext_access_mode_e;

    // ------------------------------------------------------------------------
    // Máscaras de Bits Genéricas
    // ------------------------------------------------------------------------
    localparam logic [63:0] EXT_MASK_64BIT = 64'hFFFF_FFFF_FFFF_FFFF;
    localparam logic [63:0] EXT_MASK_32BIT = 64'h0000_0000_FFFF_FFFF;
    localparam logic [63:0] EXT_MASK_16BIT = 64'h0000_0000_0000_FFFF;
    localparam logic [63:0] EXT_MASK_8BIT  = 64'h0000_0000_0000_00FF;

    // ------------------------------------------------------------------------
    // Estrutura Genérica de Decomposição de Bits para R8..R15
    // ------------------------------------------------------------------------
    typedef struct packed {
        logic [31:0] high_dword; // Bits [63:32]
        logic [15:0] high_word;  // Bits [31:16]
        logic [7:0]  high_byte;  // Bits [15:8]
        logic [7:0]  low_byte;   // Bits [7:0]  (R8B .. R15B)
    } ext_reg_fields_t;

    typedef struct packed {
        logic [7:0] byte7; // Bits [63:56]
        logic [7:0] byte6; // Bits [55:48]
        logic [7:0] byte5; // Bits [47:40]
        logic [7:0] byte4; // Bits [39:32]
        logic [7:0] byte3; // Bits [31:24]
        logic [7:0] byte2; // Bits [23:16]
        logic [7:0] byte1; // Bits [15:8]
        logic [7:0] byte0; // Bits [7:0]
    } ext_reg_byte_map_t;

    typedef union packed {
        logic [63:0]        r_qword; // Visão 64-bit (R8 .. R15)
        logic [31:0]        r_dword; // Visão 32-bit (R8D .. R15D)
        logic [15:0]        r_word;  // Visão 16-bit (R8W .. R15W)
        logic [7:0]         r_byte;  // Visão 8-bit  (R8B .. R15B)
        ext_reg_fields_t    fields;
        ext_reg_byte_map_t  bytes;
    } ext_reg_u;

    // Telemetria Comum
    typedef struct packed {
        logic        is_zero;
        logic        is_negative;
        logic [63:0] value;
    } ext_reg_status_t;

endpackage : r8_r15_pkg


// ============================================================================
// Macro para Geração Dinâmica de Interfaces por Registrador (R8 a R15)
// ============================================================================
`define DEFINE_EXT_REG_INTERFACE(REG_NAME) \
interface ``REG_NAME``_if ( \
    input logic clk, \
    input logic rst_n \
); \
    import r8_r15_pkg::*; \
    logic               wr_en; \
    ext_access_mode_e   access_mode; \
    logic [63:0]        din; \
    logic [63:0]        dout; \
    ext_reg_status_t    status; \
    \
    modport Register ( \
        input  clk, rst_n, wr_en, access_mode, din, \
        output dout, status \
    ); \
    modport Controller ( \
        input  clk, rst_n, dout, status, \
        output wr_en, access_mode, din \
    ); \
    modport Monitor ( \
        input clk, rst_n, wr_en, access_mode, din, dout, status \
    ); \
endinterface : ``REG_NAME``_if

// Declaração individual das interfaces
`DEFINE_EXT_REG_INTERFACE(r8)
`DEFINE_EXT_REG_INTERFACE(r9)
`DEFINE_EXT_REG_INTERFACE(r10)
`DEFINE_EXT_REG_INTERFACE(r11)
`DEFINE_EXT_REG_INTERFACE(r12)
`DEFINE_EXT_REG_INTERFACE(r13)
`DEFINE_EXT_REG_INTERFACE(r14)
`DEFINE_EXT_REG_INTERFACE(r15)

`undef DEFINE_EXT_REG_INTERFACE


// ============================================================================
// Assinaturas Individuais dos Módulos (R8 até R15)
// ============================================================================

module r8_register (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     wr_en,
    input  r8_r15_pkg::ext_access_mode_e access_mode,
    input  logic [63:0]              din,
    output logic [63:0]              dout,
    output r8_r15_pkg::ext_reg_status_t status
);
endmodule : r8_register

module r9_register (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     wr_en,
    input  r8_r15_pkg::ext_access_mode_e access_mode,
    input  logic [63:0]              din,
    output logic [63:0]              dout,
    output r8_r15_pkg::ext_reg_status_t status
);
endmodule : r9_register

module r10_register (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     wr_en,
    input  r8_r15_pkg::ext_access_mode_e access_mode,
    input  logic [63:0]              din,
    output logic [63:0]              dout,
    output r8_r15_pkg::ext_reg_status_t status
);
endmodule : r10_register

module r11_register (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     wr_en,
    input  r8_r15_pkg::ext_access_mode_e access_mode,
    input  logic [63:0]              din,
    output logic [63:0]              dout,
    output r8_r15_pkg::ext_reg_status_t status
);
endmodule : r11_register

module r12_register (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     wr_en,
    input  r8_r15_pkg::ext_access_mode_e access_mode,
    input  logic [63:0]              din,
    output logic [63:0]              dout,
    output r8_r15_pkg::ext_reg_status_t status
);
endmodule : r12_register

module r13_register (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     wr_en,
    input  r8_r15_pkg::ext_access_mode_e access_mode,
    input  logic [63:0]              din,
    output logic [63:0]              dout,
    output r8_r15_pkg::ext_reg_status_t status
);
endmodule : r13_register

module r14_register (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     wr_en,
    input  r8_r15_pkg::ext_access_mode_e access_mode,
    input  logic [63:0]              din,
    output logic [63:0]              dout,
    output r8_r15_pkg::ext_reg_status_t status
);
endmodule : r14_register

module r15_register (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     wr_en,
    input  r8_r15_pkg::ext_access_mode_e access_mode,
    input  logic [63:0]              din,
    output logic [63:0]              dout,
    output r8_r15_pkg::ext_reg_status_t status
);
endmodule : r15_register

`endif // __HEADERS_REGISTERS_RAX_SV__
