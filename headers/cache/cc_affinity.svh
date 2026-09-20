// ============================================================================
// File: headers/cache/cc_affinity.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for managing coherence affinity
//              and line routing between cache banks/NUMA cores.
// ============================================================================

`ifndef CACHE_CC_AFFINITY_SVH
`define CACHE_CC_AFFINITY_SVH

package cache_cc_affinity_pkg;

    localparam int MAX_NUMA_NODES = 4;
    localparam int MAX_CORES_PER_NODE = 8;

    typedef struct packed {
        logic [1:0] node_id;
        logic [2:0] core_id;
        logic [2:0] cache_bank_id;
    } affinity_route_t;

    typedef struct packed {
        logic local_hit;
        logic remote_numa_req;
        logic [1:0] target_node;
    } affinity_status_t;

endpackage : cache_cc_affinity_pkg


interface cache_cc_affinity_if (
    input logic clk,
    input logic rst_n
);
    import cache_cc_affinity_pkg::*;

    logic [51:6]        line_paddr;
    affinity_route_t    route_info;
    affinity_status_t   status;

    modport Router (
        input  clk, rst_n, line_paddr, route_info,
        output status
    );

    modport Controller (
        input  clk, rst_n, status,
        output line_paddr, route_info
    );

    modport Monitor (
        input clk, rst_n, line_paddr, route_info, status
    );
endinterface : cache_cc_affinity_if


module cache_cc_affinity_router (
    input  logic                                clk,
    input  logic                                rst_n,
    input  logic [51:6]                         line_paddr,
    input  cache_cc_affinity_pkg::affinity_route_t route_info,
    output cache_cc_affinity_pkg::affinity_status_t status
);
endmodule : cache_cc_affinity_router

`endif // CACHE_CC_AFFINITY_SVH
