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
    input [1:0] count_tmp, 

    output  stop_write ,
    output  stop_read , 
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
reg  stop_read_  ; 
reg   stop_write_ ; 
// reg req = 0 ; 

//wire  ena_ ; 
//reg [2:0] count__ ; 
//always @(posedge clk or negedge rst_n ) 
//begin 
//    if (!rst_n )
//    begin 
//        count__ <= 0 ; 
//    end
//    else if (ena ) begin 
//       count__ <= count__ + 1'b1 ; 
//       if (count__ == 4 ) begin 
//       count__ <= 2 ; 
//       end
//       end 
       
// end 

//assign ena_ = (count__ == 1  ) ? 1 : 0 ; 
always @*
begin 
if(state_reg == STOP & (count_tmp > 0)) begin
    scl_ena = 1 ;
end 
else if ((state_reg == IDOL) || (state_reg == START) ) 
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
            if ((state_reg == WRITE) && counter) 
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
                 stop_read_ = 0 ; 
                 stop_write_ = 0 ; 
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
                          if (scl_n)  stop_write_ = 1 ; 
                            state_next = STOP ;
                           
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
                     if (scl_n)  stop_read_ = 1 ; 
                        count_o_stop = 1 ; 
                        state_next = STOP ; 
                        
                    end 
                    else 
                        state_next = READ ; 
                end 
        STOP : // 8 
                begin 
			        		
                    count_o_stop = 0 ;  
                    if (stop_done)
		begin 
                    state_next = IDOL; 

		end
                end
    endcase 
end
reg stop_write_one ; 
reg stop_read_one ; 
always @(posedge clk or negedge rst_n) 
begin 
    if (~rst_n) begin 
         stop_read_one <= 0 ; 
         stop_write_one <= 0 ; 
    end 
    else 
        begin 
            if (stop_write_)
            stop_write_one <= 1 ; 
            else  if (stop_read_) 
            stop_read_one <= 1 ; 
            else if (state == IDOL) begin 
            stop_read_one <= 0 ; 
            stop_write_one <= 0 ; 
            end 
        end 
end
assign stop_write = (stop_done && stop_write_one) ? 1 : 0 ; 
assign stop_read= (stop_done && stop_read_one) ? 1 : 0 ;
assign valid = (((stop_read) || (stop_write)) & scl_n ) ? 1 : 0 ;  
assign state = state_reg ; 
assign W_ena = ( (state_reg == IDOL) || (state_reg == START )|| (state_reg == ADDRESS) || (state_reg == WRITE) || (state_reg == WRITE_ACK) || (state_reg == STOP)) ? 1 : 0;

endmodule 