class rst_config extends uvm_object;

    `uvm_object_utils(rst_config)

    virtual rst_driver_bfm drv_vbfm;
    virtual rst_monitor_bfm mon_vbfm;

    int min_duration = 10;
    int max_duration = 50;

    int min_delay = 1000;
    int max_delay = 3000;

    function new (string name = "rst_cfg") 
        super.new(name);
    endfunction

endclass