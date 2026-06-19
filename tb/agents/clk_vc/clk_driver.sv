class clk_driver extends uvm_component;
    
    `uvm_component_utils(clk_driver)
    
    clk_config clk_cfg;
    virtual clk_bfm vbfm;
    
    function new (string name = "clk_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if (!uvm_config_db #(clk_config)::get(this, "", "clk_cfg", clk_cfg)) begin
            `uvm_fatal("BUILD_PHASE", "No clk_config found for clk_driver")
        end
        vbfm = clk_cfg.vbfm;
    endfunction

    task run_phase (uvm_phase phase);
        vbfm.drive_clk(clk_cfg.period);
    endtask

endclass