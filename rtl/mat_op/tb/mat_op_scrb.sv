class mat_op_scrb #(parameter N = 4, parameter DATA_W = 16);

    ref_model model;
    
    virtual mat_op_bfm  vbfm;

    function new (virtual mat_op_bfm vbfm, ref_model model);
        this.vbfm = vbfm;
        this.model = model;
    endfunction

    task do_monitor;
        forever begin
            @(posedge vbfm.clk);
            if(vbfm.start) begin
                check_results(vbfm.t);
            end
        end
    endtask

    task check_results (int t);
        if (vbfm.op == 2'b00) begin // op = 00 for add and transpose because in mat_op_tb they are calculated together
                                    // transpose is independent of op
                                    // add calculates when op = 00
            if (vbfm.addsub_overflow !== model.exp_ovf_add[t]) begin
                        $error("[  scrb   ] TEST %0d: ADD overflow mismatch: got %b, expected %b", t, vbfm.addsub_overflow, model.exp_ovf_add[t]);
                    end
            for (int i = 0; i < N; i++) begin
                for (int j = 0; j < N; j++) begin
                    if (vbfm.mat_addsub_res[i][j] !== model.exp_res_add[t][i][j]) begin
                        $error("[  scrb   ] TEST %0d: ADD result mismatch at [%0d][%0d]: got %h, expected %h", t, i, j, vbfm.mat_addsub_res[i][j], model.exp_res_add[t][i][j]);
                    end
                    if (vbfm.mat_transpose_res[i][j] !== model.exp_res_trans[t][i][j]) begin                                                                                  
                        $error("[  scrb   ] TEST %0d: TRANSPOSE result mismatch at [%0d][%0d]: got %h, expected %h", t, i, j, vbfm.mat_transpose_res[i][j], model.exp_res_trans[t][i][j]);
                    end
                end
            end
        end
        else if (vbfm.op == 2'b11) begin // op = 11 for sub and det because in mat_op_tb they are calculated together
                                         // det calculates when op = 11
                                         // sub calculates when |op is 1 (always 1 when op != 00)
            if (vbfm.addsub_overflow !== model.exp_ovf_sub[t]) begin
                        $error("[  scrb   ] TEST %0d: SUB overflow mismatch: got %b, expected %b", t, vbfm.addsub_overflow, model.exp_ovf_sub[t]);
                    end
            for (int i = 0; i < N; i++) begin
                for (int j = 0; j < N; j++) begin
                    if (vbfm.mat_addsub_res[i][j] !== model.exp_res_sub[t][i][j]) begin
                        $error("[  scrb   ] TEST %0d: SUB result mismatch at [%0d][%0d]: got %h, expected %h", t, i, j, vbfm.mat_addsub_res[i][j], model.exp_res_sub[t][i][j]);
                    end
                end
            end

            @(posedge vbfm.clk);
            wait (vbfm.calc_done);
            if ((!vbfm.det_singular && (model.exp_res_det[t] == 0)) ||
                ( vbfm.det_singular && (model.exp_res_det[t] != 0))) begin
                    $error("[  scrb   ] TEST %0d: DETERMINANT singularity mismatch: got %b, expected %b", t, vbfm.det_singular, (model.exp_res_det[t] == 0));
            end
            if (vbfm.det !== model.exp_res_det[t]) begin
                $error("[  scrb   ] TEST %0d: DETERMINANT result mismatch: got %h, expected %h", t, vbfm.det, model.exp_res_det[t]);
            end
        end
    endtask

endclass