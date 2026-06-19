class rst_seq_base extends uvm_sequence #(rst_seq_item);

    `uvm_object_utils(rst_seq_base)

    rst_config rst_cfg;
    bit rst_cfg_ready;

    rand int duration;

    constraint c_duration {
        duration >= rst_cfg.min_duration;
        duration <= rst_cfg.max_duration;
    }

    function new (string name = "rst_seq");
        super.new(name);
    endfunction

    virtual function void get_config();
        if (!uvm_config_db #(rst_config)::get(null, "uvm_test_top.env.rst_m", "rst_cfg", rst_cfg)) begin
            `uvm_error("RST_SEQ", "Failed to get rst_config from config_db")
        end
        else begin
            rst_cfg_ready = 1;
        end
    endfunction

    function void pre_randomize();
        if (rst_cfg == null) get_config();
    endfunction

endclass