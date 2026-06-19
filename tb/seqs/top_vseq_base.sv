class top_vseq_base #(parameter int N = 4, parameter int DATA_W = 16) extends uvm_sequence #(uvm_sequence_item);

    `uvm_object_param_utils(top_vseq_base #(N, DATA_W))

    const string report_id = "top_vseq_base";

    uvm_sequencer_base rst_sqr;
    uvm_sequencer_base apb_sqr;
    uvm_sequencer_base axis_m_sqr_a;
    uvm_sequencer_base axis_m_sqr_b;

    env_config env_cfg;
    bit env_cfg_ready;

    function new (string name = "top_vseq_base");
        super.new(name);
    endfunction

    virtual function void get_config();
        if (!uvm_config_db #(env_config)::get(null, "uvm_test_top.env", "env_cfg", env_cfg))
            `uvm_error(report_id, "Failed to get env_config")
        else 
            env_cfg_ready = 1;
    endfunction

    // ===========================
    // API with vectors database
    // =========================== 

    virtual function void get_vec_A(int test_id, output logic signed [DATA_W-1:0] matrix[N][N]);
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.vec_db.get_input_A(test_id, matrix);
    endfunction

    virtual function void get_vec_B(int test_id, output logic signed [DATA_W-1:0] matrix[N][N]);
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.vec_db.get_input_B(test_id, matrix);
    endfunction

    virtual function void push_chan_a(int id); 
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.vec_db.push_chan_a(id);
    endfunction

    virtual function void push_chan_b(int id); 
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.vec_db.push_chan_b(id);
    endfunction

    virtual function void mark_garbage_a(); 
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.vec_db.mark_garbage_a();
    endfunction

    virtual function void mark_garbage_b(); 
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.vec_db.mark_garbage_b();
    endfunction

    virtual function int get_tests_num();
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            return env_cfg.vec_db.get_tests_num();
    endfunction

    // ===========================

    virtual function bit get_rx_err_status();
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            return (env_cfg.ref_regs.apb_regs[REG_STATUS].value[RX_ERR]);
    endfunction

    // ===========================
    // API with monitors methods
    // =========================== 

    virtual task wait_for_clock (int n = 1);
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.clk_cfg.wait_for_clock(n);
    endtask

    virtual task wait_start_of_rst();
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.rst_cfg.wait_start_of_rst();
    endtask

    virtual task wait_end_of_rst();
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.rst_cfg.wait_end_of_rst();
    endtask

    virtual task wait_last_res_elem_hs();
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.axis_s_cfg.wait_last_elem_hs();
    endtask

    virtual task wait_res_elem_hs();
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.axis_s_cfg.wait_elem_hs();
    endtask

    virtual task wait_last_in0_elem_hs();
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.axis_m_cfg[0].wait_last_elem_hs();
    endtask

    virtual task wait_in0_elem_hs();
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.axis_m_cfg[0].wait_elem_hs();
    endtask

    virtual task wait_last_in1_elem_hs();
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.axis_m_cfg[1].wait_last_elem_hs();
    endtask

    virtual task wait_in1_elem_hs();
        if (env_cfg == null) get_config();
        if (env_cfg_ready)
            env_cfg.axis_m_cfg[1].wait_elem_hs();
    endtask

endclass