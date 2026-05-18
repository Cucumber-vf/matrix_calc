interface clk_bfm;

    bit clk;

    task drive (int period);
        if ((period <= 0) || (period % 2 != 0)) begin
            `uvm_warning("clk_bfm", "clk period is less or equal to zero or not even, it was changed ");
            period = 10;
        end

        forever begin
            #(period/2) clk <= ~clk;
        end
    endtask


endinterface