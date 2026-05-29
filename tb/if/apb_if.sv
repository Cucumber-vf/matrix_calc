interface apb_if (input logic clk, input logic rst_n);

    logic        psel, penable, pwrite;
    logic [7:0]  paddr;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic        pready, pslverr;

    modport master (
        input clk, rst_n, prdata, pready, pslverr,
        output psel, penable, pwrite, paddr, pwdata
    );

    modport slave (
        input clk, rst_n, psel, penable, pwrite, paddr, pwdata,
        output prdata, pready, pslverr
    );

    modport monitor (
        input clk, rst_n, psel, penable, pwrite, paddr, pwdata, 
              prdata, pready, pslverr
    );
        
endinterface