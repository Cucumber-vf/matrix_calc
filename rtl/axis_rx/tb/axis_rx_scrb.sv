class axis_rx_scrb #(parameter N = 4, parameter DATA_W = 16);

    virtual axis_rx_bfm  vbfm;

    int cnt;
    int recv_count;
    int max_recv_count;

    function new (virtual axis_rx_bfm vbfm, int max_recv_count);
        this.vbfm = vbfm;
        this.max_recv_count = max_recv_count;
    endfunction

    task do_monitor;
        forever begin
            @(posedge vbfm.clk or negedge vbfm.rst_n);
            if (~vbfm.rst_n)
                process_reset();
            else if (vbfm.flush)
                cnt = 0;
            else if (vbfm.s_tvalid & vbfm.s_tready)
                do_check();
        end
    endtask

    task do_check;
        int exp_data = vbfm.s_tdata;
        if (vbfm.s_tlast) begin
            #1;
            if (vbfm.mat[cnt/N][cnt%N] !== exp_data)
                $error("[  scrb  ] ERROR: Inv MAT[%0d][%0d] data: got %h, expected %h                    (%0t)", 
                    cnt/N, cnt%N, vbfm.mat[cnt/N][cnt%N], exp_data, $time);

            if (cnt != N*N - 1) begin
                if (!vbfm.rx_err) 
                    $error("[  scrb  ] ERROR: RX_ERR not asserted when receive tlast too early at count %0d  (%0t)", cnt, $time);
                if (vbfm.s_tready)
                    $error("[  scrb  ] ERROR: S_TREADY asserted when receive tlast too early at count %0d    (%0t)", cnt, $time);
            end
            else begin
                if (!vbfm.recv_done)
                    $error("[  scrb  ] ERROR: RECV_DONE not asserted when receive done                       (%0t)", cnt, $time);
                $display("[  scrb  ] INFO: Received matrix #%0d successfully                    (%0t)", recv_count, $time);
                recv_count++;
            end
            
            cnt = 0;
        end
        else begin
            #1;
            if (vbfm.mat[cnt/N][cnt%N] !== exp_data)
                $error("[  scrb  ] ERROR: Inv MAT[%0d][%0d] data: got %h, expected %h                    (%0t)", 
                    cnt/N, cnt%N, vbfm.mat[cnt/N][cnt%N], exp_data, $time);
            if (vbfm.recv_done)
                $error("[  scrb  ] ERROR: RECV_DONE asserted when receive in progress                    (%0t)", cnt, $time);
            cnt++;
        end

        if (recv_count == max_recv_count) begin
            $display ("===========================AXIS_rx random test finish===========================");
            $finish();
        end    
    endtask

    task process_reset;
        #1;
        if (vbfm.s_tready)
            $error("[  scrb  ] ERROR: S_TREADY should be deasserted during reset                      (%0t)", $time);
        if (vbfm.recv_done)
            $error("[  scrb  ] ERROR: RECV_DONE should be deasserted during reset                     (%0t)", $time);
        if (vbfm.rx_err)
            $error("[  scrb  ] ERROR: RX_ERR should be deasserted during reset                        (%0t)", $time);
        cnt = 0;
    endtask

endclass