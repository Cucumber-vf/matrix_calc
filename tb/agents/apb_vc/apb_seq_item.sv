class apb_seq_item extends uvm_sequence_item;

    `uvm_object_utils(apb_seq_item)

    rand logic [31:0] paddr;
    rand logic        pwrite;
    rand logic [31:0] pwdata;

         logic [31:0] prdata;
         logic        pslverr;
 
    function new (string name = "apb_seq_item");
        super.new(name);
    endfunction

    virtual function void do_copy(uvm_object rhs);
        apb_seq_item rhs_;
        
        if (!$cast(rhs_, rhs)) begin
            `uvm_error("APB_SEQ_ITEM", "do_copy: Cast of rhs object failed")
            return;
        end
        super.do_copy(rhs); 
        paddr   = rhs_.paddr;
        pwrite  = rhs_.pwrite;
        pwdata  = rhs_.pwdata;
        prdata  = rhs_.prdata;
        pslverr = rhs_.pslverr;
    endfunction

    virtual function string convert2string();
        string s = super.convert2string();
        s = $sformatf("%s\npaddr   : %0h\npwrite  : %0b\npwdata  : %0h\nprdata  : %0h\npslverr : %0b", 
                      s, paddr, pwrite, pwdata, prdata, pslverr);
        return s;
    endfunction

    virtual function void do_print(uvm_printer printer);
        $display(convert2string());
    endfunction

    virtual function apb_seq_item_s to_struct();
        apb_seq_item_s res;
        res.paddr   = paddr;
        res.pwrite  = pwrite;
        res.pwdata  = pwdata;
        return res;
    endfunction

    virtual function void from_struct(apb_seq_item_s item);
        paddr   = item.paddr;
        pwrite  = item.pwrite;
        pwdata  = item.pwdata;
        prdata  = item.prdata;
        pslverr = item.pslverr;
    endfunction

endclass
