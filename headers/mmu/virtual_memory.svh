// ============================================================================
// File: headers/mmu/virtual_memory.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for controlling 4-level /
//              5-level paging (PML4, PDPT, PD, PT) and virtual memory
//              management (Intel 64 / AMD64).
// ============================================================================

`ifndef MMU_VIRTUAL_MEMORY_SVH
`define MMU_VIRTUAL_MEMORY_SVH

package mmu_virtual_memory_pkg;

    localparam int VIRT_ADDR_WIDTH = 48;
    localparam int PHYS_ADDR_WIDTH = 52;

    typedef enum logic [1:0] {
        VM_ACCESS_READ  = 2'b00,
        VM_ACCESS_WRITE = 2'b01,
        VM_ACCESS_EXEC  = 2'b10
    } vm_access_type_e;

    typedef struct packed {
        logic [8:0] pml4_idx; // vaddr[47:39]
        logic [8:0] pdpt_idx; // vaddr[38:30]
        logic [8:0] pd_idx;   // vaddr[29:21]
        logic [8:0] pt_idx;   // vaddr[20:12]
        logic [11:0] offset;  // vaddr[11:0]
    } virt_addr_split_t;

    typedef struct packed {
        logic                     page_fault;
        logic [PHYS_ADDR_WIDTH-1:0] paddr;
        logic [31:0]              error_code; // Error code para exceção #PF
    } vm_translation_resp_t;

endpackage : mmu_virtual_memory_pkg


interface mmu_virtual_memory_if (
    input logic clk,
    input logic rst_n
);
    import mmu_virtual_memory_pkg::*;

    logic                     trans_req;
    logic [VIRT_ADDR_WIDTH-1:0] vaddr;
    vm_access_type_e          access_type;
    logic [1:0]               cpl;
    logic [PHYS_ADDR_WIDTH-1:12] cr3_pfn; // Registrador CR3 (Base da tabela PML4)
    vm_translation_resp_t     resp;

    modport PageTableWalker (
        input  clk, rst_n, trans_req, vaddr, access_type, cpl, cr3_pfn,
        output resp
    );

    modport MMU (
        input  clk, rst_n, resp,
        output trans_req, vaddr, access_type, cpl, cr3_pfn
    );

    modport Monitor (
        input clk, rst_n, trans_req, vaddr, access_type, cpl, cr3_pfn, resp
    );
endinterface : mmu_virtual_memory_if


module mmu_page_table_walker (
    input  logic                                      clk,
    input  logic                                      rst_n,
    input  logic                                      trans_req,
    input  logic [47:0]                               vaddr,
    input  mmu_virtual_memory_pkg::vm_access_type_e   access_type,
    input  logic [1:0]                                cpl,
    input  logic [51:12]                              cr3_pfn,
    output mmu_virtual_memory_pkg::vm_translation_resp_t resp
);
endmodule : mmu_page_table_walker

`endif // MMU_VIRTUAL_MEMORY_SVH
