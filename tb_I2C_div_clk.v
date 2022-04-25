module tb_I2C_div_clk ;
reg clk ;
reg rst_n ;
wire scl_n ;
wire scl_p ;
I2C_div_clk #  (
    . heso (2),
    . size (1) 
) uut 
(
    . clk (clk) , 
    . rst_n (rst_n), 
    . scl_n(scl_n),
    . scl_p (scl_p) 
); 
initial 
    begin 
        clk = 0 ;
        rst_n = 0; 
        #10 ; 
        rst_n = 1;
    end
    always #5  clk = ~ clk ;
endmodule 