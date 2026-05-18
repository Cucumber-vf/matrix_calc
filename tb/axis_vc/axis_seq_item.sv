class axis_seq_item extends uvm_object;

    `uvm_object_utils(axis_seq_item)

    bit signed [DATA_W - 1:0] tdata; // data - python random gen vectors
    bit                       is_last;

    function new (string name = "axis_seq_item");
        super.new(name);
    endfunction

endclass