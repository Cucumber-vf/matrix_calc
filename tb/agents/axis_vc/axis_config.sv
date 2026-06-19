class axis_config extends uvm_object;

    `uvm_object_utils(axis_config)

    virtual axis_monitor_bfm mon_vbfm;

    int clk_period;
    
    function new (string name = "axis_cfg"); 
        super.new(name);
    endfunction

    task wait_last_elem_hs;
        mon_vbfm.wait_last_elem_hs();
    endtask

    task wait_elem_hs;
        mon_vbfm.wait_elem_hs();
    endtask

endclass