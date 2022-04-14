module I2C_control (
    input rst_n ,
    input rw ,
    input ena,
    input sda_in,
    input scl_in,
    input counter ,
    output reg scl_out,
    output W_ena ,
    output R_enas
) ;
// symbolic state declaration 
localparam  [3:0] IDOL     = 4'b0000,
                  START     = 4'b0001,
                  ADDRESS   = 4'b0010,
                  READ_ACK  = 4'b0011, 
                  WRITE     = 4'b0100,
                  READ      = 4'b0101,
                  read_ack_1  = 4'b0110,
                  write_ack   = 4'b0111,
                  STOP        = 4'b1000;
// signal declaration                
reg [2:0] state_reg ,state_next ;
reg st_ena ;
// #(heso = 8,
//   size  = 3) 
// I2C_dic_clk uut (
//     .clk(clk),
//     .rst_n(rst_n),
//     .clk_out(clk_out)
// );
always @(posedge sda_in)
if (rst_n)
        scl_out <= 1 ;
else if (state_reg == IDOL || state_reg == START || state_reg == STOP) 
        scl_out <= 1 ;
else    
        scl_out <= 0 ;
always @(posedge scl_in) 
begin 
    if (~rst_n)
    begin 
        st_ena <= 0;
        state_reg <= IDOL ;
    end
        state_reg <= state_next ;
end
always @* 
begin 
    case (state_reg) 
        IDOL : 
            begin 
                if(ena)
                begin 
                    st_ena <= 1 ;
                    state_next <= START ;
                end
                    else 
                    state_next <= IDOL ;
            end
         START : 
            begin 
                if (st_ena)
                begin 
                state_next <= ADDRESS ;
                end 
                else 
                state_next <= START ;
            end
        ADDRESS :
            begin 
                if (counter) state_next <= READ_ACK ;
                else 
                    state_next <= state_reg ; 
            end
        READ_ACK : 
            begin 
               if (sda_in == 0 )
               begin 
                   if (rw) 
                        state_next <= READ ; 
                    else 
                        state_next <= WRITE ;
               end
               else 
                        state_next <= START ;
            end
        WRITE : 
                begin 
                    if (counter) 
                        state_next <= read_ack_1 ;
                    else 
                        state_next <= state_reg ;
                end
        READ :
                begin 
                    if (counter) 
                        state_next <= write_ack ;
                    else 
                        state_next <= state_reg;
                end
        read_ack_1 : 
                begin 
                    if (sda_in)
                         state_next <= START ;
                    else 
                        state_next <= WRITE ;
                end
        write_ack :
                begin 
                    if (sda_in)
                            state_next <= START ;
                    else 
                        state_next <= READ ;
                end
        STOP : 
                begin 
                    state_next <= IDOL ;
                end
    endcase 
end
assign W_ena = (state_reg == IDOL || state_reg == START || state_reg == ADDRESS || state_reg == READ_ACK || state_reg == WRITE) ? 1 : 0;
assign R_ena = ( state_reg == IDOL || state_reg == START || state_reg == ADDRESS || state_reg == READ_ACK || state_reg == READ ) ? 1 : 0;
endmodule 

    
                    

                    


            


                


