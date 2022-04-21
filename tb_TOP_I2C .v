module tb_TOP_I2C ;
reg clk, rst_n;
reg ena = 0;
reg rw = 0;
reg [7:0] data_in =0;
reg [6:0] address =0; 
wire valid ;
wire [7:0] data_out ;
wire scl_out ;
wire i2c_sda ;
I2C_TOP I2C_TOP (
    .clk(clk),
    .rst_n(rst_n),
    .ena(ena),
    .rw(rw),
    .data_in(data_in),
    .address(address),
    .valid(valid),
    .data_out(data_out),
    .scl_out(scl_out),
    .i2c_sda(i2c_sda)
);
i2c_slave_model i2c_slave_model (
    .scl(scl_out),
    .sda(i2c_sda)
); 
pullup p1(i2c_sda);
pullup p2 (scl_out);
initial begin 
    clk = 0 ;
    rst_n = 0 ; 
    #10 ;
    rst_n = 1 ;
    ena = 1 ;
    rw = 0;
    data_in = 8'd0 ;
    address = 7'b001_0000 ; 
    #100000 
    $finish ;
end
always #5 clk = ~clk ; 
endmodule 
    