class clk_config extends uvm_object;

    `uvm_object_utils(clk_config)

    virtual clk_bfm vbfm;
    
    int period = 10;

    function new (string name = "clk_config");
        super.new(name);
    endfunction

endclass