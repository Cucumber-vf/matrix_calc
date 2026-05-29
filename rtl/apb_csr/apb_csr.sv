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
    
    typedef enum logic [7:0] {
        REG_OP     = 8'h00,
        REG_CTRL   = 8'h04,
        REG_STATUS = 8'h08
    } e_regs_addresses;
    
    assign pready  = rst_n ? 1'b1 : 1'b0;
    assign pslverr = psel && penable && ( !(paddr inside {REG_OP, REG_CTRL, REG_STATUS}) || (pwrite && paddr == 8'h08) );
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            op    <= 2'b00;
            start <= 1'b0;
            flush <= 1'b0;
        end
        if (psel && penable && pwrite) begin
            case (paddr)
                REG_OP   : if (~busy_i) op <= pwdata[1:0];
                REG_CTRL : {flush, start}  <= pwdata[1:0];
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
        prdata = '0;

        if (psel && penable && ~pwrite) begin
            case (paddr)
                REG_OP     :  prdata = op;
                REG_CTRL   :  prdata = {flush, start};
                REG_STATUS :  prdata = {rx_err_i, singular_i, overflow_i, busy_i, done_i};
            endcase
        end
    end
    
endmodule