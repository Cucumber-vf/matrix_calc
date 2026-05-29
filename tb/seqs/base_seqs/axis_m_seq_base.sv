class axis_m_seq_base #(parameter DATA_W = 16) extends uvm_sequence #(axis_m_drv_seq_item #(DATA_W));

    `uvm_object_param_utils(axis_m_seq_base #(DATA_W))

    axis_master_config axis_m_cfg;
    bit axis_m_cfg_ready;

    rand logic signed [DATA_W - 1:0] tdata;
    rand bit                         is_last;
    rand int                         delay;

    constraint c_delay {
        delay >= axis_m_cfg.min_txn_delay;
        delay <= axis_m_cfg.max_txn_delay;
    }

    constraint c_is_last {
        is_last dist { 1 := axis_m_cfg.early_tlast_chance, 
                       0 := 100 - axis_m_cfg.early_tlast_chance };
    }

    function new (string name = "axis_m_seq");
        super.new(name);
    endfunction

    virtual function void get_config();
        if (!uvm_config_db #(axis_master_config)::get(null, "uvm_test_top.env.axis_m_a", "axis_m_cfg", axis_m_cfg)) begin
            `uvm_error("AXIS_M_SEQ", "Failed to get axis_master_config from config_db")
        end
        else begin
            axis_m_cfg_ready = 1;
        end
    endfunction

    function void pre_randomize();
        if (axis_m_cfg == null) get_config();
    endfunction

endclass