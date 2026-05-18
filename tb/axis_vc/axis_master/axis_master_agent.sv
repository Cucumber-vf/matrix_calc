import axis_master_package::*;

class axis_master_agent extends uvm_agent;

    `uvm_component_utils(axis_master_agent)

    uvm_analysis_port #(axis_seq_item) axis_m_ap;
    axis_master_config axis_m_cfg;
    axis_master_driver axis_m_drv;
    axis_sequencer axis_m_sqr;
    axis_master_monitor axis_m_mon;

    function new (string name = "axis_master_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if (axis_m_cfg == null)
            if(!uvm_config_db #(axis_master_config)::get(this, " ", "axis_m_cfg", axis_m_cfg)) begin
                `uvm_error("BUILD_PHASE", "No axis_m_cfg found for agent")
            end
        axis_m_mon = axis_master_monitor::type_id::create("axis_m_mon", this);
        axis_m_mon.axis_m_cfg = axis_m_cfg;
        if (axis_m_cfg.active == UVM_ACTIVE) begin
            axis_m_drv = axis_master_driver::type_id::create("axis_m_drv", this);
            axis_m_sqr = axis_sequencer::type_id::create("axis_m_sqr", this);
            axis_m_drv.axis_m_cfg = axis_m_cfg;
        end
    endfunction

    function void connect_phase (uvm_phase phase);
        axis_m_ap = axis_m_mon.axis_mon_ap;
        if (axis_m_cfg.active == UVM_ACTIVE)
            axis_m_drv.seq_item_port.connect(axis_m_sqr.seq_item_export);
    endfunction

endclass