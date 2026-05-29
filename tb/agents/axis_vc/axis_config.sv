class axis_config extends uvm_object;

    `uvm_object_utils(axis_config)

    virtual axis_monitor_bfm mon_vbfm;

    function new (string name = "axis_cfg"); 
        super.new(name);
    endfunction

    task wait_last_elem;
        mon_vbfm.wait_last_elem();
    endtask

endclass