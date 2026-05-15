class axis_tx_scrb #(parameter N = 4, parameter DATA_W = 16);

    virtual axis_tx_bfm  vbfm;

    int cnt;
    int recv_count;
    int max_recv_count;
    bit idle_flag;

    function new (virtual axis_tx_bfm vbfm, int max_recv_count);
        this.vbfm = vbfm;
        this.max_recv_count = max_recv_count;
    endfunction

    task do_monitor;
        forever begin
            @(posedge vbfm.clk or negedge vbfm.rst_n);
            if (~vbfm.rst_n)
                process_reset();
            else if (idle_flag)
                check_idle();
            else if (vbfm.m_tvalid & vbfm.m_tready)
                do_check();
        end
    endtask

    task do_check;
        if (vbfm.m_tlast) begin
            if (vbfm.is_scalar) begin
                if (vbfm.m_tdata !== vbfm.scalar_in[cnt * DATA_W +: DATA_W])               
                    $error("[  scrb  ] ERROR: Inv M_TDATA value: got %h, expected %h (sc[%0d:%0d])      (%0t)", 
                        vbfm.m_tdata, vbfm.scalar_in[cnt * DATA_W +: DATA_W], cnt * DATA_W, (cnt + 1) * DATA_W - 1, $time);

                if (cnt != N - 1)
                    $error("[  scrb  ] ERROR: M_TLAST asserted before send all scalar                   (%0t)", $time);
                else begin
                    $display("[  scrb  ] INFO: Received data #%0d (scalar) successfully                  (%0t)", recv_count, $time);
                    recv_count++;
                end
            end 
            else begin
                if (vbfm.m_tdata !== vbfm.mat_in[cnt/N][cnt%N])               
                    $error("[  scrb  ] ERROR: Inv M_TDATA value: got %h, expected %h (mat[%0d:%0d])     (%0t)", 
                        vbfm.m_tdata, vbfm.mat_in[cnt/N][cnt%N], cnt/N, cnt%N, $time);

                if (cnt != N*N - 1)
                    $error("[  scrb  ] ERROR: M_TLAST asserted before send all mat                      (%0t)", $time);
                else begin
                    $display("[  scrb  ] INFO: Received data #%0d (matrix) successfully                  (%0t)", recv_count, $time);
                    recv_count++;
                end
            end
            cnt = 0;
            idle_flag = 1;
        end
        else begin
            if (vbfm.is_scalar) begin
                if (vbfm.m_tdata !== vbfm.scalar_in[cnt * DATA_W +: DATA_W])               
                    $error("[  scrb  ] ERROR: Inv M_TDATA value: got %h, expected %h (sc[%0d:%0d])      (%0t)", 
                        vbfm.m_tdata, vbfm.scalar_in[cnt * DATA_W +: DATA_W], cnt * DATA_W, (cnt + 1) * DATA_W - 1, $time);
            end 
            else begin
                if (vbfm.m_tdata !== vbfm.mat_in[cnt/N][cnt%N])               
                    $error("[  scrb  ] ERROR: Inv M_TDATA value: got %h, expected %h (mat[%0d:%0d])     (%0t)", 
                        vbfm.m_tdata, vbfm.mat_in[cnt/N][cnt%N], cnt/N, cnt%N, $time);
            end
            cnt++;
        end

        if (recv_count == max_recv_count) begin
            $display ("===========================AXIS_tx random test finish===========================");
            $finish();
        end    
    endtask

    task check_idle;
        if (vbfm.m_tvalid)
            $error("[  scrb  ] ERROR: State must be idle but M_TVALID is asserted                     (%0t)", $time);
        if (vbfm.m_tlast)
            $error("[  scrb  ] ERROR: State must be idle but M_TLAST is asserted                      (%0t)", $time);
        
        if (vbfm.send)
            idle_flag = 0;
    endtask

    task process_reset;
        cnt = 0;
        idle_flag = 1;
        #1;
        if (vbfm.m_tvalid)
            $error("[  scrb  ] ERROR: M_TVALID should be deasserted during reset                      (%0t)", $time);
        if (vbfm.m_tlast)
            $error("[  scrb  ] ERROR: M_TLAST should be deasserted during reset                       (%0t)", $time);
    endtask

endclass