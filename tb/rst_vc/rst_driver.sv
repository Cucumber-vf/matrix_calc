class rst_driver extends uvm_driver #(rst_seq_item);
    
    `uvm_component_utils(rst_driver)
    
    rst_config rst_cfg;
    virtual rst_driver_bfm vbfm;
    
    function new (string name = "rst_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        if (rst_cfg == null) begin
            if (!uvm_config_db #(rst_config)::get(this, " ", "rst_cfg", rst_cfg)) begin
                `uvm_fatal("BUILD_PHASE", "No rst_config found for rst_driver")
            end
        end
        vbfm = rst_cfg.drv_vbfm;
    endfunction

    task run_phase (uvm_phase phase);
        rst_seq_item item;
        forever begin
            seq_item_port.get_next_item(item);
            vbfm.drive_rst(item);
            seq_item_port.item_done();
        end
    endtask

endclass
            