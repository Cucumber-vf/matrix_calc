class axis_slave_agent extends uvm_agent;
    
    `uvm_component_utils(axis_slave_agent)

    uvm_analysis_port #(axis_seq_item_t) axis_s_ap;
    uvm_analysis_port #(axis_slave_tvalid_seq_item) axis_s_tvalid_ap;

    axis_slave_config axis_s_cfg;
    axis_slave_driver axis_s_drv;
    axis_monitor axis_s_mon;
    axis_slave_tvalid_monitor axis_s_tvalid_mon;

    function new (string name = "axis_slave_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if (!uvm_config_db #(axis_slave_config)::get(this, "", "axis_s_cfg", axis_s_cfg)) begin
            `uvm_fatal("BUILD_PHASE", "No axis_s_cfg found for agent")
        end

        axis_s_ap = new("axis_s_ap", this);
        axis_s_mon = axis_monitor::type_id::create("axis_s_mon", this);
        uvm_config_db #(axis_config)::set(this, "axis_s_mon", "axis_cfg", axis_s_cfg);

        if (axis_s_cfg.has_tvalid_monitor) begin
            axis_s_tvalid_ap = new("axis_s_tvalid_ap", this);
            axis_s_tvalid_mon = axis_slave_tvalid_monitor::type_id::create("axis_s_tvalid_mon", this);
        end

        axis_s_drv = axis_slave_driver::type_id::create("axis_s_drv", this);
    endfunction

    function void connect_phase (uvm_phase phase);
        axis_s_mon.axis_mon_ap.connect(axis_s_ap);
        if (axis_s_cfg.has_tvalid_monitor) begin
            axis_s_tvalid_mon.axis_tvalid_mon_ap.connect(axis_s_tvalid_ap);
        end
    endfunction

endclass