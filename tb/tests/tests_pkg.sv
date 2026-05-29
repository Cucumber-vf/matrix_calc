package tests_pkg;
    
    import uvm_pkg::*;
    
    import clk_agent_pkg::clk_config;
    import rst_agent_pkg::rst_config;
    import apb_master_pkg::apb_config;
    import axis_master_pkg::axis_master_config;
    import axis_slave_pkg::axis_slave_config;

    import test_base_pkg::*;
    import seq_lib_pkg::*;

    `include "test_test.sv"
    `include "reg_test.sv"
    `include "mat_test.sv"

endpackage