class axis_slave_driver extends uvm_driver #(axis_seq_item);

    `uvm_component_utils(axis_slave_driver)

    axis_slave_config axis_s_cfg;
    virtual axis_slave_driver_bfm #(DATA_W) vbfm;

    function new (string name = "axis_slave_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if (axis_s_cfg == null) begin
            if (!uvm_config_db #(axis_slave_config)::get(this, " ", "axis_s_cfg", axis_s_cfg)) begin
                `uvm_fatal("BUILD_PHASE", "No axis_s_cfg found for driver")
            end
        end
        vbfm = axis_s_cfg.drv_vbfm;
    endfunction

    task run_phase (uvm_phase phase);
        vbfm.drive(axis_s_cfg.tready_policy, axis_s_cfg.min_delay, axis_s_cfg.max_delay);
    endtask

endclass