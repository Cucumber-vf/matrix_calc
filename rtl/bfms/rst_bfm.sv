interface rst_bfm;

    bit rst_n;

    task rst_gen (int duration, int freq);
        if (duration <= 0) begin
            $warning ("[rst_bfm] WARNING: rst duration is less or eqal to zero, it was changed ");
            duration = 20;
        end
        if (freq == 0) begin  // freq < 0 is meaning off reset on fly
            $warning ("[rst_bfm] WARNING: rst freq is eqal to zero, it was changed ");
            freq = 300;
        end
        
        forever begin
            rst_n <= 0;
            #(duration);
            rst_n <= 1;
            wait (freq > 0);
            #(freq);
        end
    endtask

endinterface