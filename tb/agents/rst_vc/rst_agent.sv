class rst_agent extends uvm_agent;
    
    `uvm_component_utils(rst_agent)
    
    uvm_analysis_port #(rst_seq_item) rst_ap;
    rst_config rst_cfg;
    rst_driver rst_drv;
    uvm_sequencer #(rst_seq_item) rst_sqr;
    rst_monitor rst_mon;

    function new (string name = "rst_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if (!uvm_config_db #(rst_config)::get(this, "", "rst_cfg", rst_cfg)) begin
            `uvm_fatal("BUILD_PHASE", "No rst_config found for agent")
        end

        rst_ap = new("rst_ap", this);
        rst_mon = rst_monitor::type_id::create("rst_mon", this);

        if (rst_cfg.active == UVM_ACTIVE) begin
            rst_drv = rst_driver::type_id::create("rst_drv", this);
            rst_sqr = uvm_sequencer #(rst_seq_item)::type_id::create("rst_sqr", this);
        end
    endfunction

    function void connect_phase (uvm_phase phase);
        rst_mon.rst_mon_ap.connect(rst_ap);
        if (rst_cfg.active == UVM_ACTIVE) begin
            rst_drv.seq_item_port.connect(rst_sqr.seq_item_export);
        end
    endfunction

endclass