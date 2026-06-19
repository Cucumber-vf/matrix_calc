class axis_m_send_seq #(parameter DATA_W = 16) extends axis_m_seq_base #(DATA_W);

    `uvm_object_param_utils(axis_m_send_seq #(DATA_W))

    const string report_id = "axis_m_send_seq";

    function new (string name = "axis_m_send_seq");
        super.new(name);
    endfunction

    task body();
        if (axis_m_cfg == null) get_config();
        if (!axis_m_cfg_ready) return;

        req = axis_seq_item #(DATA_W)::type_id::create("axis_req");
        start_item(req);
        
        if (!(req.randomize() with {
            tdata   == local::tdata;
            is_last == local::is_last;
            delay   == local::delay;
        })) `uvm_error(report_id, "Randomize Failed!")
        
        `uvm_info(report_id, $sformatf("Start AXIS txn: tdata=0x%0h, last=%0b, delay=%0d", 
                                        req.tdata, req.is_last, req.delay), UVM_HIGH)
        finish_item(req);
    endtask

endclass