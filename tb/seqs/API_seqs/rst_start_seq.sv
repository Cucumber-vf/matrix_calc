class rst_start_seq extends rst_seq_base;

    `uvm_object_utils(rst_start_seq)

    const string report_id = "rst_start_seq";

    function new (string name = "rst_start_seq");
        super.new(name);
    endfunction

    task body();
        if (rst_cfg == null) get_config();
        if (!rst_cfg_ready) return;

        req = rst_seq_item::type_id::create("rst_req");
        start_item(req);
        
        if (!(req.randomize() with {
            duration == local::duration;
        })) `uvm_error(report_id, "Randomize Failed!")

        `uvm_info(report_id, $sformatf("Start reset with duration=%0d", req.duration), UVM_LOW) 
        finish_item(req);
    endtask

endclass 