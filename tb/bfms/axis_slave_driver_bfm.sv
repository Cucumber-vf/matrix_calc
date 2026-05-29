import bfm_types_pkg::*;

interface axis_slave_driver_bfm (axis_if intf);

    task drive_tready (tready_policy_e tready_policy, int min_active_dur, int max_active_dur,
                                                      int min_inactive_dur, int max_inactive_dur);
        fork
            forever begin
                case(tready_policy)
                    ALWAYS_HIGH: begin
                        intf.tready <= 1;
                        @(posedge intf.clk);
                    end
                    TOGGLE: begin
                        intf.tready <= 1;
                        repeat ($urandom_range(min_active_dur, max_active_dur)) begin
                            @(posedge intf.clk);
                        end

                        intf.tready <= 0;
                        repeat ($urandom_range(min_inactive_dur, max_inactive_dur)) begin
                            @(posedge intf.clk);
                        end
                    end
                endcase
            end
        join_none
        wait(~intf.rst_n);
        disable fork;
        intf.tready <= 0;
        wait( intf.rst_n);
    endtask

endinterface