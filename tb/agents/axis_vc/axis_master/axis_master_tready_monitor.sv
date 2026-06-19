class axis_master_tready_monitor extends uvm_monitor;

    `uvm_component_utils(axis_master_tready_monitor)
    
    uvm_analysis_port #(axis_master_tready_seq_item) axis_tready_mon_ap;
    virtual axis_monitor_bfm vbfm;
    axis_master_config axis_m_cfg;
    
    function new (string name = "axis_tready_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        axis_tready_mon_ap = new("axis_tready_mon_ap", this);
        if (!uvm_config_db #(axis_master_config)::get(this, "", "axis_m_cfg", axis_m_cfg)) begin
            `uvm_fatal("BUILD_PHASE", "No axis_m_cfg found for tready monitor")
        end
        vbfm = axis_m_cfg.mon_vbfm;
    endfunction

    task run_phase(uvm_phase phase);
        axis_master_tready_seq_item tready_mon_item;
        forever begin
            vbfm.wait_for_tready_assert();
            tready_mon_item = axis_master_tready_seq_item::type_id::create("tready_start_mon_item");
            tready_mon_item.is_assert = 1;
            axis_tready_mon_ap.write(tready_mon_item);

            vbfm.wait_for_tready_deassert();
            tready_mon_item = axis_master_tready_seq_item::type_id::create("tready_end_mon_item");
            tready_mon_item.is_assert = 0;
            axis_tready_mon_ap.write(tready_mon_item);
        end
    endtask

endclass