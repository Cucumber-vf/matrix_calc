interface axis_if #(parameter DATA_W = 16) (input logic clk, input logic rst_n);

    logic signed [DATA_W-1:0] tdata;
    logic                     tvalid, tlast, tready;
        
    modport master (
        input clk, rst_n, tready,
        output tvalid, tdata, tlast
    );

    modport slave (
        input clk, rst_n, tvalid, tdata, tlast,
        output tready
    );

    modport monitor (
        input clk, rst_n, tvalid, tdata, tready, tlast
    );
    
endinterface