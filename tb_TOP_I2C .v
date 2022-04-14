module tb_TOP_I2C ;
reg clk, rst_n;
reg ena;
reg rw ;
reg [7:0] data_in ;
reg [6:0] address ;
wire valid ;
wire [7:0] data_out ;
wire scl_out ;
wire sda_out ;
I2C_TOP uut (
    .clk(clk),
    .rst_n(rst_n),
    .ena(ena),
    .rw(rw),
    .data_in(data_in),
    .address(address),
    .valid(valid),
    .data_out(data_out),
    .scl_out(scl_out),
    .sda_out(sda_out)
);
initial begin 
    clk = 0 ;
    rst_n = 0 ; 
    #10 ;
    rst_n = 1 ;
    ena = 1 ;
    rw = 1 ;
    data_in = 8'd10 ;
    address = 7'd8 ; 
end
always #5 clk = ~clk ; 
endmodule 
    