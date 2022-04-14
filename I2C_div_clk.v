module I2C_div_clk
# (
    parameter heso = 8 ,
    parameter size = 3 
)
(
    input clk , 
    input rst_n , 
    output reg clk_out
); 
reg [size -1'b1 : 0] Q ;
always @(posedge clk or negedge rst_n) 
begin
    if (~rst_n) 
    begin 
        Q<=0;
        clk_out <= 0 ;
    end
    else if (Q == heso -1'b1) 
    begin 
        Q<=0 ;
        clk_out <= !clk_out ; 
    end
    else 
        Q <= Q + 1'b1 ; 
end 
endmodule 