class clk_config extends uvm_object;

    `uvm_object_utils(clk_config)

    virtual clk_bfm vbfm;
    
    int period = 10;

    bit create_clk_agent = 1; // 0 if clk generate in tb_top

    function new (string name = "clk_config");
        super.new(name);
    endfunction

    task wait_for_clock (int n = 1);
        vbfm.wait_for_clock(n);
    endtask

endclass