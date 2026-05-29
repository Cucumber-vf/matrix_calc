class test_base extends uvm_test;
    
    `uvm_component_utils(test_base)

    matrix_calc_env    env;

    env_config         env_cfg;

    vectors_db_t       vec_db;
    regs_model         ref_regs;

    clk_config         clk_cfg;
    rst_config         rst_cfg;
    apb_config         apb_cfg;
    axis_master_config axis_m_a_cfg;
    axis_master_config axis_m_b_cfg;
    axis_slave_config  axis_s_cfg;

    function new (string name = "test_base", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        
        env = matrix_calc_env::type_id::create("env", this);

        env_cfg = env_config::type_id::create("env_cfg", this);

        vec_db = vectors_db_t::type_id::create("vec_db", this);
        env_cfg.vec_db = vec_db;
        ref_regs = regs_model::type_id::create("ref_regs", this);
        env_cfg.ref_regs = ref_regs;

        clk_cfg = clk_config::type_id::create("clk_cfg", this);
        if (!uvm_config_db #(virtual clk_bfm)::get(this, "", "clk_drv_bfm", clk_cfg.vbfm)) begin
            `uvm_fatal("BUILD_PHASE", "No clk_bfm found for clk_cfg")
        end
        configure_clk_agent (clk_cfg);
        env_cfg.clk_cfg = clk_cfg;

        rst_cfg = rst_config::type_id::create("rst_cfg", this);
        if (!uvm_config_db #(virtual rst_driver_bfm)::get(this, "", "rst_drv_bfm", rst_cfg.drv_vbfm)) begin
            `uvm_fatal("BUILD_PHASE", "No rst_drv_bfm found for rst_cfg")
        end
        if (!uvm_config_db #(virtual rst_monitor_bfm)::get(this, "", "rst_mon_bfm", rst_cfg.mon_vbfm)) begin
            `uvm_fatal("BUILD_PHASE", "No rst_mon_bfm found for rst_cfg")
        end
        configure_rst_agent (rst_cfg);
        env_cfg.rst_cfg = rst_cfg;
        
        apb_cfg = apb_config::type_id::create("apb_cfg", this);
        if (!uvm_config_db #(virtual apb_driver_bfm)::get(this, "", "apb_drv_bfm", apb_cfg.drv_vbfm)) begin
            `uvm_fatal("BUILD_PHASE", "No apb_drv_bfm found for apb_cfg")
        end
        if (!uvm_config_db #(virtual apb_monitor_bfm)::get(this, "", "apb_mon_bfm", apb_cfg.mon_vbfm)) begin
            `uvm_fatal("BUILD_PHASE", "No apb_mon_bfm found for apb_cfg")
        end
        configure_apb_agent (apb_cfg);
        env_cfg.apb_cfg = apb_cfg;

        axis_m_a_cfg = axis_master_config::type_id::create("axis_m_a_cfg", this);
        if (!uvm_config_db #(virtual axis_master_driver_bfm)::get(this, "", "axis_m_a_drv_bfm", axis_m_a_cfg.drv_vbfm)) begin
            `uvm_fatal("BUILD_PHASE", "No axis_drv_bfm found for axis_m_a_cfg")
        end
        if (!uvm_config_db #(virtual axis_monitor_bfm)::get(this, "", "axis_m_a_mon_bfm", axis_m_a_cfg.mon_vbfm)) begin
            `uvm_fatal("BUILD_PHASE", "No axis_mon_bfm found for axis_m_a_cfg")
        end
        configure_axis_master (axis_m_a_cfg);
        env_cfg.axis_m_a_cfg = axis_m_a_cfg;

        axis_m_b_cfg = axis_master_config::type_id::create("axis_m_b_cfg", this);
        if (!uvm_config_db #(virtual axis_master_driver_bfm)::get(this, "", "axis_m_b_drv_bfm", axis_m_b_cfg.drv_vbfm)) begin
            `uvm_fatal("BUILD_PHASE", "No axis_drv_bfm found for axis_m_b_cfg")
        end
        if (!uvm_config_db #(virtual axis_monitor_bfm)::get(this, "", "axis_m_b_mon_bfm", axis_m_b_cfg.mon_vbfm)) begin
            `uvm_fatal("BUILD_PHASE", "No axis_mon_bfm found for axis_m_b_cfg")
        end
        configure_axis_master (axis_m_b_cfg);
        env_cfg.axis_m_b_cfg = axis_m_b_cfg;

        axis_s_cfg = axis_slave_config::type_id::create("axis_s_cfg", this);
        if (!uvm_config_db #(virtual axis_slave_driver_bfm)::get(this, "", "axis_s_drv_bfm", axis_s_cfg.drv_vbfm)) begin
            `uvm_fatal("BUILD_PHASE", "No axis_drv_bfm found for axis_s_cfg")
        end
        if (!uvm_config_db #(virtual axis_monitor_bfm)::get(this, "", "axis_s_mon_bfm", axis_s_cfg.mon_vbfm)) begin
            `uvm_fatal("BUILD_PHASE", "No axis_mon_bfm found for axis_s_cfg")
        end
        configure_axis_slave (axis_s_cfg);
        env_cfg.axis_s_cfg = axis_s_cfg;

        uvm_config_db #(env_config)::set(this, "env", "env_cfg", env_cfg);

    endfunction

    function void end_of_elaboration_phase (uvm_phase phase);
        uvm_top.print_topology(); 
        uvm_config_db #(bit)::dump();
    endfunction

    virtual task run_phase (uvm_phase phase);
        `uvm_info(get_full_name(), "Hello world", UVM_NONE)
    endtask

    // ===========================
    // Init virtual sequence
    // =========================== 

    function void init_vseq (top_vseq_base_t vseq);
        vseq.rst_sqr      = env.rst_m.rst_sqr;
        vseq.apb_sqr      = env.apb_m.apb_sqr;
        vseq.axis_m_sqr_a = env.axis_m_a.axis_m_sqr;
        vseq.axis_m_sqr_b = env.axis_m_b.axis_m_sqr;
    endfunction

    // ===========================
    // Virtual configure functions
    // ===========================                
    virtual function void configure_clk_agent (clk_config clk_cfg);
        clk_cfg.create_clk_agent = 1;
        clk_cfg.period           = 10;
    endfunction

    virtual function void configure_rst_agent (rst_config rst_cfg);
        rst_cfg.active       = UVM_ACTIVE;
        rst_cfg.min_duration = 10;
        rst_cfg.max_duration = 50;
    endfunction

    virtual function void configure_apb_agent (apb_config apb_cfg);
        apb_cfg.active = UVM_ACTIVE;
    endfunction

    virtual function void configure_axis_master (axis_master_config axis_m_cfg);
        axis_m_cfg.active             = UVM_ACTIVE;
        axis_m_cfg.min_txn_delay      = 0;
        axis_m_cfg.max_txn_delay      = 5;
        axis_m_cfg.early_tlast_chance = 20;
    endfunction

    virtual function void configure_axis_slave (axis_slave_config axis_m_cfg);
        axis_s_cfg.min_active_dur   = 0;
        axis_s_cfg.max_active_dur   = 5;
        axis_s_cfg.min_inactive_dur = 0;
        axis_s_cfg.max_inactive_dur = 5;
        axis_s_cfg.tready_policy    = TOGGLE;
    endfunction

endclass