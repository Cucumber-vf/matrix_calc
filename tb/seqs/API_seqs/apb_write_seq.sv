class apb_write_seq extends apb_seq_base;

    `uvm_object_utils(apb_write_seq)

    const string report_id = "apb_write_seq";
    
    rand logic [31:0] addr;
    rand logic [31:0] wdata;

    constraint c_addr {
        addr inside {REG_OP, REG_CTRL};
    }

    function new (string name = "apb_write_seq");
        super.new(name);
    endfunction

    task body();
        req = apb_seq_item::type_id::create("apb_req");
        start_item(req);
        
        if (!(req.randomize() with {
            paddr  == local::addr;
            pwrite == 1'b1;
            pwdata == local::wdata;
        })) `uvm_error(report_id, "Randomize Failed!")

        `uvm_info(report_id, 
                  $sformatf("Start write with addr=0x%0h data=0x%0h", req.paddr, req.pwdata), UVM_HIGH)
        finish_item(req);
    endtask 

endclass 