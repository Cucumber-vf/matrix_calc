module apb_csr (
    
    input  logic        clk,
    input  logic        rst_n, 
     
    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [7:0]  paddr,
    input  logic [31:0] pwdata,

    output logic [31:0] prdata,
    output logic        pready,       
    output logic        pslverr,

    output logic [1:0]  op,
    output logic        start,
    output logic        flush,
    
    input  logic        done_i,
    input  logic        busy_i,
    input  logic        overflow_i,
    input  logic        singular_i,
    input  logic        rx_err_i
);
    assign pready  = 1'b1;
    assign pslverr = psel && penable && ( !(paddr inside {8'h00, 8'h04, 8'h08}) || (pwrite && paddr == 8'h08) );
    
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            op <= 2'b00;
        end
        if (psel && penable && pwrite) begin
            case (paddr)
                8'h00 : if (~busy_i) op <= pwdata;
                8'h04 : {flush, start}  <= pwdata;
            endcase
        end
        else begin
            if (start) 
                start <= 1'b0;
            if (flush)
                flush <= 1'b0;
        end
    end

    always_comb begin
        if (psel && penable && ~pwrite) begin
            case (paddr)
                8'h00 :  prdata = op;
                8'h04 :  prdata = start;
                8'h08 :  prdata = {rx_err_i, singular_i, overflow_i, busy_i, done_i};
                default: prdata = 1'b0;
            endcase
        end
    end
    
endmodule