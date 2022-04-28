module tb_TOP_I2C ;
reg clk, rst_n;
reg ena = 0;
reg rw = 0;
reg [7:0] data_in =0;
reg [6:0] address =0; 
reg [4:0] n_byte = 0  ; 
wire req_w ; 
wire valid ;
wire [7:0] data_out ;
wire scl_out ;
wire i2c_sda ;
wire i2c_bus_free ;
I2C_TOP I2C_TOP (
    .clk(clk),
    .rst_n(rst_n),
    .ena(ena),
    .rw(rw),
    .data_in(data_in),
    .address(address),
    .valid(valid),
    .n_byte(n_byte),

    .req_w(req_w),
    .data_out(data_out),
    .scl_out(scl_out),
    .i2c_bus_free(i2c_bus_free),
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
    data_in = 8'd1 ;
    address = 7'b001_0000 ; 
    n_byte = 5'd4 ;
    @(negedge clk) 
    wait(req_w);
     data_in = 8'hbb ;
     #100;
    @(negedge clk) 
    wait(req_w);
    data_in = 8'd6;
    #100;
    @(negedge clk)  
    wait(req_w);
     data_in = 8'd4;  
    #100;
    //  @(negedge clk) 
    //  wait(i2c_bus_free);// rise when p stop condtion
    // // #100000;
    // rst_n = 0 ;
    // #10 ;
    // rst_n = 1 ;
    // ena = 1 ;
    // address = 7'b001_0000 ; 
    // data_in = 8'd1  ; 
    // rw = 0;
    // n_byte = 5'd1 ;
    //  @ (negedge clk)
    //  wait(i2c_bus_free); // rise when p stop condition
    // // #100000 ;
    // rw = 1 ;  
    // n_byte = 5'd2 ; 
    // #100000 
    $finish ;
end
always #5 clk = ~clk ; 
endmodule 
    