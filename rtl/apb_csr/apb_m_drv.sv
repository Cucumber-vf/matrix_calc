module apb_m_drv (
    //
    input  logic        clk,
    input  logic        rst_n, 

    //
    output logic        psel,
    output logic        penable,
    output logic        pwrite,
    output logic [7:0]  paddr,
    output logic [31:0] pwdata,

    input  logic [31:0] prdata,
    input  logic        pready,       
    input  logic        pslverr
);

    task apb_reset ();

        wait(~rst_n);
        penable <= 0;
        psel    <= 0;
        pwrite  <= 0;
        wait(rst_n);

    endtask

    task apb_write (input [7:0] addr, input [31:0] data);

        @(posedge clk);
        penable <= 0;
        psel    <= 1;
        pwrite  <= 1;
        paddr   <= addr;
        pwdata  <= data;
        @(posedge clk);
        penable <= 1;
        do begin
            if (pslverr)
            $display("[APB WRITE] WARNING: pslverr asserted for addr=0x%02H data=0x%08H at time %0t",
                     addr, data, $time);
            @(posedge clk);
        end
        while (~pready);
        penable <= 0;
        psel    <= 0;

    endtask

    task apb_read (input [7:0] addr, output [31:0] rdata);

        @(posedge clk);
        penable <= 0;
        psel    <= 1;
        pwrite  <= 0;
        paddr   <= addr;
        @(posedge clk);
        penable <= 1;
        do begin
            if (pready) rdata = prdata;
            if (pslverr)
            $display("[APB READ ] WARNING: pslverr asserted for addr=0x%02X at time %0t",
                     addr, $time);
            @(posedge clk);
        end
        while (~pready);
        penable <= 0;
        psel    <= 0;

    endtask

endmodule