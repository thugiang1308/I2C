module I2C_TOP (
    input clk , 
    input rst_n,
    input ena , 
    input rw , 
    input [7:0] data_in,
    input [6:0] address ,
    // input n_byte ,
    output valid,
    output [7:0] data_out ,
    output scl_out ,
    output sda_out
);
reg clk_out ;
reg W_ena, R_ena, st_ena, counter;
I2C_div_clk # (.heso (8) ,
               .size (3)) 
 uut (
    .clk(clk),
    .rst_n(rst_n),
    .clk_out(clk_out)
);
I2C_data_path uut_1 (
    .scl_in(clk_out),
    .rst_n(rst_n),
    .W_ena(W_ena),
    .R_ena(R_ena),
    .sda_in(clk_out),
    .data_in(data_in),
    .address(address),
    .ena(ena),
    .data_out(data_out),
    .valid(valid),
    .counter (counter),
    .sda_out(sda_out),
    .scl_out(scl_out)
);
I2C_control uut_2 (
    . rst_n(rst_n) ,
    . rw(rw) ,
    . ena(ena),
    . sda_in(sda_in),
    . counter(counter) ,
    . W_ena (W_ena),
    . R_ena (R_ena),
    . st_ena(st_ena),
    . scl_in(scl_in),
    .scl_out(scl_out)
);
endmodule

