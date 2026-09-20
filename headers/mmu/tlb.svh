// ============================================================================
// File:  headers/mmu/tlb.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated to the Translation Lookaside Buffer
//              (TLB L1/L2) for accelerated virtual-to-physical address translation
//              (Intel 64 / AMD64).
// ============================================================================

`ifndef MMU_TLB_SVH
`define MMU_TLB_SVH

package mmu_tlb_pkg;

    localparam int VIRT_ADDR_WIDTH = 48;
    localparam int PHYS_ADDR_WIDTH = 52;

    typedef enum logic [1:0] {
        TLB_PAGE_4K  = 2'b00,
        TLB_PAGE_2M  = 2'b01,
        TLB_PAGE_1G  = 2'b10
    } page_size_e;

    typedef struct packed {
        logic                    valid;
        logic                    global_page;
        logic                    user_supervisor; // U/S
        logic                    read_write;      // R/W
        logic                    no_execute;      // NX/XD
        page_size_e              pg_size;
        logic [PHYS_ADDR_WIDTH-1:12] pfn;
    } tlb_entry_t;

    typedef struct packed {
        logic                    hit;
        logic                    miss;
        logic [PHYS_ADDR_WIDTH-1:12] pfn;
        logic                    page_fault;
    } tlb_lookup_resp_t;

endpackage : mmu_tlb_pkg


interface mmu_tlb_if (
    input logic clk,
    input logic rst_n
);
    import mmu_tlb_pkg::*;

    logic                     lookup_en;
    logic [VIRT_ADDR_WIDTH-1:12] vpn;
    tlb_lookup_resp_t         resp;

    // Sinais para Invalidação (ex: INVLPG ou escrita em CR3)
    logic                     flush_all;
    logic                     invlpg_en;
    logic [VIRT_ADDR_WIDTH-1:12] invlpg_vpn;

    modport TLBUnit (
        input  clk, rst_n, lookup_en, vpn, flush_all, invlpg_en, invlpg_vpn,
        output resp
    );

    modport MMU (
        input  clk, rst_n, resp,
        output lookup_en, vpn, flush_all, invlpg_en, invlpg_vpn
    );

    modport Monitor (
        input clk, rst_n, lookup_en, vpn, resp, flush_all, invlpg_en, invlpg_vpn
    );
endinterface : mmu_tlb_if


module mmu_tlb_unit (
    input  logic                             clk,
    input  logic                             rst_n,
    input  logic                             lookup_en,
    input  logic [47:12]                     vpn,
    input  logic                             flush_all,
    input  logic                             invlpg_en,
    input  logic [47:12]                     invlpg_vpn,
    output mmu_tlb_pkg::tlb_lookup_resp_t    resp
);
endmodule : mmu_tlb_unit

`endif // MMU_TLB_SVH
