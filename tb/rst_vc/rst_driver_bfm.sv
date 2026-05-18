interface rst_driver_bfm;

    bit rst_n;

    task drive_rst (input rst_seq_item item);
        rst_n <= 0;
        #(item.duration);
        rst_n <= 1;
    endtask

endinterface