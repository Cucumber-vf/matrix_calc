class axis_slave_config extends axis_config;

    `uvm_object_utils(axis_slave_config)

    virtual axis_slave_driver_bfm drv_vbfm;

    int min_active_dur = 0;
    int max_active_dur = 5;

    int min_inactive_dur = 0;
    int max_inactive_dur = 5;

    tready_policy_e tready_policy = ALWAYS_HIGH;

    function new (string name = "axis_s_cfg"); 
        super.new(name);
    endfunction

endclass