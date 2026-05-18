class apb_monitor extends uvm_monitor;
    
    `uvm_component_utils("apb_monitor")

    uvm_analysis_port #(apb_seq_item) apb_mon_ap;
    virtual apb_monitor_bfm vbfm;
    apb_config apb_cfg;

    function new (string name = "apb_mon", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        apb_mon_ap = new("apb_mon_ap", this);
        if (apb_cfg == null) begin
            if (!uvm_config_db #(apb_config)::get(this, " ", "apb_cfg", apb_cfg)) begin
                `uvm_fatal("BUILD_PHASE", "No apb_cfg found for monitor")
            end
        end
        vbfm = apb_cfg.mon_vbfm;
        vbfm.mon = this;
    endfunction

    task run_phase (uvm_phase phase);
        vbfm.run();
    endtask

    function void notify_seq_item(apb_seq_item item);
        apb_mon_ap.write(item);
    endfunction
    
endclass