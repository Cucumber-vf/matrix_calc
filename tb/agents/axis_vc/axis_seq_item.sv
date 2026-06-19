class axis_seq_item #(parameter DATA_W = 16) extends uvm_sequence_item;

    `uvm_object_param_utils(axis_seq_item #(DATA_W))

    rand logic signed [DATA_W - 1:0] tdata; 
    rand logic                       is_last;
    rand int                         delay;

    function new (string name = "axis_seq_item");
        super.new(name);
    endfunction

    virtual function void do_copy(uvm_object rhs);
        axis_seq_item rhs_;
        if (!$cast(rhs_, rhs)) begin
            `uvm_error("AXIS_SEQ_ITEM", "do_copy: Cast of rhs object failed")
            return;
        end
        super.do_copy(rhs);
        tdata   = rhs_.tdata;
        is_last = rhs_.is_last;
        delay   = rhs_.delay;
    endfunction

    virtual function string convert2string();
        string s = super.convert2string();
        s = $sformatf("%s\ntdata   : %0d (0x%0h)\nis_last : %0b\ndelay   : %0d", 
                      s, tdata, tdata, is_last, delay);
        return s;
    endfunction

    virtual function void do_print(uvm_printer printer);
        $display(convert2string());
    endfunction

    virtual function axis_seq_item_s to_struct();
        axis_seq_item_s res;
        res.tdata   = tdata;
        res.is_last = is_last;
        res.delay   = delay;
        return res;
    endfunction

    virtual function void from_struct(axis_seq_item_s item);
        tdata   = item.tdata;
        is_last = item.is_last;
        delay   = item.delay;
    endfunction

endclass