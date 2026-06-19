class rst_seq_item extends uvm_sequence_item;

    `uvm_object_utils(rst_seq_item)

    rand int duration;

    function new (string name = "rst_seq_item");
        super.new(name);
    endfunction
    
    virtual function void do_copy(uvm_object rhs);
        rst_seq_item rhs_;
        if (!$cast(rhs_, rhs)) begin
            `uvm_error("RST_SEQ_ITEM", "do_copy: Cast of rhs object failed")
            return;
        end
        super.do_copy(rhs);
        duration = rhs_.duration;
    endfunction

    virtual function string convert2string();
        string s = super.convert2string();
        s = $sformatf("%s\nduration : %0d", 
                      s, duration);
        return s;
    endfunction

    virtual function void do_print(uvm_printer printer);
        $display(convert2string());
    endfunction

endclass