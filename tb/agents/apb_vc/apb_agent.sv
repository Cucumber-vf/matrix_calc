class apb_agent extends uvm_agent;

    `uvm_component_utils(apb_agent)

    uvm_analysis_port #(apb_seq_item) apb_ap;
    apb_config apb_cfg;
    apb_driver apb_drv;
    uvm_sequencer #(apb_seq_item) apb_sqr;
    apb_monitor apb_mon;

    function new (string name = "apb_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if(!uvm_config_db #(apb_config)::get(this, "", "apb_cfg", apb_cfg)) begin
            `uvm_fatal("BUILD_PHASE", "No apb_cfg found for agent")
        end
        
        apb_ap = new("apb_ap", this);
        apb_mon = apb_monitor::type_id::create("apb_mon", this);

        if (apb_cfg.active == UVM_ACTIVE) begin
            apb_drv = apb_driver::type_id::create("apb_drv", this);
            apb_sqr = uvm_sequencer #(apb_seq_item)::type_id::create("apb_sqr", this);
        end 
    endfunction

    function void connect_phase (uvm_phase phase);
        apb_mon.apb_mon_ap.connect(apb_ap);
        if (apb_cfg.active == UVM_ACTIVE)
            apb_drv.seq_item_port.connect(apb_sqr.seq_item_export);
    endfunction

endclass