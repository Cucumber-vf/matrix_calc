module matrix_calc #(
    parameter N      = 4,    
    parameter DATA_W = 16    
) (
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
    
    input  logic signed [DATA_W-1:0] s_axis_a_tdata,
    input  logic                     s_axis_a_tvalid,
    input  logic                     s_axis_a_tlast,   
    output logic                     s_axis_a_tready,

    input  logic signed [DATA_W-1:0] s_axis_b_tdata,
    input  logic                     s_axis_b_tvalid,
    input  logic                     s_axis_b_tlast,
    output logic                     s_axis_b_tready,

    output logic signed [DATA_W-1:0] m_axis_res_tdata,
    output logic                     m_axis_res_tvalid,
    output logic                     m_axis_res_tlast,  
    input  logic                     m_axis_res_tready             
);

    logic [1:0]                 op;
    logic                       start;
    logic                       flush;
    logic                       busy_i;
    logic                       overflow_i;
    logic                       singular_i;
    logic                       rx_err_i;
    
    logic                       set_calc_status;

    logic                       flush_rx;
    logic signed [  DATA_W-1:0] mat_a [N][N];
    logic signed [  DATA_W-1:0] mat_b [N][N];
    logic                       recv_a_done;
    logic                       rx_err_a;
    logic                       recv_b_done;
    logic                       rx_err_b;

    logic signed [  DATA_W-1:0] mat_addsub_res [N][N];
    logic                       addsub_overflow;

    logic signed [  DATA_W-1:0] mat_transpose_res [N][N];

    logic signed [N*DATA_W-1:0] det;
    logic                       det_singular;
    logic                       calc_done;

    logic                       send;
    logic                       is_scalar;
    logic signed [  DATA_W-1:0] res_mat [N][N];

    assign busy_i   = ~s_axis_a_tready || (~op[1] & ~s_axis_b_tready);
    assign rx_err_i = rx_err_a || (~op[1] & rx_err_b);
    assign res_mat  = op[1] ? mat_transpose_res : mat_addsub_res;

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            overflow_i <= 0;
            singular_i <= 0;
        end
        else if (flush_rx) begin
            overflow_i <= 0;
            singular_i <= 0;
        end
        else if (set_calc_status) begin
            overflow_i <= ~op[1] ? addsub_overflow : 0;
            singular_i <= det_singular;
        end
    end
    
    // FSM ////////////////////////////////////////////////

     typedef enum logic [2:0] {
        IDLE,
        RECV,
        WAIT_START,
        COMPUTE,
        SEND,
        RX_ERR
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk)
        if (~rst_n)
            state <= IDLE;
        else
            state <= next_state;

    always_comb begin
        next_state = state;

        case (state)
            IDLE: 
                if (s_axis_a_tready & s_axis_b_tready)     next_state = RECV;
            RECV: 
                if (recv_a_done && (op[1] | recv_b_done))  next_state = WAIT_START;
                else if (rx_err_i)                         next_state = RX_ERR;
                else if (flush)                            next_state = IDLE;
            WAIT_START:
                if (flush)                                 next_state = IDLE;
                else if (start)                            next_state = COMPUTE;
            COMPUTE:
                if (calc_done || (op != 2'b11))            next_state = SEND;
            SEND:
                if (m_axis_res_tvalid && m_axis_res_tready
                                      && m_axis_res_tlast) next_state = IDLE;
            RX_ERR:
                if (flush)                                 next_state = IDLE;
        endcase
    end
    
    assign flush_rx = (next_state == IDLE);
    assign send     = (state == COMPUTE) && (next_state == SEND);

    assign set_calc_status = (state == COMPUTE) && (next_state == SEND) && (op != 2'b10);
    assign det_calc_start  = (state == WAIT_START) && start && op;

   ////////////////////////////////////////////////////////

    apb_csr u_apb_csr (
        .clk        (clk       ),
        .rst_n      (rst_n     ),
        .psel       (psel      ),
        .penable    (penable   ),
        .pwrite     (pwrite    ),
        .paddr      (paddr     ),
        .pwdata     (pwdata    ),
        .prdata     (prdata    ),
        .pready     (pready    ),
        .pslverr    (pslverr   ),
        .op         (op        ),
        .start      (start     ),
        .flush      (flush     ),
        .busy_i     (busy_i    ),
        .overflow_i (overflow_i),
        .singular_i (singular_i),
        .rx_err_i   (rx_err_i  )
    );
    
    axis_rx #(
        .N         (N),
        .DATA_W    (DATA_W)
    ) u_axis_rx_a (
        .clk       (clk            ),
        .rst_n     (rst_n          ),
        .s_tdata   (s_axis_a_tdata ),
        .s_tvalid  (s_axis_a_tvalid),
        .s_tlast   (s_axis_a_tlast ),
        .s_tready  (s_axis_a_tready),
        .flush     (flush_rx       ),
        .mat       (mat_a          ),
        .recv_done (recv_a_done    ),
        .rx_err    (rx_err_a       )
    );

    axis_rx #(
        .N         (N),
        .DATA_W    (DATA_W)
    ) u_axis_rx_b (
        .clk       (clk            ),
        .rst_n     (rst_n          ),
        .s_tdata   (s_axis_b_tdata ),
        .s_tvalid  (s_axis_b_tvalid),
        .s_tlast   (s_axis_b_tlast ),
        .s_tready  (s_axis_b_tready),
        .flush     (flush_rx       ),
        .mat       (mat_b          ),
        .recv_done (recv_b_done    ),
        .rx_err    (rx_err_b       )
    );

    mat_addsub #(
        .N        (N),
        .DATA_W   (DATA_W)
    ) u_mat_addsub (
        .mat_a    (mat_a          ),
        .mat_b    (mat_b          ),
        .sub      (|op            ),
        .mat_c    (mat_addsub_res ),
        .overflow (addsub_overflow)
    );

    mat_transpose #(
        .N      (N),
        .DATA_W (DATA_W)
    ) u_mat_transpose (
        .mat_a   (mat_a            ),
        .mat_c   (mat_transpose_res)
    );

    mat_det #(
        .N        (N),
        .DATA_W   (DATA_W)
    ) u_mat_det (
        .clk       (clk           ),
        .rst_n     (rst_n         ),
        .mat_a     (mat_a         ),
        .det       (det           ),
        .start     (det_calc_start),
        .singular  (det_singular  ),
        .calc_done (calc_done     )
    );

    axis_tx #(
        .N         (N),
        .DATA_W    (DATA_W)
    ) u_axis_tx (
        .clk       (clk              ),
        .rst_n     (rst_n            ),
        .send      (send             ),
        .is_scalar (&op              ),
        .mat_in    (res_mat          ),
        .scalar_in (det              ),
        .m_tdata   (m_axis_res_tdata ),
        .m_tvalid  (m_axis_res_tvalid),
        .m_tlast   (m_axis_res_tlast ),
        .m_tready  (m_axis_res_tready)
    );

endmodule