class env_config extends uvm_object;

    `uvm_object_utils(env_config)

    clk_config  clk_cfg;
    rst_config  rst_cfg;
    apb_config  apb_cfg;
    axis_master_config axis_m_a_cfg;
    axis_master_config axis_m_b_cfg;
    axis_slave_config axis_s_cfg;
    
    vectors_db_t vec_db;
    regs_model ref_regs;

    function new (name = "env_cfg"); 
        super.new(name);
    endfunction

endclass