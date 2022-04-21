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
    inout reg i2c_sda
);
wire scl_in ;
wire scl_n, scl_p ;
wire scl_ena, W_ena ;
wire [3:0] state ; 
wire st_ena; //  start_ena ;
//wire W_ena, R_ena, St_ena, counter;
I2C_div_clk # (.heso (2) ,
               .size (1)) 
 I2C_div_clk (
    .clk(clk),
    .rst_n(rst_n),
    .clk_out (scl_in),
    .scl_p(scl_p),
    .scl_n(scl_n)
);

I2C_data_path I2C_data_path (
    .clk(clk),
    .rst_n(rst_n),
    .rw(rw),
    .sda_in(i2c_sda),
    .data_in(data_in),
    .address(address),
    .scl_n(scl_n),
    . state(state),
    
    .data_out(data_out),
    .valid(valid),
    .sda_out(sda_out),
    .counter(counter),
    .st_ena(st_ena)
);

I2C_control I2C_control (
    . clk(clk),
    . rst_n(rst_n) ,
    . rw(rw) ,
    . ena(ena),
    . sda_in(i2c_sda),
    . counter(counter) ,
    . st_ena(st_ena),
    . scl_n(scl_n),

    . W_ena(W_ena),
    . state(state),
    . scl_ena(scl_ena)
);
assign scl_out = (scl_ena == 1 ) ? 1 : scl_in ;
assign i2c_sda = (W_ena == 1 ) ? sda_out : 1'bz ;
endmodule

