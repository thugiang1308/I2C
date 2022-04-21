module I2C_control (
    input clk , rst_n ,
    input rw ,
    input ena,
    input sda_in,
    input scl_n ,
    input counter ,
    input st_ena,

    output  [3:0] state , 
    output reg scl_ena,
    output W_ena 
) ;

localparam  [3:0] IDOL     = 4'b0000,
                  START     = 4'b0001,
                  ADDRESS   = 4'b0010,
                  READ_ACK  = 4'b0011, 
                  WRITE     = 4'b0100,
                  READ      = 4'b0101,
                  READ_ACK_1 = 4'b0110,
                  WRITE_ACK  = 4'b0111,
                  STOP        = 4'b1000;
                
reg [3:0] state_reg ,state_next ;


always @*
begin 
 if (state_reg == IDOL || state_reg == START || state_reg == STOP  ) 
    begin if (scl_n)
          scl_ena = 1 ;
    end 
else    
        scl_ena = 0 ;
end 

always @(posedge clk or negedge rst_n ) 
begin 
    if (!rst_n )
    begin 
        state_reg <= IDOL ;
    end
    else if (scl_n)  state_reg <= state_next ;
end
always @*
begin 
    state_next = state_reg ;
    case (state_reg) 
        IDOL : //0
            begin 
                if(ena)
                begin 
                    
                    state_next = START ;
                end
                    else 
                    state_next = IDOL ;
            end
         START : //1
            begin 
                
                if (st_ena) 
                begin 
                state_next = ADDRESS ;
                end 
                else 
                state_next = START ;
            end
        ADDRESS ://2
            begin 
               
                if (counter) state_next = READ_ACK ;
              
            end
        READ_ACK : //3
            begin 
               if ( !sda_in  )
               begin 
                   if (rw) 
                        state_next = READ ; 
                    else 
                        state_next = WRITE ;
               end
               else 
                        state_next = START ;
            end
        WRITE : //4
                begin 
                   
                    if (counter) 
                        state_next = READ_ACK_1 ;
                end
        READ :
                begin 
                    
                    if (counter) 
                        state_next = WRITE_ACK ;
                end
        READ_ACK_1 : 
                begin 
                    if (!sda_in)
                        state_next = START ;
                    else 
                        state_next = WRITE ;
                end
        WRITE_ACK :
                begin 
                    if (!sda_in)
                        state_next = START ;
                    else 
                        state_next = READ ;
                end
        STOP : 
                begin 
                    state_next = IDOL ;
                end
    endcase 
end
assign state = state_reg ; 
assign W_ena = (state_reg == IDOL || state_reg == START || state_reg == ADDRESS || state_reg == WRITE_ACK || state_reg == WRITE || state_reg == STOP) ? 1 : 0;
endmodule 

    
                    

                    


            


                


