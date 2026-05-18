import axis_slave_package::*;

class axis_slave_agent extends uvm_agent;

    `uvm_component_utils(axis_slave_agent)

    uvm_analysis_port #(axis_seq_item) axis_s_ap;
    axis_slave_config axis_s_cfg;
    axis_slave_driver axis_s_drv;
    axis_slave_monitor axis_s_mon;

    function new (string name = "axis_slave_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if (axis_s_cfg == null) begin
            if (!uvm_config_db #(axis_slave_config)::get(this, " ", "axis_s_cfg", axis_s_cfg)) begin
                `uvm_fatal("BUILD_PHASE", "No axis_s_cfg found for agent")
            end
        end
        axis_s_mon = axis_slave_monitor::type_id::create("axis_s_mon", this);
        axis_s_mon.axis_s_cfg = axis_s_cfg;
        if (axis_s_cfg.active == UVM_ACTIVE) begin
            axis_s_drv = axis_slave_driver::type_id::create("axis_s_drv", this);
            axis_s_drv.axis_s_cfg = axis_s_cfg;
        end
    endfunction

    function void connect_phase (uvm_phase phase);
        axis_s_ap = axis_s_mon.axis_mon_ap;
    endfunction

endclass