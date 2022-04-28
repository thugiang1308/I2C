module I2C_TOP (
    input clk , 
    input rst_n,
    input ena , 
    input rw , 
    input [7:0] data_in,
    input [6:0] address ,
    input [4:0] n_byte ,

    output valid,
    output [7:0] data_out ,
    output scl_out ,
    output reg i2c_bus_free, 
    output  req_w ,
    inout reg i2c_sda
);
wire [4:0] count_o ;
wire scl_in ;
wire scl_n, scl_p ;
wire scl_ena, W_ena ;
wire [3:0] state ; 
wire st_ena;
wire stop_done ;
wire count_o_stop ;   //  start_ena ;
//wire W_ena, R_ena, St_ena, counter;
wire scl_tmp;
I2C_div_clk # (.heso (2) ,
               .size (1)) 
 I2C_div_clk (
    .clk(clk),
    .rst_n(rst_n),
    .clk_out (scl_in),
    .scl_tmp(scl_tmp),
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
    .state(state),
    .stop_done(stop_done),
    .count_o_stop(count_o_stop),

    .data_out(data_out),
    // .req_w(req_w),
    .sda_out(sda_out),
    .counter(counter),
    .st_ena(st_ena),
    .count_o(count_o)
);

I2C_control I2C_control (
    .clk(clk),
    .rst_n(rst_n) ,
    .rw(rw) ,
    .ena(ena),
    .sda_in(i2c_sda),
    .counter(counter) ,
    .scl_p(scl_p),
    .st_ena(st_ena),
    .count_o_stop(count_o_stop),
    .scl_n(scl_n),
    .stop_done(stop_done),
    .count_o(count_o),
    .req_w(req_w),
    .n_byte(n_byte),
    .W_ena(W_ena),
    .state(state),
    .valid(valid),
    .scl_ena(scl_ena)
);
always @(posedge clk or negedge rst_n )
begin 
    if(~ rst_n) begin 
        i2c_bus_free  <= 0 ; 
        end 
    else begin 
        if (stop_done ) 
             begin 
            i2c_bus_free <= 1 ; 
        end
        else begin 
            i2c_bus_free <= 0 ;
        end
    end
end

// assign req_w = (valid) ? 1:0 ; 
assign scl_out = (scl_ena == 1 ) ? 1 : scl_tmp ;
//assign i2c_sda = (~sda_out ) ? 1'b0 : 1'bz ;
assign i2c_sda = (W_ena )  ? sda_out : 1'bz;
endmodule

