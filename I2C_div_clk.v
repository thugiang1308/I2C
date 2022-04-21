module I2C_div_clk
# (
    parameter heso = 8 ,
    parameter size = 3 
)
(
    input clk , 
    input rst_n , 
    output reg clk_out,
    output reg scl_p,
    output reg scl_n 
); 

reg [size -1'b1 : 0] Q ;
always @(negedge clk or negedge rst_n) 
begin
    if (~rst_n)                                                        
    begin 
        Q<=0;
        clk_out <= 0 ;
        scl_n <= 0 ;
        scl_p <= 0 ;
    end
    else if (Q == heso -1'b1) 
    begin 
        Q<=0 ;
        clk_out <= !clk_out ; 
        if (clk_out) scl_n <= 1 ;
        else scl_p <= 1 ;
    end
    else 
    begin 
        Q <= Q + 1'b1 ; 
        scl_p <= 0 ; 
        scl_n <= 0 ; 
    end
end 

endmodule                                                      