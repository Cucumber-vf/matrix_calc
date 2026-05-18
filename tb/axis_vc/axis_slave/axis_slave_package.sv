package axis_slave_package;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import axis_params_package::*;

    `include "axis_slave_config.sv";
    `include "axis_slave_driver.sv";
    `include "axis_slave_monitor.sv";
    `include "axis_seq_item.sv";

    typedef uvm_sequencer #(axis_seq_item) axis_sequencer;

    typedef enum {ALWAYS_HIGH, TOGGLE} tready_policy_e;

endpackage