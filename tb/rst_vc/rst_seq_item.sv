class rst_seq_item extends uvm_object;

    `uvm_object_utils(rst_seq_item)

    rand int duration;

    function new (string name = "rst_seq_item");
        super.new(name);
    endfunction

endclass