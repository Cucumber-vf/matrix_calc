interface axis_slave_driver_bfm #(parameter DATA_W = 16) (input clk, input rst_n);

    // AXIS Master Interface
    logic signed [DATA_W-1:0] m_tdata;
    logic                     m_tvalid;
    logic                     m_tlast;
    logic                     m_tready;

    task axis_slave_rst;
        m_tready <= 0;
    endtask

    task drive (tready_policy_e tready_policy, int min_delay, int max_delay);
        fork
            forever begin
                case(tready_policy)
                    ALWAYS_HIGH: begin
                        @(posedge clk);
                        m_tready <= 1;
                    end
                    TOGGLE: begin
                        repeat ($urandom_range(min_delay, max_delay)) @(posedge clk);
                        m_tready <= 1;
                        @(posedge clk);
                        m_tready <= 0;
                    end
                endcase
            end
        join_none
        wait(~rst_n);
        disable fork
        axis_slave_rst();
        wait( rst_n);
    endtask

endinterface