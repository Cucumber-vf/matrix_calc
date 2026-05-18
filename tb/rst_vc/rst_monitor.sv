class uvm_monitor extends uvm_monitor;

    `uvm_component_utils(uvm_monitor)

    uvm_analysis_port #(rst_seq_item) mon_ap;
    virtual rst_monitor_bfm vbfm;
    rst_config rst_cfg;

    function new (string name = "uvm_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        mon_ap = new("mon_ap", this);
        if (rst_cfg == null) begin
            if (!uvm_config_db #(rst_config)::get(this, " ", "rst_cfg", rst_cfg)) begin
                `uvm_fatal("BUILD_PHASE", "No rst_config found for monitor")
            end
        end
        vbfm = rst_cfg.mon_vbfm;
        vbfm.mon = this;
    endfunction

    task run_phase (uvm_phase phase);
        vbfm.run();
    endtask

    function void notify_seq_item(rst_seq_item item);
        mon_ap.write(item);
    endfunction

endclass