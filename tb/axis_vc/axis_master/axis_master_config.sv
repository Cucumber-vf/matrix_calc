class axis_master_config extends uvm_object;

    `uvm_object_utils(axis_master_config)

    virtual axis_master_driver_bfm #(DATA_W) drv_vbfm;
    virtual axis_master_monitor_bfm #(DATA_W) mon_vbfm;

    uvm_active_passive_enum active = UVM_ACTIVE;

    int min_delay = 0;
    int max_delay = 5;
    int early_tlast_chance = 20; // percentage

    function new (string name = "axis_m_cfg") 
        super.new(name);
    endfunction

endclass