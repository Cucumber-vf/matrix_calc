class axis_master_config extends axis_config;

    `uvm_object_utils(axis_master_config)

    virtual axis_master_driver_bfm drv_vbfm;

    uvm_active_passive_enum active = UVM_ACTIVE;

    int min_txn_delay = 0;
    int max_txn_delay = 5;
    int early_tlast_chance = 10; // percentage

    function new (string name = "axis_m_cfg"); 
        super.new(name);
    endfunction

endclass