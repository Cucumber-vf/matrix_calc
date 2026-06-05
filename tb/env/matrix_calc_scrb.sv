`uvm_analysis_imp_decl(_rst)
`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_axis_in_a)
`uvm_analysis_imp_decl(_axis_in_b)
`uvm_analysis_imp_decl(_axis_out)
 
class matrix_calc_scrb #(parameter N = 4, parameter DATA_W = 16) extends uvm_scoreboard;
 
    `uvm_component_param_utils(matrix_calc_scrb #(N, DATA_W))
 
    uvm_analysis_imp_rst       #(rst_seq_item,            matrix_calc_scrb #(N, DATA_W)) rst_exp;
    uvm_analysis_imp_apb       #(apb_seq_item,            matrix_calc_scrb #(N, DATA_W)) apb_exp;
    uvm_analysis_imp_axis_in_a #(axis_seq_item #(DATA_W), matrix_calc_scrb #(N, DATA_W)) axis_in_a_exp;
    uvm_analysis_imp_axis_in_b #(axis_seq_item #(DATA_W), matrix_calc_scrb #(N, DATA_W)) axis_in_b_exp;
    uvm_analysis_imp_axis_out  #(axis_seq_item #(DATA_W), matrix_calc_scrb #(N, DATA_W)) axis_out_exp;
 
    env_config              env_cfg;
    vectors_db #(N, DATA_W) vec_db;
    regs_model              ref_regs;
 
    // Parameters
    localparam int TOTAL = N * N;
    localparam int DET_W = N * DATA_W;
 

    localparam bit CTRL_START = 0;
    localparam bit CTRL_FLUSH = 1;
 
    // Predict state
    typedef enum { S_IDLE, S_RECV, S_WAIT_START, S_COMPUTE, S_RX_ERR } e_pred_state;
    e_pred_state pred_state;
 
    // Int state
    bit in_reset;            
 
    int  a_count;            
    bit  a_in_progress;      
    bit  a_done;             
    bit  a_err;              
    int  a_test_id;         
    bit  a_id_valid;
    logic signed [DATA_W-1:0] a_mat [N][N];
 
    int  b_count;
    bit  b_in_progress;
    bit  b_done;
    bit  b_err;
    int  b_test_id;
    bit  b_id_valid;
    logic signed [DATA_W-1:0] b_mat [N][N];
 
    
    opcodes_e cur_op;
    bit       op_in_flight;   
 
 
    int  out_count;
    logic signed [DATA_W-1:0] out_buf [TOTAL];
 
    bit ovf_pred, sing_pred, comp_status_valid;
 
    // Statistic
    bit check_inputs = 1;       // compare the restored inputs with ref
    int num_checks, num_errors;
    int num_ops_checked, num_apb_checks, num_rx_err, num_flush, num_resets;
 
    // ========================================================================
    function new (string name = "matrix_calc_scrb", uvm_component parent = null);
        super.new(name, parent);
    endfunction
 
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        rst_exp       = new("rst_exp", this);
        apb_exp       = new("apb_exp", this);
        axis_in_a_exp = new("axis_in_a_exp", this);
        axis_in_b_exp = new("axis_in_b_exp", this);
        axis_out_exp  = new("axis_out_exp", this);
 
        if (!uvm_config_db #(env_config)::get(this, "", "env_cfg", env_cfg)) begin
            `uvm_fatal("BUILD_PHASE", "No env_cfg found for scoreboard")
        end
        vec_db   = env_cfg.vec_db;
        ref_regs = env_cfg.ref_regs;
 
        do_full_reset();
    endfunction
    // ========================================================================
    
    //  Help functions
    function opcodes_e get_reg_op();
        return opcodes_e'(ref_regs.apb_regs[REG_OP].value[1:0]);
    endfunction
 
    function bit op_needs_b(opcodes_e op);
        return (op inside {ADD, SUB});
    endfunction
 
    function bit busy_pred();
        return (pred_state inside {S_WAIT_START, S_COMPUTE});
    endfunction
 
    function bit addr_is_valid(logic [7:0] addr);
        foreach (valid_addresses[i])
            if (addr == valid_addresses[i]) return 1'b1;
        return 1'b0;
    endfunction
 
    function bit have_ref();
        return op_needs_b(cur_op)
             ? (a_id_valid && b_id_valid && (a_test_id == b_test_id))
             : a_id_valid;
    endfunction
 
    function void predict_result_status();
        bit                       exp_ovf;
        logic signed [DATA_W-1:0] dummy [N][N];
        logic signed [DET_W-1:0]  det;
 
        if (!have_ref()) begin
            comp_status_valid = 0;  
            return;
        end
        case (cur_op)
            ADD:       begin vec_db.get_expected_add(a_test_id, dummy, exp_ovf); ovf_pred = exp_ovf; sing_pred = 1'b0; end
            SUB:       begin vec_db.get_expected_sub(a_test_id, dummy, exp_ovf); ovf_pred = exp_ovf; sing_pred = 1'b0; end
            TRANSPOSE: begin ovf_pred = 1'b0; sing_pred = 1'b0; end
            DET:       begin det = vec_db.get_expected_det(a_test_id); ovf_pred = 1'b0; sing_pred = (det == '0); end
        endcase
        comp_status_valid = 1;
    endfunction
 
    function void reset_inputs();
        a_count = 0; a_in_progress = 0; a_done = 0; a_err = 0; a_id_valid = 0;
        b_count = 0; b_in_progress = 0; b_done = 0; b_err = 0; b_id_valid = 0;
    endfunction
 
    function void do_full_reset();
        ref_regs.reset_regs();              
        reset_inputs();
        out_count    = 0;
        op_in_flight = 0;
        cur_op       = ADD;
        pred_state   = S_IDLE;
        
        ovf_pred = 0; sing_pred = 0; comp_status_valid = 1;
        if (vec_db != null) vec_db.clear_queues();
    endfunction
 
    function void enter_rx_err(string why);
        op_in_flight = 0;
        pred_state   = S_RX_ERR;
        num_rx_err++;
        `uvm_info("SCRB/RXERR", $sformatf("RX_ERR predicted: %s", why), UVM_MEDIUM)
    endfunction
 
    function void reevaluate();
        opcodes_e op = get_reg_op();
 
        if (pred_state inside {S_WAIT_START, S_COMPUTE, S_RX_ERR}) return;
 
        if (a_done && a_err) begin
            enter_rx_err($sformatf("Channel A: pkt_w=%0d (expected %0d)", a_count, TOTAL));
            return;
        end
 
        if (op_needs_b(op) && b_done && b_err) begin
            enter_rx_err($sformatf("Channel B: pkt_w=%0d (expected %0d)", b_count, TOTAL));
            return;
        end
 
        if (a_done && !a_err && (!op_needs_b(op) || (b_done && !b_err))) begin
            cur_op     = op;         
            pred_state = S_WAIT_START;
            `uvm_info("SCRB", $sformatf("Inputs recieved, WAIT_START (op=%s, a_id=%0d)", cur_op.name(), a_test_id), UVM_HIGH)
        end
    endfunction
 
    function string mat2str(logic signed [DATA_W-1:0] m [N][N]);
        string s = "";
        foreach (m[r]) begin
            s = {s, "\n    "};
            foreach (m[r][c]) s = {s, $sformatf("%6d ", m[r][c])};
        end
        return s;
    endfunction
 
    // ========================================================================
    function void write_rst (rst_seq_item item);
        `uvm_info("SCRB", $sformatf("RST transaction, duration=%0d", item.duration), UVM_MEDIUM)
 
        if (item.duration < 0) begin
            in_reset = 1;
            do_full_reset();
            num_resets++;
            `uvm_info("SCRB", "Rst starts: full_reset done", UVM_MEDIUM)
        end
        else begin
            in_reset   = 0;
            pred_state = S_IDLE;     
            `uvm_info("SCRB", "Rst ends: wait for default values of regs", UVM_MEDIUM)
        end
    endfunction
 
    // ========================================================================
    function bit exp_pslverr(logic [7:0] addr, bit wr);
        if (!addr_is_valid(addr))      return 1'b1;  
        if (addr == REG_STATUS && wr)  return 1'b1;  
        return 1'b0;
    endfunction
 
    function void check_status_read(logic [31:0] rd);
        bit exp_rxerr = (pred_state == S_RX_ERR);
        num_checks++;
        if (rd[RX_ERR] !== exp_rxerr) begin
            num_errors++;
            `uvm_error("SCRB/STATUS", $sformatf("RX_ERR mismatch: got=%0b exp=%0b", rd[RX_ERR], exp_rxerr))
        end
        if (comp_status_valid) begin
            if (rd[OVERFLOW] !== ovf_pred) begin
                num_errors++;
                `uvm_error("SCRB/STATUS", $sformatf("OVERFLOW mismatch: got=%0b exp=%0b", rd[OVERFLOW], ovf_pred))
            end
            if (rd[SINGULAR] !== sing_pred) begin
                num_errors++;
                `uvm_error("SCRB/STATUS", $sformatf("SINGULAR mismatch: got=%0b exp=%0b", rd[SINGULAR], sing_pred))
            end
        end
    endfunction
 

    function void write_apb (apb_seq_item item);
        logic [7:0]  addr = item.paddr[7:0];
        bit          wr   = item.pwrite;
        bit          exp_err;
        logic [31:0] exp_rd;
 
        `uvm_info("SCRB", $sformatf("APB %s addr=0x%02h wdata=0x%08h",
                                    wr ? "WRITE" : "READ", addr, item.pwdata), UVM_HIGH)
 
        if (in_reset) return;
 
        exp_err = exp_pslverr(addr, wr);
        num_apb_checks++;
        if (item.pslverr !== exp_err) begin
            num_errors++;
            `uvm_error("SCRB/APB", $sformatf("pslverr mismatch for addr=0x%02h %s: got=%0b exp=%0b",
                                             addr, wr ? "WR" : "RD", item.pslverr, exp_err))
        end
 
        if (exp_err) return;
 
        if (wr) begin
            case (e_regs_addresses'(addr))
                REG_OP: begin
                    if (busy_pred()) begin
                        `uvm_info("SCRB", "Write to REG_OP when BUSY ignored", UVM_MEDIUM)
                    end
                    else begin
                        ref_regs.write_to_reg(addr, item.pwdata);
                        reevaluate();
                    end
                end
                REG_CTRL: begin
                    handle_ctrl(item.pwdata[CTRL_START], item.pwdata[CTRL_FLUSH]);
                end
                REG_STATUS: begin
                    
                end
            endcase
        end
        else begin
            if (addr inside {REG_OP, REG_CTRL}) begin
                ref_regs.read_reg(addr, exp_rd);
                num_checks++;
                if (item.prdata !== exp_rd) begin
                    num_errors++;
                    `uvm_error("SCRB/APB", $sformatf("prdata mismatch for addr=0x%02h: got=0x%08h exp=0x%08h",
                                                     addr, item.prdata, exp_rd))
                end
                else begin
                    `uvm_info("SCRB/APB", $sformatf("READ addr=0x%02h = 0x%08h OK", addr, exp_rd), UVM_HIGH)
                end
            end
            else if (addr == REG_STATUS) begin
                check_status_read(item.prdata);
            end
        end
    endfunction
 
    function void handle_ctrl(bit start, bit flush);
        if (flush) begin
            if (pred_state == S_COMPUTE) begin
                `uvm_info("SCRB", "FLUSH in state COMPUTE ignored", UVM_MEDIUM)
            end
            else begin
                do_flush();
            end
        end
        else if (start) begin
            if (pred_state == S_WAIT_START) begin
                op_in_flight      = 1;
                pred_state        = S_COMPUTE;
                ovf_pred          = 1'b0;
                sing_pred         = 1'b0;
                comp_status_valid = 1'b1;
                `uvm_info("SCRB", $sformatf("START accesed, COMPUTE (op=%s)", cur_op.name()), UVM_MEDIUM)
            end
            else begin
                `uvm_info("SCRB", $sformatf("START ignored (state=%s)", pred_state.name()), UVM_MEDIUM)
            end
        end
    endfunction
 
    function void do_flush();
        if (a_in_progress) void'(vec_db.pop_chan_a());
        if (b_in_progress) void'(vec_db.pop_chan_b());
 
        reset_inputs();
        pred_state = S_IDLE;
        num_flush++;
        `uvm_info("SCRB", "FLUSH processed: recievers dropped, state -> IDLE", UVM_MEDIUM)
    endfunction
 
    // ========================================================================
    function void write_axis_in_a (axis_seq_item #(DATA_W) item);
        if (in_reset) return;
 
        if (!a_in_progress) begin
            a_in_progress = 1;
            a_count       = 0;
            if (pred_state == S_IDLE) pred_state = S_RECV;
        end
 
        if (a_count < TOTAL) a_mat[a_count / N][a_count % N] = item.tdata;
        a_count++;
 
        if (item.is_last) finalize_a();
    endfunction
 
    function void finalize_a();
        int tid;
        bit err = (a_count != TOTAL);   
        tid = vec_db.pop_chan_a();
 
        a_in_progress = 0;
        a_done        = 1;
        a_err         = err;
        a_test_id     = tid;
        a_id_valid    = (tid >= 0);
 
        if (!err && check_inputs && a_id_valid)
            check_input_mat(a_mat, vec_db.vec_A[tid], "A", tid);
 
        reevaluate();
    endfunction
 
    // ========================================================================
    function void write_axis_in_b (axis_seq_item #(DATA_W) item);
        if (in_reset) return;
 
        if (!b_in_progress) begin
            b_in_progress = 1;
            b_count       = 0;
            if (pred_state == S_IDLE) pred_state = S_RECV;
        end
 
        if (b_count < TOTAL) b_mat[b_count / N][b_count % N] = item.tdata;
        b_count++;
 
        if (item.is_last) finalize_b();
    endfunction
 
    function void finalize_b();
        int tid;
        bit err = (b_count != TOTAL);
        tid = vec_db.pop_chan_b();      
 
        b_in_progress = 0;
        b_done        = 1;
        b_err         = err;
        b_test_id     = tid;
        b_id_valid    = (tid >= 0);
 
        if (!err && check_inputs && b_id_valid && op_needs_b(get_reg_op()))
            check_input_mat(b_mat, vec_db.vec_B[tid], "B", tid);
 
        reevaluate();
    endfunction
 
    // ========================================================================
    function void write_axis_out (axis_seq_item #(DATA_W) item);
        if (in_reset) return;
 
        if (out_count == 0 && op_in_flight) predict_result_status();
 
        if (out_count < TOTAL) out_buf[out_count] = item.tdata;
        out_count++;
 
        if (item.is_last) finalize_out();
    endfunction
 
    function void finalize_out();
        int len     = out_count;
        int exp_len = (cur_op == DET) ? N : TOTAL;
 
        if (!op_in_flight) begin
            num_errors++;
            `uvm_error("SCRB/OUT", "Output txn recieved, but start wasn't writed")
        end
 
        if (len != exp_len) begin
            num_errors++;
            `uvm_error("SCRB/OUT", $sformatf("Unexpected res_len: got=%0d, exp=%0d (op=%s)",
                                             len, exp_len, cur_op.name()))
        end
        else begin
            check_result();
        end
 
        ovf_pred          = 1'b0;
        sing_pred         = 1'b0;
        comp_status_valid = 1'b1;
 
        op_in_flight = 0;
        pred_state   = S_IDLE;
 
        reset_inputs();
        out_count = 0;
    endfunction
 
    function void check_result();
        int tid = a_test_id;
        logic signed [DATA_W-1:0] exp_mat [N][N];
        logic signed [DATA_W-1:0] got_mat [N][N];
        bit   exp_ovf;
 
        if (!have_ref()) begin
            `uvm_info("SCRB/RESULT",
                      "Result hasn't ref (input not from vectors_db) — check results skipped",
                      UVM_MEDIUM)
            return;
        end
 
        num_ops_checked++;
 
        case (cur_op)
            ADD: begin
                vec_db.get_expected_add(tid, exp_mat, exp_ovf);
                build_out_mat(got_mat);
                cmp_mat(got_mat, exp_mat, "ADD", tid);
            end
            SUB: begin
                vec_db.get_expected_sub(tid, exp_mat, exp_ovf);
                build_out_mat(got_mat);
                cmp_mat(got_mat, exp_mat, "SUB", tid);
            end
            TRANSPOSE: begin
                vec_db.get_expected_trans(tid, exp_mat);
                build_out_mat(got_mat);
                cmp_mat(got_mat, exp_mat, "TRANS", tid);
            end
            DET: begin
                logic signed [DET_W-1:0] exp_det;
                logic        [DET_W-1:0] got_det;
                exp_det = vec_db.get_expected_det(tid);
                build_out_det(got_det);
                num_checks++;
                if ($signed(got_det) !== $signed(exp_det)) begin
                    num_errors++;
                    `uvm_error("SCRB/RESULT", $sformatf("DET (test_id=%0d) mismatch: got=%0d (0x%0h) exp=%0d (0x%0h)",
                                                        tid, $signed(got_det), got_det, $signed(exp_det), exp_det))
                end
                else begin
                    `uvm_info("SCRB/RESULT", $sformatf("DET (test_id=%0d) = %0d OK", tid, $signed(got_det)), UVM_LOW)
                end
            end
        endcase
    endfunction
 
    function void build_out_mat(output logic signed [DATA_W-1:0] m [N][N]);
        for (int k = 0; k < TOTAL; k++) m[k / N][k % N] = out_buf[k];
    endfunction
 
    function void build_out_det(output logic [DET_W-1:0] det);
        det = '0;
        for (int i = 0; i < N; i++) det[i*DATA_W +: DATA_W] = out_buf[i];
    endfunction
 
    function void cmp_mat(input logic signed [DATA_W-1:0] got [N][N],
                          input logic signed [DATA_W-1:0] exp_m [N][N],
                          input string tag, input int tid);
        bit ok = 1;
        num_checks++;
        foreach (got[r,c]) begin
            if (got[r][c] !== exp_m[r][c]) begin
                ok = 0;
                `uvm_error("SCRB/RESULT", $sformatf("%s (test_id=%0d): mismatch [%0d][%0d]: got=%0d exp=%0d",
                                                    tag, tid, r, c, got[r][c], exp_m[r][c]))
            end
        end
        if (!ok) begin
            num_errors++;
            `uvm_error("SCRB/RESULT", $sformatf("%s (test_id=%0d) mismatch.\n  GOT:%s\n  EXP:%s",
                                                tag, tid, mat2str(got), mat2str(exp_m)))
        end
        else begin
            `uvm_info("SCRB/RESULT", $sformatf("%s (test_id=%0d) OK", tag, tid), UVM_LOW)
        end
    endfunction
 
    function void check_input_mat(input logic signed [DATA_W-1:0] got [N][N],
                                  input logic signed [DATA_W-1:0] ref_m [N][N],
                                  input string ch, input int tid);
        foreach (got[r,c]) begin
            if (got[r][c] !== ref_m[r][c]) begin
                num_errors++;
                `uvm_error("SCRB/INPUT", $sformatf("Channel %s (test_id=%0d): recieved data != ref in [%0d][%0d]: got=%0d exp=%0d",
                                                   ch, tid, r, c, got[r][c], ref_m[r][c]))
                return;
            end
        end
    endfunction
 
    // ========================================================================
    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (!vec_db.chan_a_empty() || !vec_db.chan_b_empty()) begin
            `uvm_warning("SCRB", $sformatf("Queues has unchecked id: A=%0d, B=%0d",
                                           vec_db.chan_a_size(), vec_db.chan_b_size()))
        end
        if (op_in_flight) begin
            `uvm_warning("SCRB", "There is unfinished operation")
        end
    endfunction
 
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCRB",
            $sformatf({"\n=== SCOREBOARD SUMMARY ===",
                       "\n  Total checks        : %0d",
                       "\n  Errors              : %0d",
                       "\n  Op checks           : %0d",
                       "\n  APB checks          : %0d",
                       "\n  RX_ERR num          : %0d",
                       "\n  FLUSH num           : %0d",
                       "\n  RST num             : %0d",
                       "\n=========================="},
                       num_checks, num_errors, num_ops_checked,
                       num_apb_checks, num_rx_err, num_flush, num_resets),
            (num_errors == 0) ? UVM_LOW : UVM_NONE)
 
        if (num_errors != 0)
            `uvm_error("SCRB", $sformatf("Scoreboard finished with %0d errors", num_errors))
    endfunction
 
endclass
 