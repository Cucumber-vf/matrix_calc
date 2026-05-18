class axis_slave_monitor extends uvm_monitor;

    `uvm_component_utils(axis_slave_monitor)
    
    uvm_analysis_port #(axis_seq_item) axis_mon_ap;
    virtual axis_slave_monitor_bfm #(DATA_W) vbfm;
    axis_slave_config axis_s_cfg;
    
    function new (string name = "axis_slave_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        axis_mon_ap = new("axis_mon_ap", this);
        if (axis_s_cfg == null) begin
            if (!uvm_config_db #(axis_slave_config)::get(this, " ", "axis_s_cfg", axis_s_cfg)) begin
                `uvm_fatal("BUILD_PHASE", "No axis_s_cfg found for monitor")
            end
        end
        vbfm = axis_s_cfg.mon_vbfm;
        vbfm.mon = this;
    endfunction

    task run_phase (uvm_phase phase);
        vbfm.run();
    endtask

    function void notify_seq_item(axis_seq_item item);
        axis_mon_ap.write(item);
    endfunction

endclass