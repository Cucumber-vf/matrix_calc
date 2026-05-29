interface clk_gen_bfm;

    bit clk;

    task clk_gen (int period);
        if ((period <= 0) || (period % 2 != 0)) begin
            $warning ("[clk_bfm] WARNING: clk period is less or eqal to zero or not even, it was changed ");
            period = 10;
        end

        forever begin
            #(period/2) clk <= ~clk;
        end
    endtask

endinterface