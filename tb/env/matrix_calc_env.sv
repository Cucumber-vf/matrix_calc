class matrix_calc_env extends uvm_env;

    `uvm_component_utils(matrix_calc_env)

    env_config env_cfg;

    clk_agent clk_m;
    rst_agent rst_m;

    apb_agent apb_m;
    axis_master_agent axis_m_a;
    axis_master_agent axis_m_b;
    axis_slave_agent axis_s;

    matrix_calc_scrb_t scrb;

    function new (string name = "matrix_calc_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if(!uvm_config_db #(env_config)::get(this, "", "env_cfg", env_cfg)) begin
            `uvm_fatal("BUILD_PHASE", "No env_cfg found for environment")
        end
        
        scrb = matrix_calc_scrb_t::type_id::create("scrb", this);
        uvm_config_db #(env_config)::set(this, "scrb", "env_cfg", env_cfg);

        if (env_cfg.clk_cfg.create_clk_agent) begin
            clk_m = clk_agent::type_id::create("clk_m", this);
            uvm_config_db #(clk_config)::set(this, "clk_m*", "clk_cfg", env_cfg.clk_cfg);
        end

        rst_m = rst_agent::type_id::create("rst_m", this);
        uvm_config_db #(rst_config)::set(this, "rst_m*", "rst_cfg", env_cfg.rst_cfg);

        apb_m = apb_agent::type_id::create("apb_m", this);
        uvm_config_db #(apb_config)::set(this, "apb_m*", "apb_cfg", env_cfg.apb_cfg);

        axis_m_a = axis_master_agent::type_id::create("axis_m_a", this);
        uvm_config_db #(axis_master_config)::set(this, "axis_m_a*", "axis_m_cfg", env_cfg.axis_m_a_cfg);

        axis_m_b = axis_master_agent::type_id::create("axis_m_b", this);
        uvm_config_db #(axis_master_config)::set(this, "axis_m_b*", "axis_m_cfg", env_cfg.axis_m_b_cfg);

        axis_s = axis_slave_agent::type_id::create("axis_s", this);
        uvm_config_db #(axis_slave_config)::set(this, "axis_s*", "axis_s_cfg", env_cfg.axis_s_cfg);
    endfunction

    function void connect_phase (uvm_phase phase);
        rst_m.rst_ap.connect(scrb.rst_exp);
        apb_m.apb_ap.connect(scrb.apb_exp);
        axis_m_a.axis_m_ap.connect(scrb.axis_in_a_exp);
        axis_m_b.axis_m_ap.connect(scrb.axis_in_b_exp);
        axis_s.axis_s_ap.connect(scrb.axis_out_exp);
    endfunction

endclass