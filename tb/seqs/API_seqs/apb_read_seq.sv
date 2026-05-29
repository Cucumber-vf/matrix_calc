class apb_read_seq extends apb_seq_base;

    `uvm_object_utils(apb_read_seq)

    const string report_id = "apb_read_seq";
    
    rand logic [31:0] addr;
         logic [31:0] rdata;
         logic        slverr;

    constraint c_addr {
        addr inside {valid_addresses};
    }

    function new (string name = "apb_read_seq");
        super.new(name);
    endfunction

    task body();
        req = apb_seq_item::type_id::create("apb_req");
        start_item(req);

        if (!(req.randomize() with {
            paddr  == local::addr;
            pwrite == 1'b0; 
        })) `uvm_error(report_id, "Randomize Failed!")

        `uvm_info(report_id, $sformatf("Start read with addr=0x%0h", req.paddr), UVM_MEDIUM)
        finish_item(req); 
         
        rdata  = req.prdata;
        slverr = req.pslverr;
    endtask 

endclass