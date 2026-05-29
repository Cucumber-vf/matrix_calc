class axis_monitor extends uvm_monitor;

    `uvm_component_utils(axis_monitor)
    
    uvm_analysis_port #(axis_seq_item_t) axis_mon_ap;
    virtual axis_monitor_bfm vbfm;
    axis_config axis_cfg;
    
    function new (string name = "axis_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        axis_mon_ap = new("axis_mon_ap", this);
        if (!uvm_config_db #(axis_config)::get(this, "", "axis_cfg", axis_cfg)) begin
            `uvm_fatal("BUILD_PHASE", "No axis_cfg found for monitor")
        end
        vbfm = axis_cfg.mon_vbfm;
    endfunction

    task run_phase(uvm_phase phase);
        axis_seq_item mon_item;
        axis_m_drv_seq_item_s bfm_item;
        forever begin
            vbfm.wait_hs(bfm_item);
            mon_item = axis_seq_item_t::type_id::create("mon_item", this);
            mon_item.from_struct(bfm_item);
            axis_mon_ap.write(mon_item);
        end
    endtask

endclass