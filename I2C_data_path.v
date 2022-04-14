module I2C_data_path (
    input clk , rst_n , 
    input W_ena , 
    input R_ena , 
    input sda_in,
    input rw,
    input [7:0] data_in ,
    input [6:0] address , 
    input ena,
    output reg [7:0] data_out ,
    output valid , 
    output reg sda_out, 
    output scl_out, 
    output reg counter 
);
reg st_ena; 
reg [6:0] addr ;
reg [7:0] data ;
reg [7:0] count ;
// always @(posedge clk)
// if (rst_n)
//         scl_out <= 1 ;
// else if (state_reg == IDOL || state_reg == START || state_reg == STOP) 
//         scl_out <= 1 ;
// else    
//         scl_out <= 0 ;
always @(posedge clk or negedge rst_n)
if (~rst_n) 
    begin 
            sda_out <= 1 ; 
            addr<= 7'd0 ;
            data <=8'd0 ;
            st_ena <= 0 ;

    if (ena) 
        begin 
            sda_out <= 1 ;
            addr <= {address,rw};
            count <= 6;
            data <= data_in ;
            st_ena <=  1; 
         end
    if (st_ena) 
        begin 
            sda_out <= addr[count] ;
            count <= count - 1'b1 ;
            if (count == 0) 
            begin
                 counter <= 1 ; 
            end
        end
    if (sda_in == 0) count <= 7 ; 
    
    if (W_ena)
        begin 
            sda_out <= data[count] ; 
            count <= count - 1'b1 ;
            if (count == 0 ) counter <= 1 ; 
        end 
    
    else if (R_ena)
        begin 
            data_out[count] <= sda_in ; 
            count <= count - 1'b1 ;
            if (count == 0 ) counter <= 1 ; 
        end 
    end
    
endmodule 