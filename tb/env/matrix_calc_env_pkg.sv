package matrix_calc_env_pkg;

    import uvm_pkg::*;

    import clk_agent_pkg::*;
    import rst_agent_pkg::*;
    import apb_master_pkg::*;
    import axis_master_pkg::*;
    import axis_slave_pkg::*;

    import tb_params_pkg::*;

    `include "apb_regs_def.svh"
    `include "regs_model.sv"

    `include "vectors_db.sv"
    typedef vectors_db #(TEST::N, AXIS::DATA_W) vectors_db_t;
    
    `include "env_config.sv"

    `include "matrix_calc_scrb.sv"
    typedef matrix_calc_scrb #(TEST::N, AXIS::DATA_W) matrix_calc_scrb_t;

    `include "matrix_calc_env.sv"

endpackage
