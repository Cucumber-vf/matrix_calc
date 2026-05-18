class axis_master_monitor extends uvm_monitor;

    `uvm_component_utils(axis_master_monitor)
    
    uvm_analysis_port #(axis_seq_item) axis_mon_ap;
    virtual axis_master_monitor_bfm #(DATA_W) vbfm;
    axis_master_config axis_m_cfg;
    
    function new (string name = "axis_master_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        axis_mon_ap = new("axis_mon_ap", this);
        if (axis_m_cfg == null) begin
            if (!uvm_config_db #(axis_master_config)::get(this, " ", "axis_m_cfg", axis_m_cfg)) begin
                `uvm_fatal("BUILD_PHASE", "No axis_m_cfg found for monitor")
            end
        end
        vbfm = axis_m_cfg.mon_vbfm;
        vbfm.mon = this;
    endfunction

    task run_phase (uvm_phase phase);
        vbfm.run();
    endtask

    function void notify_seq_item(axis_seq_item item);
        axis_mon_ap.write(item);
    endfunction

endclass