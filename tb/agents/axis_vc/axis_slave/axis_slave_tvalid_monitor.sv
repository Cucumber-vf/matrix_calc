class axis_slave_tvalid_monitor extends uvm_monitor;

    `uvm_component_utils(axis_slave_tvalid_monitor)
    
    uvm_analysis_port #(axis_slave_tvalid_seq_item) axis_tvalid_mon_ap;
    virtual axis_monitor_bfm vbfm;
    axis_slave_config axis_s_cfg;
    
    function new (string name = "axis_tvalid_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        axis_tvalid_mon_ap = new("axis_tvalid_mon_ap", this);
        if (!uvm_config_db #(axis_slave_config)::get(this, "", "axis_s_cfg", axis_s_cfg)) begin
            `uvm_fatal("BUILD_PHASE", "No axis_s_cfg found for tvalid monitor")
        end
        vbfm = axis_s_cfg.mon_vbfm;
    endfunction

    task run_phase(uvm_phase phase);
        axis_slave_tvalid_seq_item tvalid_mon_item;
        forever begin
            vbfm.wait_for_tvalid_assert();
            tvalid_mon_item = axis_slave_tvalid_seq_item::type_id::create("tvalid_start_mon_item");
            tvalid_mon_item.is_assert = 1;
            axis_tvalid_mon_ap.write(tvalid_mon_item);

            vbfm.wait_for_tvalid_deassert();
            tvalid_mon_item = axis_slave_tvalid_seq_item::type_id::create("tvalid_end_mon_item");
            tvalid_mon_item.is_assert = 0;
            axis_tvalid_mon_ap.write(tvalid_mon_item);
        end
    endtask

endclass