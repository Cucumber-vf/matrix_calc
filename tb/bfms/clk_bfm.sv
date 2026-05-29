interface clk_bfm (output bit clk);

    task drive_clk (int period);
        if ((period <= 0) || (period % 2 != 0)) begin
            $warning("[clk_bfm] clk period is less or equal to zero or not even, it was changed");
            period = 10;
        end

        forever begin
            #(period/2) clk <= ~clk;
        end
    endtask

endinterface