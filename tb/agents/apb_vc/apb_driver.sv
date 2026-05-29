class apb_driver extends uvm_driver #(apb_seq_item);

    `uvm_component_utils(apb_driver)

    apb_config apb_cfg;
    virtual apb_driver_bfm vbfm;

    function new (string name = "apb_drv", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if(!uvm_config_db #(apb_config)::get(this, "", "apb_cfg", apb_cfg)) begin
            `uvm_fatal("BUILD_PHASE", "No apb_cfg found for driver")
        end
        vbfm = apb_cfg.drv_vbfm;
    endfunction

    task run_phase (uvm_phase phase);
        apb_seq_item item;
        forever begin
            seq_item_port.get_next_item(item);
            vbfm.drive_txn(item.to_struct());
            seq_item_port.item_done();
        end
    endtask

endclass