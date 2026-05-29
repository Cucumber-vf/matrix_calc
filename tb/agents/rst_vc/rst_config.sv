class rst_config extends uvm_object;

    `uvm_object_utils(rst_config)

    virtual rst_driver_bfm drv_vbfm;
    virtual rst_monitor_bfm mon_vbfm;

    int min_duration = 10;
    int max_duration = 50;

    uvm_active_passive_enum active = UVM_ACTIVE;

    function new (string name = "rst_cfg"); 
        super.new(name);
    endfunction

    task wait_start_of_rst;
        mon_vbfm.wait_start_of_rst();
    endtask

    task wait_end_of_rst;
        mon_vbfm.wait_end_of_rst();
    endtask

endclass