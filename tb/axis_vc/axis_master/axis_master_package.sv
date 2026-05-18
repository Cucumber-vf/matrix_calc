package axis_master_package;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import axis_params_package::*;

    `include "axis_master_config.sv";
    `include "axis_master_driver.sv";
    `include "axis_master_monitor.sv";
    `include "axis_seq_item.sv";

    typedef uvm_sequencer #(axis_seq_item) axis_sequencer;

endpackage