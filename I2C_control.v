module I2C_control (
    input clk , rst_n ,
    input rw ,
    input ena,
    input sda_in,
    input scl_n ,
    input counter ,
    input scl_p,
    input st_ena,
    input [4:0] n_byte,
    input stop_done , 
    input [4:0] count_o , 

    output [3:0] state , 
    output reg  req_w , 
    output  valid , 
    output reg count_o_stop  , 
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
// reg [4:0] count_o = 0  ; 
reg  stop_read = 0  ; 
reg   stop_write = 0 ; 
// reg req = 0 ; 

always @*
begin 
 if ((state_reg == IDOL) || (state_reg == START) || (state_reg == STOP ) ) 
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
        count_o_stop <= 0 ;  
    end

    else begin
        
            if (scl_n)  state_reg <= state_next ;
    end 
end

always @(posedge clk or negedge rst_n) 
begin 
    if (~rst_n) 
        begin 
             req_w <= 0 ; 
        end
        else if (scl_n) 
        begin 
            if (state_reg == WRITE && counter) 
                    req_w <= 1 ; 
                 else 
                    req_w <= 0 ; 
        end
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
              //  count_o = 0 ; 
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
                    begin 
                        state_next = READ_ACK_1 ;
                    end 
                end
        READ :  //5 
                begin 
                    
                    if (counter) 
                    begin 
                        state_next = WRITE_ACK ; 
                    end 
                end
        READ_ACK_1 : //6 
                begin 
                    if (!sda_in)
                    begin 
                        if (count_o == n_byte )
                        begin  
                            count_o_stop = 1 ; 
                            state_next = STOP ;
                            if (scl_n) stop_write = 1 ; 
                        end 
                        else 
                        begin   
                            state_next = WRITE ;  
                        end
                    end 
                    else 
                        state_next = STOP ;
                end
        WRITE_ACK : //7 
                begin 
                    if (count_o == n_byte)
                    begin  
                        if (scl_n) stop_read = 1 ; 
                        count_o_stop = 1 ; 
                        state_next = STOP ; 
                        
                    end 
                    else 
                        state_next = READ ; 
                end 
        STOP : // 8 
                begin 
                     stop_read = 0 ; 
                     stop_write = 0 ; 
                     count_o_stop = 0 ;  
                    if (stop_done)
                    state_next = IDOL ;
                end
    endcase 
end
assign valid = (((stop_read) || (stop_write)) & scl_n ) ? 1 : 0 ; 

// assign req_w = ((state_reg == WRITE) && (scl_n) && (counter)  ) ? 1 : 0 ; 

assign state = state_reg ; 
assign W_ena = ( (state_reg == IDOL) || (state_reg == START )|| (state_reg == ADDRESS) || (state_reg == WRITE) || (state_reg == WRITE_ACK) || (state_reg == STOP)) ? 1 : 0;

endmodule 

    
                    

                    


            


                


