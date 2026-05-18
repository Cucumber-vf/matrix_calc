import apb_master_package::*;

class apb_agent extends uvm_agent;

    `uvm_component_utils("apb_agent")

    uvm_analysis_port #(apb_seq_item) apb_ap;
    apb_config apb_cfg;
    apb_driver apb_drv;
    apb_sequencer apb_sqr;
    apb_monitor apb_mon;

    function new (string name = "apb_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if (apb_cfg == null)
            if(!uvm_config_db #(apb_config)::get(this, " ", "apb_cfg", apb_cfg)) begin
                `uvm_error("BUILD_PHASE", "No apb_cfg found for agent")
            end
        apb_mon = apb_monitor::type_id::create("apb_mon", this);
        apb_mon.apb_cfg = apb_cfg;
        if (apb_cfg.active == UVM_ACTIVE) begin
            apb_drv = apb_driver::type_id::create("apb_drv", this);
            apb_sqr = apb_sequencer::type_id::create("apb_sqr", this);
            apb_drv.apb_cfg = apb_cfg;
        end 
    endfunction

    function void connect_phase (uvm_phase phase);
        apb_ap = apb_mon.apb_mon_ap;
        if (apb_cfg.active == UVM_ACTIVE)
            apb_drv.seq_item_port.connect(apb_sqr.seq_item_export);
    endfunction

endclass