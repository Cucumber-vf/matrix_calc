class apb_seq_item extends uvm_object;

    `uvm_object_utils(apb_seq_item)

    rand bit [31:0] paddr;
    rand bit        pwrite;
    rand bit [31:0] pwdata;

         bit [31:0] prdata;
         bit        pslverr;
 
    function new (string name = "axis_seq_item");
        super.new(name);
    endfunction

endclass