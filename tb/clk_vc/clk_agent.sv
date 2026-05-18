import clk_package::*;

class clk_agent extends uvm_agent;
    
    `uvm_component_utils(clk_agent)
    
    clk_config clk_cfg;
    clk_driver clk_drv;

    function new (string name = "clk_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if (clk_cfg == null) begin
            if (!uvm_config_db #(clk_config)::get(this, " ", "clk_cfg", clk_cfg)) begin
                `uvm_fatal("BUILD_PHASE", "No clk_cfg found for agent")
            end
        end
        clk_drv = clk_driver::type_id::create("clk_drv", this);
        clk_drv.cfg = clk_cfg;
    endfunction

endclass