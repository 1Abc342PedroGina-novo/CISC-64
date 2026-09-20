// ============================================================================
// File: header/timer/tick.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for generating the base Tick event
//              and the central timer frequency divider (e.g., PIT 8254 / HPET Tick).
// ============================================================================

`ifndef TIMER_TICK_SVH
`define TIMER_TICK_SVH

package timer_tick_pkg;

    typedef struct packed {
        logic [31:0] divisor;    // Divisor do clock de entrada
        logic        enable;     // Habilita a contagem de ticks
    } tick_config_t;

    typedef struct packed {
        logic [63:0] tick_count; // Total acumulado de ticks
        logic        tick_event; // Pulso de 1 ciclo no disparo de cada tick
    } tick_status_t;

endpackage : timer_tick_pkg


interface timer_tick_if (
    input logic clk,
    input logic rst_n
);
    import timer_tick_pkg::*;

    tick_config_t cfg;
    tick_status_t status;

    modport Generator (
        input  clk, rst_n, cfg,
        output status
    );

    modport Subscriber (
        input  clk, rst_n, status,
        output cfg
    );

    modport Monitor (
        input clk, rst_n, cfg, status
    );
endinterface : timer_tick_if


module timer_tick_generator (
    input  logic                     clk,
    input  logic                     rst_n,
    input  timer_tick_pkg::tick_config_t cfg,
    output timer_tick_pkg::tick_status_t status
);
endmodule : timer_tick_generator

`endif // TIMER_TICK_SVH
