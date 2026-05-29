class axis_m_drv_seq_item #(parameter DATA_W = 16) extends axis_seq_item #(DATA_W);
    
    `uvm_object_param_utils(axis_m_drv_seq_item #(DATA_W))

    rand int delay;

    function new (string name = "axis_m_drv_seq_item");
        super.new(name);
    endfunction

    virtual function void do_copy(uvm_object rhs);
        axis_m_drv_seq_item rhs_;
        if (!$cast(rhs_, rhs)) begin
            `uvm_error("AXIS_M_DRV_SEQ_ITEM", "do_copy: Cast of rhs object failed")
            return;
        end
        super.do_copy(rhs);
        delay = rhs_.delay;
    endfunction

    virtual function string convert2string();
        string s = super.convert2string();
        s = $sformatf("%s\ndelay   : %0d", 
                      s, delay);
        return s;
    endfunction

    virtual function axis_m_drv_seq_item_s to_struct(); 
        axis_m_drv_seq_item_s res = super.to_struct();
        res.delay = delay;
        return res;
    endfunction

endclass