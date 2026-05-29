class apb_seq_base extends uvm_sequence #(apb_seq_item);

    `uvm_object_utils(apb_seq_base)

    function new(string name = "apb_seq_base");
        super.new(name);
    endfunction
    
endclass