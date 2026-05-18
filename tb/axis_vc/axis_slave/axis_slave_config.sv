class axis_slave_config extends uvm_object;

    `uvm_object_utils(axis_slave_config)

    virtual axis_slave_driver_bfm #(DATA_W) drv_vbfm;
    virtual axis_slave_monitor_bfm #(DATA_W) mon_vbfm;

    uvm_active_passive_enum active = UVM_ACTIVE;

    int min_delay = 0;
    int max_delay = 5;

    tready_policy_e tready_policy = ALWAYS_HIGH;

    function new (string name = "axis_s_cfg") 
        super.new(name);
    endfunction

endclass