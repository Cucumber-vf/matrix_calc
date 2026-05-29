class axis_master_driver extends uvm_driver #(axis_m_drv_seq_item_t);

    `uvm_component_utils(axis_master_driver)

    axis_master_config axis_m_cfg;
    virtual axis_master_driver_bfm vbfm;

    function new (string name = "axis_master_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if (!uvm_config_db #(axis_master_config)::get(this, "", "axis_m_cfg", axis_m_cfg)) begin
            `uvm_fatal("BUILD_PHASE", "No axis_m_cfg found for driver")
        end
        vbfm = axis_m_cfg.drv_vbfm;
    endfunction

    task run_phase (uvm_phase phase);
        axis_m_drv_seq_item item;
        forever begin
            seq_item_port.get_next_item(item);
            vbfm.drive_txn(item.to_struct());
            seq_item_port.item_done();
        end
    endtask

endclass