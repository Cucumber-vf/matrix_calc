class clk_driver extends uvm_component;
    
    `uvm_component_utils(clk_driver)
    
    clk_config cfg;
    virtual clk_bfm vbfm;
    
    function new (string name = "clk_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if (cfg == null) begin
            if (!uvm_config_db #(clk_config)::get(this, " ", "cfg", cfg)) begin
                `uvm_fatal("BUILD_PHASE", "No clk_config found for clk_driver")
            end
        end
        vbfm = cfg.vbfm;
    endfunction

    task run_phase (uvm_phase phase);
        vbfm.drive(cfg.period);
    endtask

endclass