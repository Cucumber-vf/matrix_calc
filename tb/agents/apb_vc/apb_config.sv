class apb_config extends uvm_object;

    `uvm_object_utils(apb_config)

    virtual apb_driver_bfm  drv_vbfm;
    virtual apb_monitor_bfm mon_vbfm;

    uvm_active_passive_enum active = UVM_ACTIVE;

    function new (string name = "apb_cfg"); 
        super.new(name);
    endfunction

endclass