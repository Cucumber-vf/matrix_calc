class axis_master_tready_seq_item extends uvm_sequence_item;

    `uvm_object_utils(axis_master_tready_seq_item)

    bit is_assert;

    function new (string name = "axis_master_tready_seq_item");
        super.new(name);
    endfunction

endclass