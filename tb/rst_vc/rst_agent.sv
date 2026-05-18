import rst_package::*;

class rst_agent extends uvm_agent;
    
    `uvm_component_utils(rst_agent)
    
    uvm_analysis_port #(rst_seq_item) rst_ap;
    rst_config rst_cfg;
    rst_driver rst_drv;
    rst_sequencer rst_sqr;
    rst_monitor rst_mon;

    function new (string name = "rst_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if (rst_cfg == null) begin
            if (!uvm_config_db #(rst_config)::get(this, " ", "rst_cfg", rst_cfg)) begin
                `uvm_fatal("BUILD_PHASE", "No rst_config found for agent")
            end
        end
        rst_mon = rst_monitor::type_id::create("rst_mon", this);
        rst_mon.rst_cfg = rst_cfg;
        rst_drv = rst_driver::type_id::create("rst_drv", this);
        rst_drv.rst_cfg = rst_cfg;
    endfunction

    function void connect_phase (uvm_phase phase);
        rst_ap = rst_mon.mon_ap;
        rst_drv.seq_item_port.connect(rst_sqr.seq_item_export);
    endfunction

endclass