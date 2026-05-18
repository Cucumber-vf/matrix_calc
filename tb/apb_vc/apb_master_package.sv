package apb_master_package;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "apb_config.sv";
    `include "apb_driver.sv";
    `include "apb_monitor.sv";
    `include "apb_seq_item.sv";

    typedef uvm_sequencer #(apb_seq_item) apb_sequencer;

endpackage