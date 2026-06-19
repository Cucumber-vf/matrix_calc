class matrix_calc_scrb #(parameter N = 4, parameter DATA_W = 16) extends uvm_scoreboard;
 
    `uvm_component_param_utils(matrix_calc_scrb #(N, DATA_W))
 
    uvm_analysis_export #(rst_seq_item) rst_exp;
    uvm_analysis_export #(apb_seq_item) apb_exp;
    uvm_analysis_export #(axis_seq_item #(DATA_W)) axis_in_exp [2];
    uvm_analysis_export #(axis_seq_item #(DATA_W)) axis_out_exp;
    uvm_analysis_export #(axis_master_tready_seq_item) axis_in_tready_exp [2];
    uvm_analysis_export #(axis_slave_tvalid_seq_item ) axis_out_tvalid_exp;

    uvm_tlm_analysis_fifo #(rst_seq_item) rst_fifo;
    uvm_tlm_analysis_fifo #(apb_seq_item) apb_fifo;
    uvm_tlm_analysis_fifo #(axis_seq_item #(DATA_W)) axis_in_fifo [2];
    uvm_tlm_analysis_fifo #(axis_seq_item #(DATA_W)) axis_out_fifo;
    uvm_tlm_analysis_fifo #(axis_master_tready_seq_item) axis_in_tready_fifo [2];
    uvm_tlm_analysis_fifo #(axis_slave_tvalid_seq_item ) axis_out_tvalid_fifo;
 
    env_config              env_cfg;
    vectors_db #(N, DATA_W) vec_db;
    regs_model              ref_regs;

    // ======================================================================== //
    //                       Parameters and values                              //
    // ======================================================================== //

    // ==========
    // Parameters
    // ========== 

    localparam int TOTAL = N * N;
    localparam int DET_W = N * DATA_W;
 
    // Bits position in control reg
    localparam bit CTRL_START = 0;
    localparam bit CTRL_FLUSH = 1;
 
    // ===============
    // Predicted state
    // =============== 
    
    typedef enum { S_IDLE, S_RECV, S_WAIT_START, S_COMPUTE, S_SEND, S_RX_ERR } e_pred_state;
    e_pred_state pred_state;

    bit [1:0] rx_ready;
 
    // ==============
    // Internal state
    // ============== 

    bit in_reset;            
    
    // In channels
    int  count       [2];            
    bit  in_progress [2];      
    bit  done        [2];             
    bit  err         [2];              
    int  test_id     [2];         
    bit  id_valid    [2];
    logic signed [DATA_W-1:0] mat [2][N][N];
 
    // Result channel
    int  out_count;
    logic signed [DATA_W-1:0] out_buf [TOTAL];

    // Operation state
    opcodes_e cur_op;
    bit       op_in_flight;   

    // Calc status checking
    bit check_calc_status;
    bit calc_status_valid;
 
    // Statistic
    bit  check_inputs = 1;       // compare the restored inputs with ref
    int  num_errors;
    int  num_ops_checked, num_rx_err, num_flush, num_resets;
 
    // ======================================================================== //
    //                       Constructor and UVM phases                         //
    // ======================================================================== //

    function new (string name = "matrix_calc_scrb", uvm_component parent = null);
        super.new(name, parent);
    endfunction
 
    function void build_phase (uvm_phase phase);
        if (!uvm_config_db #(env_config)::get(this, "", "env_cfg", env_cfg)) begin
            `uvm_fatal("BUILD_PHASE", "No env_cfg found for scoreboard")
        end
        vec_db   = env_cfg.vec_db;
        ref_regs = env_cfg.ref_regs;

        check_calc_status = env_cfg.axis_s_cfg.has_tvalid_monitor;

        rst_exp  = new("rst_exp", this);
        rst_fifo = new("rst_fifo", this);

        apb_exp  = new("apb_exp", this);
        apb_fifo = new("apb_fifo", this);

        foreach (axis_in_exp[i]) begin
            axis_in_exp[i]  = new($sformatf("axis_in%0d_exp", i), this);
            axis_in_fifo[i] = new($sformatf("axis_in%0d_fifo", i), this);
            if (env_cfg.axis_m_cfg[i].has_tready_monitor) begin
                axis_in_tready_exp[i]  = new($sformatf("axis_in%0d_tready_exp", i), this);
                axis_in_tready_fifo[i] = new($sformatf("axis_in%0d_tready_fifo", i), this);
            end
        end

        axis_out_exp   = new("axis_out_exp", this);
        axis_out_fifo  = new("axis_out_fifo", this);
        if (env_cfg.axis_s_cfg.has_tvalid_monitor) begin
            axis_out_tvalid_exp  = new("axis_out_tvalid_exp", this);
            axis_out_tvalid_fifo = new("axis_out_tvalid_fifo", this);
        end

        do_full_reset();
    endfunction

    function void connect_phase (uvm_phase phase);
        rst_exp.connect(rst_fifo.analysis_export);
        apb_exp.connect(apb_fifo.analysis_export);
        foreach (axis_in_exp[i]) begin
            axis_in_exp[i].connect(axis_in_fifo[i].analysis_export);
            if (env_cfg.axis_m_cfg[i].has_tready_monitor) begin
                axis_in_tready_exp[i].connect(axis_in_tready_fifo[i].analysis_export);
            end
        end
        axis_out_exp.connect(axis_out_fifo.analysis_export);
        if (env_cfg.axis_s_cfg.has_tvalid_monitor) begin
            axis_out_tvalid_exp.connect(axis_out_tvalid_fifo.analysis_export);
        end
    endfunction

    task run_phase (uvm_phase phase);
        rst_seq_item            rst_item;
        apb_seq_item            apb_item;
        axis_seq_item #(DATA_W) axis_item;

        axis_master_tready_seq_item axis_m_tready_item;
        axis_slave_tvalid_seq_item  axis_s_tvalid_item;

        forever begin
            env_cfg.clk_cfg.wait_for_clock(1);
            #1; // so that all write methods are executed

            // Due to this delay, 
            // all basic methods check the state in the current cycle and evaluate it for the next one, 
            // when the methods for tvalid and tready check the state in that *next* cycle.

            if (rst_fifo.try_get(rst_item)) begin
                process_rst(rst_item);
            end

            if (axis_out_fifo.try_get(axis_item)) begin
                process_axis_out(axis_item);
            end

            // =========================================================
            // After AXIS out processing 
            // for correct tvalid deasserting error detection

            if (axis_out_tvalid_fifo.try_get(axis_s_tvalid_item)) begin
                process_axis_out_tvalid(axis_s_tvalid_item);
            end

            // Before APB processing
            // for correct SEND state and calc status predicting,
            // and correct tvalid asserting error detection
            // =========================================================

            if (apb_fifo.try_get(apb_item)) begin
                process_apb(apb_item);
            end

            foreach (axis_in_fifo[i]) begin
                if (axis_in_fifo[i].try_get(axis_item)) begin
                    process_axis_in(axis_item, i);
                end
            end
        
            case (pred_state)
                S_IDLE: begin
                    ref_regs.apb_regs[REG_STATUS].value = '0;
                    reset_inputs();
                    calc_status_valid = 0;
                end
                S_WAIT_START: begin
                    ref_regs.apb_regs[REG_STATUS].value[BUSY] = 1'b1;
                end
                S_RX_ERR: begin
                    ref_regs.apb_regs[REG_STATUS].value[BUSY]   = 1'b1;
                    ref_regs.apb_regs[REG_STATUS].value[RX_ERR] = 1'b1;
                end
            endcase
            
            // =========================================================
            // After all processing methods of actual cycle
            // for correct tready processing of the *next* cycle

            foreach (axis_in_fifo[i]) begin
                if (axis_in_tready_fifo[i].try_get(axis_m_tready_item)) begin
                    process_axis_in_tready(axis_m_tready_item, i);
                end
            end
        end
    endtask

    function void check_phase(uvm_phase phase);
        if (!vec_db.chan_a_empty() || !vec_db.chan_b_empty()) begin
            `uvm_warning("SCRB", $sformatf("Queues has unchecked id: A=%0d, B=%0d",
                                           vec_db.chan_a_size(), vec_db.chan_b_size()))
        end
        if (op_in_flight) begin
            `uvm_warning("SCRB", "There is unfinished operation")
        end
    endfunction
 
    function void report_phase(uvm_phase phase);
        `uvm_info("SCRB",
            $sformatf({"\n=== SCOREBOARD SUMMARY ===",
                       "\n  Errors              : %0d",
                       "\n  Op checks           : %0d",
                       "\n  RX_ERR num          : %0d",
                       "\n  FLUSH num           : %0d",
                       "\n  RST num             : %0d",
                       "\n=========================="},
                       num_errors, num_ops_checked,
                       num_rx_err, num_flush, num_resets),
            (num_errors == 0) ? UVM_LOW : UVM_NONE)
 
        if (num_errors != 0)
            `uvm_error("SCRB", $sformatf("Scoreboard finished with %0d errors", num_errors))
    endfunction
 
    // ======================================================================== //
    //                       RST transacrion                                    //
    // ======================================================================== //

    function void process_rst (rst_seq_item item);
        `uvm_info("SCRB", $sformatf("RST transaction, duration=%0d", item.duration), UVM_MEDIUM)
 
        if (item.duration < 0) begin // duration = -1 is a signal of beginning of reset
            in_reset = 1;
            do_full_reset();
            num_resets++;
            `uvm_info("SCRB", "Rst starts: full_reset done", UVM_MEDIUM)
        end
        else begin
            in_reset   = 0;     
            `uvm_info("SCRB", "Rst ends", UVM_MEDIUM)
        end
    endfunction

    // ======================================================================== //
    //                       APB transacrion                                    //
    // ======================================================================== //

    function void process_apb (apb_seq_item item);
        bit          exp_err;
        logic [31:0] exp_rd;

        if (in_reset) begin
            `uvm_error("SCRB/APB", "Got APB transaction in reset")
            return;
        end
 
        `uvm_info("SCRB", $sformatf("APB %s addr=0x%02h wdata=0x%08h",
                                    item.pwrite ? "WRITE" : "READ", item.paddr, item.pwdata), UVM_HIGH)
        
        exp_err = exp_pslverr(item.paddr, item.pwrite);
        if (item.pslverr !== exp_err) begin
            num_errors++;
            `uvm_error("SCRB/APB", $sformatf("PSLVERR mismatch for addr=0x%02h %s: got=%0b exp=%0b",
                                             item.paddr, item.pwrite ? "WR" : "RD", item.pslverr, exp_err))
        end
 
        if (exp_err) return;
 
        if (item.pwrite) begin
            if (e_regs_addresses'(item.paddr) == REG_CTRL) begin
                handle_ctrl(item.pwdata[CTRL_START], item.pwdata[CTRL_FLUSH]);
            end
            else begin
                ref_regs.write_to_reg(item.paddr, item.pwdata);
                reevaluate();
            end
        end
        else begin
            ref_regs.read_reg(item.paddr, exp_rd);
            if (item.paddr == REG_STATUS) begin
                check_status_read(item.prdata, exp_rd);
            end
            else if (item.prdata !== exp_rd) begin
                num_errors++;
                `uvm_error("SCRB/APB", $sformatf("PRDATA mismatch for addr=0x%02h: got=0x%08h exp=0x%08h",
                                                     item.paddr, item.prdata, exp_rd))
            end
            else begin
                `uvm_info("SCRB/APB", $sformatf("READ addr=0x%02h = 0x%08h OK", item.paddr, exp_rd), UVM_HIGH)
            end
        end
    endfunction
 
    // ======================================================================== //
    //                       AXIS in transacrions                               //
    // ======================================================================== //

    // =======
    // In data
    // =======

    function void process_axis_in (axis_seq_item #(DATA_W) item, bit ch);
        if (in_reset) begin
            `uvm_error("SCRB/IN", "Got AXISin transaction in reset")
            return;
        end

        if (!in_progress[ch]) begin
            if (get_busy_status() && done[ch]) begin
                num_errors++;
                `uvm_error("SCRB/IN", "Got AXISin transaction when busy")
                return;
            end
            in_progress [ch] = 1;
            if (pred_state == S_IDLE) pred_state = S_RECV;  // For case, when tready monitor disabled. 
                                                            // This is an approximate state prediction 
                                                            // (in reality, it might update earlier, 
                                                            // but this is not critical for the scoreboard's operation).
        end

        if (count[ch] < TOTAL) mat[ch][count[ch] / N][count[ch] % N] = item.tdata;
        count[ch]++;
 
        if (item.is_last) finalize_in(ch); 
    endfunction
 
    function void finalize_in(bit ch);
        int tid;  
        tid = ch ? vec_db.pop_chan_b() : vec_db.pop_chan_a();
 
        in_progress[ch] = 0;
        done       [ch] = 1;
        err        [ch] = (count[ch] != TOTAL); 
        test_id    [ch] = tid;
        id_valid   [ch] = (tid >= 0);
 
        if (!err[ch] && check_inputs && id_valid[ch])
            check_input_mat(mat[ch], ch ? vec_db.vec_B[tid] : vec_db.vec_A[tid], 
                                                $sformatf("%s", ch ? "B" : "A"), tid);
 
        reevaluate();
    endfunction

    // =========
    // In tready
    // =========

    function void process_axis_in_tready (axis_master_tready_seq_item item, bit ch);
        if (in_reset) begin
            num_errors++;
            `uvm_error("SCRB/INrdy", "TREADY was asserted during reset")
            return;
        end
    
        if (item.is_assert) begin
            rx_ready[ch] = 1;
            if (pred_state == S_IDLE) begin
                if(&rx_ready) pred_state = S_RECV;
            end
            else begin
                num_errors++;
                `uvm_error("SCRB/INrdy", "TREADY asserted, but there isn't IDLE state")
            end
        end
        else begin
            rx_ready[ch] = 0;
            if (in_progress[ch]) begin
                num_errors++;
                `uvm_error("SCRB/INrdy", "TREADY deasserted, but recovery in progress")
            end    
        end 
    endfunction

    // ======================================================================== //
    //                       AXIS out transacrions                              //
    // ======================================================================== //

    // ========
    // Out data 
    // ========

    function void process_axis_out (axis_seq_item #(DATA_W) item);
        if (in_reset) begin
            `uvm_error("SCRB/OUT", "Got AXISout transaction in reset")
            return;
        end

        if (out_count == 0) begin
            if (pred_state == S_COMPUTE) pred_state = S_SEND;   // For case, when tvalid monitor disabled. 
                                                                // This is an approximate state prediction 
                                                                // (in reality, it might update earlier, 
                                                                // but this is not critical for the scoreboard's operation).
            if (pred_state != S_SEND) begin 
                `uvm_error("SCRB/OUT", "Got AXIS out transaction but there is not SEND state")
                return;
            end 
        end
 
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
 
        op_in_flight = 0;
        out_count    = 0;
        pred_state   = S_IDLE;
    endfunction

    // ==========
    // Out tvalid 
    // ==========

    function void process_axis_out_tvalid (axis_slave_tvalid_seq_item item);
        if (in_reset) begin
            num_errors++;
            `uvm_error("SCRB/OUTval", "TVALID was asserted during reset")
            return;
        end

        if (item.is_assert) begin
            if (pred_state == S_COMPUTE) begin
                pred_state = S_SEND;
                predict_result_status();
            end 
            else begin
                num_errors++;
                `uvm_error("SCRB/OUTval", "TVALID asserted, but previous state isn't COMPUTE")
            end
        end 
        else begin
            if (pred_state != S_IDLE) begin
                num_errors++;
                `uvm_error("SCRB/OUTval", "TVALID deasserted, but there is not IDLE state")
            end
        end
    endfunction
 
    // ======================================================================== //
    //                       Help functions                                     //
    // ======================================================================== //

    // ====================
    // Help reset functions
    // ====================

    function void reset_inputs();
        foreach (axis_in_exp[i]) begin
            count[i] = 0; in_progress[i] = 0; done[i] = 0; err[i] = 0; id_valid[i] = 0;
        end
    endfunction
 
    function void do_full_reset();
        ref_regs.reset_regs();              

        op_in_flight = 0;
        out_count    = 0;
        pred_state   = S_IDLE;
        
        vec_db.clear_queues();
    endfunction
 
    // ==================
    // Help APB functions
    // ==================

    function bit exp_pslverr(logic [7:0] addr, bit wr);
        if (!(addr inside {valid_addresses})) return 1'b1;  
        if (addr == REG_STATUS && wr)  return 1'b1;  
        return 1'b0;
    endfunction

    function void do_flush();
        if (in_progress[0]) void'(vec_db.pop_chan_a());
        if (in_progress[1]) void'(vec_db.pop_chan_b());
 
        pred_state = S_IDLE;
        num_flush++;
        `uvm_info("SCRB", "FLUSH processed: recievers dropped", UVM_MEDIUM)
    endfunction

    function void handle_ctrl(bit start, bit flush);
        if (flush) begin
            if (pred_state == S_COMPUTE) begin
                `uvm_info("SCRB", "FLUSH in state COMPUTE ignored", UVM_MEDIUM)
            end
            else if (pred_state == S_SEND) begin
                `uvm_info("SCRB", "FLUSH in state SEND ignored", UVM_MEDIUM)
            end 
            else begin
                do_flush();
            end
        end
        else if (start) begin
            if (pred_state == S_WAIT_START) begin
                op_in_flight      = 1;
                pred_state        = S_COMPUTE;
                `uvm_info("SCRB", $sformatf("START accesed, COMPUTE (op=%s)", cur_op.name()), UVM_MEDIUM)
            end
            else begin
                `uvm_info("SCRB", $sformatf("START ignored (state=%s)", pred_state.name()), UVM_MEDIUM)
            end
        end
    endfunction
 
    function void check_status_read(logic [31:0] rd, logic [31:0] exp_rd);
        if (rd[BUSY] !== exp_rd[BUSY]) begin
            num_errors++;
            `uvm_error("SCRB/STATUS", $sformatf("BUSY mismatch: got=%0b exp=%0b", rd[BUSY], exp_rd[BUSY]))
        end
        if (rd[RX_ERR] !== exp_rd[RX_ERR]) begin
            num_errors++;
            `uvm_error("SCRB/STATUS", $sformatf("RX_ERR mismatch: got=%0b exp=%0b", rd[RX_ERR], exp_rd[RX_ERR]))
        end
        if (check_calc_status && calc_status_valid) begin
            if (rd[OVERFLOW] !== exp_rd[OVERFLOW]) begin
                num_errors++;
                `uvm_error("SCRB/STATUS", $sformatf("OVERFLOW mismatch: got=%0b exp=%0b", rd[OVERFLOW], exp_rd[OVERFLOW]))
            end
            if (rd[SINGULAR] !== exp_rd[SINGULAR]) begin
                num_errors++;
                `uvm_error("SCRB/STATUS", $sformatf("SINGULAR mismatch: got=%0b exp=%0b", rd[SINGULAR], exp_rd[SINGULAR]))
            end
        end
    endfunction

    // ======================
    // Help AXIS in functions
    // ======================

    function void check_input_mat(input logic signed [DATA_W-1:0] got [N][N],
                                  input logic signed [DATA_W-1:0] ref_m [N][N],
                                  input string ch, input int tid);
        foreach (got[r,c]) begin
            if (got[r][c] !== ref_m[r][c]) begin
                num_errors++;
                `uvm_error("SCRB/IN", $sformatf("Channel %s (test_id=%0d): recieved data != ref in [%0d][%0d]: got=%0d exp=%0d",
                                                   ch, tid, r, c, got[r][c], ref_m[r][c]))
                return;
            end
        end
    endfunction

    // ==============================
    // APB and AXIS in help functions
    // ==============================

    function bit get_busy_status();
        return (ref_regs.apb_regs[REG_STATUS].value[BUSY]);
    endfunction

    function opcodes_e get_reg_op();
        return opcodes_e'(ref_regs.apb_regs[REG_OP].value[1:0]);
    endfunction
 
    function bit op_needs_b(opcodes_e op);
        return (op inside {ADD, SUB});
    endfunction

    function void enter_rx_err(string why);
        op_in_flight = 0;
        pred_state   = S_RX_ERR;

        num_rx_err++;
        `uvm_info("SCRB/RXERR", $sformatf("RX_ERR predicted: %s", why), UVM_MEDIUM)
    endfunction

    function void reevaluate();
        opcodes_e op = get_reg_op();

        if (pred_state != S_RECV) return;
 
        if (done[0] && err[0]) begin
            enter_rx_err($sformatf("Channel A: pkt_w=%0d (expected %0d)", count[0], TOTAL));
            return;
        end
 
        if (op_needs_b(op) && done[1] && err[1]) begin
            enter_rx_err($sformatf("Channel B: pkt_w=%0d (expected %0d)", count[1], TOTAL));
            return;
        end
 
        if (done[0] && !err[0] && (!op_needs_b(op) || (done[1] && !err[1]))) begin
            cur_op     = op;         
            pred_state = S_WAIT_START;
            `uvm_info("SCRB", $sformatf("Inputs recieved, WAIT_START (op=%s, a_id=%0d)", cur_op.name(), test_id[0]), UVM_HIGH)
        end
    endfunction

    // =======================
    // Help AXIS out functions
    // =======================

    function bit have_ref();
        return op_needs_b(cur_op)
             ? (id_valid[0] && id_valid[1] && (test_id[0] == test_id[1]))
             : id_valid[0];
    endfunction
 
    function void predict_result_status();
        bit                       exp_ovf;
        logic signed [DATA_W-1:0] dummy [N][N];
        logic signed [DET_W-1:0]  det;
 
        if (!have_ref()) begin
            calc_status_valid = 0;  
            return;
        end

        ref_regs.apb_regs[REG_STATUS].value[OVERFLOW] = 1'b0; 
        ref_regs.apb_regs[REG_STATUS].value[SINGULAR] = 1'b0; 
        case (cur_op)
            ADD: begin 
                vec_db.get_expected_add(test_id[0], dummy, exp_ovf); 
                ref_regs.apb_regs[REG_STATUS].value[OVERFLOW] = exp_ovf;  
            end
            SUB: begin 
                vec_db.get_expected_sub(test_id[0], dummy, exp_ovf); 
                ref_regs.apb_regs[REG_STATUS].value[OVERFLOW] = exp_ovf;
            end
            DET: begin 
                det = vec_db.get_expected_det(test_id[0]); 
                ref_regs.apb_regs[REG_STATUS].value[SINGULAR] = (det == '0); 
            end
        endcase
        
        calc_status_valid = 1;
    endfunction

    function void check_result();
        int tid = test_id[0];
        logic signed [DATA_W-1:0] exp_mat [N][N];
        logic signed [DATA_W-1:0] got_mat [N][N];
        bit exp_ovf;

        logic signed [DET_W-1:0] exp_det;
        logic        [DET_W-1:0] got_det;
 
        if (!have_ref()) begin
            `uvm_info("SCRB/RESULT",
                      "Result hasn't ref (input not from vectors_db). check results skipped",
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
                exp_det = vec_db.get_expected_det(tid);
                build_out_det(got_det);
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

    function string mat2str(logic signed [DATA_W-1:0] m [N][N]);
        string s = "";
        foreach (m[r]) begin
            s = {s, "\n    "};
            foreach (m[r][c]) s = {s, $sformatf("%6d ", m[r][c])};
        end
        return s;
    endfunction

endclass
 