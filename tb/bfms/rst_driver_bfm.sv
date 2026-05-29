interface rst_driver_bfm (output bit rst_n);

    task init_reset;
        rst_n <= 1;
    endtask

    task drive_rst (int duration);
        rst_n <= 0;
        #(duration);
        rst_n <= 1;
    endtask

endinterface