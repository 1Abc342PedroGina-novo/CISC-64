// ============================================================================
// File: headers/timer/timer.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for the Global Timer Unit (Top-Level
//              Timer Unit) aggregating the 8254 PIT, LAPIC Timer, and HPET (Intel 64 / AMD64).
// ============================================================================

`ifndef TIMER_TIMER_SVH
`define TIMER_TIMER_SVH

package timer_timer_pkg;

    typedef enum logic [1:0] {
        TIMER_MODE_ONE_SHOT = 2'b00,
        TIMER_MODE_PERIODIC = 2'b01,
        TIMER_MODE_TSC_DEADLINE = 2'b10
    } timer_mode_e;

    typedef struct packed {
        timer_mode_e mode;
        logic [31:0] initial_count;
        logic [31:0] current_count;
        logic        interrupt_mask;
    } timer_ctrl_t;

    typedef struct packed {
        logic timer_expired;
        logic irq_pending;
    } timer_status_t;

endpackage : timer_timer_pkg


interface timer_timer_if (
    input logic clk,
    input logic rst_n
);
    import timer_timer_pkg::*;

    logic          timer_enable;
    timer_ctrl_t   ctrl;
    timer_status_t status;
    logic          timer_irq;

    modport TimerCore (
        input  clk, rst_n, timer_enable, ctrl,
        output status, timer_irq
    );

    modport SystemBus (
        input  clk, rst_n, status, timer_irq,
        output timer_enable, ctrl
    );

    modport Monitor (
        input clk, rst_n, timer_enable, ctrl, status, timer_irq
    );
endinterface : timer_timer_if


module timer_top_unit (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     timer_enable,
    input  timer_timer_pkg::timer_ctrl_t ctrl,
    output timer_timer_pkg::timer_status_t status,
    output logic                     timer_irq
);
endmodule : timer_top_unit

`endif // TIMER_TIMER_SVH
