class rst_monitor extends uvm_monitor;

    `uvm_component_utils(rst_monitor)

    uvm_analysis_port #(rst_seq_item) rst_mon_ap;
    virtual rst_monitor_bfm vbfm;
    rst_config rst_cfg;

    function new (string name = "uvm_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        rst_mon_ap = new("rst_mon_ap", this);
        if (!uvm_config_db #(rst_config)::get(this, " ", "rst_cfg", rst_cfg)) begin
            `uvm_fatal("BUILD_PHASE", "No rst_config found for monitor")
        end
        vbfm = rst_cfg.mon_vbfm;
    endfunction

    task run_phase(uvm_phase phase);
        rst_seq_item item;

        forever begin
            item = rst_seq_item::type_id::create("rst_start_item", this);
            vbfm.wait_reset_start(item.duration);
            rst_mon_ap.write(item);

            item = rst_seq_item::type_id::create("rst_end_item", this);
            vbfm.wait_reset_end(item.duration);
            rst_mon_ap.write(item);
        end
    endtask

endclass