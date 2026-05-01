module tb_matrix_calc;

    // ── Параметры ─────────────────────────────────────────────────
    localparam T      = 10;
    localparam N      = 4;     // размер матрицы N×N
    localparam DATA_W = 16;    // разрядность элемента (знаковое целое)

    // ── Системные сигналы ────────────────────────────────────────
    logic        clk;
    logic        rst_n;        // сброс, активный низкий
    // ── APB interface (управление) ───────────────────────────────
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [7:0]  paddr;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic        pready;      // всегда 1 в данном дизайне
    logic        pslverr;


    // ── AXI4-Stream interface: матрица A ──────────────────────────
    logic signed [DATA_W-1:0] s_axis_a_tdata;
    logic                     s_axis_a_tvalid;
    logic                     s_axis_a_tlast;   // последний элемент
    logic                     s_axis_a_tready;


    // ── AXI4-Stream interface: матрица B ──────────────────────────
    logic signed [DATA_W-1:0] s_axis_b_tdata;
    logic                     s_axis_b_tvalid;
    logic                     s_axis_b_tlast;
    logic                     s_axis_b_tready;


    // ── AXI4-Stream interface: результат ─────────────────────────
    logic signed [DATA_W-1:0] m_axis_res_tdata;
    logic                     m_axis_res_tvalid;
    logic                     m_axis_res_tlast;  // последний элемент
    logic                     m_axis_res_tready;

    // ─────────────────────────────────────────────────────────────

    // ──────── DUT ──────────────────────────────────────────────── 
    matrix_calc #( .N(N), .DATA_W(DATA_W) ) dut (
        .*
    );
    // ─────────────────────────────────────────────────────────────

    // ──────── Drivers ──────────────────────────────────────────── 
    apb_driver apb_drv (.*);

    // ─────────────────────────────────────────────────────────────

    // ──────── Clock and Reset gen ────────────────────────────────
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
    // ─────────────────────────────────────────────────────────────

    initial begin
        
        apb_drv.apb_reset();
        apb_drv.apb_drive(8'h00, 2'd2, 1);
        apb_drv.apb_drive(8'h00, 2'd2, 0);
        apb_drv.apb_drive(8'h04, 1'd1, 1);
        apb_drv.apb_drive(8'h04, 2'd2, 0);

        @(posedge clk);

        $stop();
    end

endmodule