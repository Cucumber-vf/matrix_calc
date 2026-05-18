class env_config extends uvm_object;

    `uvm_object_utils(env_config)

    clk_config  clk_cfg;
    rst_config  rst_cfg;
    apb_config  apb_cfg;
    axis_config axis_cfg;
    
    function new (name = "env_cfg", parent = null) 
        super.new(name, parent);
    endfunction

endclass