module tb_matrix_calc;

    localparam T      = 10;
    localparam N      = 4;    
    localparam DATA_W = 16;   

    //
    logic        clk;
    logic        rst_n;        
    //
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [7:0]  paddr;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic        pready;      
    logic        pslverr;

    //
    logic signed [DATA_W-1:0] s_axis_a_tdata;
    logic                     s_axis_a_tvalid;
    logic                     s_axis_a_tlast;   
    logic                     s_axis_a_tready;

    //
    logic signed [DATA_W-1:0] s_axis_b_tdata;
    logic                     s_axis_b_tvalid;
    logic                     s_axis_b_tlast;
    logic                     s_axis_b_tready;

    //
    logic signed [DATA_W-1:0] m_axis_res_tdata;
    logic                     m_axis_res_tvalid;
    logic                     m_axis_res_tlast; 
    logic                     m_axis_res_tready;

    // DUT 
    matrix_calc #( .N(N), .DATA_W(DATA_W) ) dut (
        .*
    );
    

    // Drivers
    apb_driver apb_drv (.*);


    // Clock and Reset gen
    initial begin
        clk <= 0;
        forever begin
            #(T/2) clk <= ~clk;
        end
    end 

    initial begin

        @(posedge clk);
        rst_n <= 0;
        @(posedge clk);
        rst_n <= 1;
    end

    // Direct tests
    initial begin
        
        // base op check (00)
        apb_drv.apb_reset();

        // write check
        apb_drv.apb_write(8'h00, 2'd2);
        // inv addr write check (pslverr = 1)
        apb_drv.apb_write(8'h0A, 2'd2);
        // RO reg write check (pslverr = 1)
        apb_drv.apb_write(8'h08, 2'd2);

        // write check
        apb_drv.apb_read(8'h00);
        // inv addr write check (pslverr = 1)
        apb_drv.apb_read(8'h10);
        
        // self-reset check
        apb_drv.apb_write(8'h04, 2'd3);

        @(posedge clk);
        @(posedge clk);

        $stop();
    end

endmodule