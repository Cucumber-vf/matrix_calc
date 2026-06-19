package tests_pkg;
    
    import uvm_pkg::*;
    import tb_params_pkg::CLK_PERIOD;
    
    import clk_agent_pkg  ::clk_config;
    import rst_agent_pkg  ::rst_config;
    import apb_master_pkg ::apb_config;
    import axis_master_pkg::axis_master_config;
    import axis_slave_pkg ::axis_slave_config;

    import matrix_calc_env_pkg::*;
    import seq_lib_pkg  ::*;

    `include "test_base.sv"
    `include "reg_test.sv"
    `include "mat_test.sv"
    `include "recv_features_test.sv"
    `include "flush_and_rst_test.sv"

endpackage