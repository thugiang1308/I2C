module I2C_data_path (
    input  clk , rst_n , 
    input rw,
    input sda_in,
    input [7:0] data_in ,
    input [6:0] address , 
    input  [3:0] state , 
    input scl_n ,

    output reg [7:0] data_out ,
    output valid , 
    output reg sda_out, 
    output  counter ,
  //  output reg count_o,
    output reg st_ena 
);
localparam  [3:0] IDOL     = 4'd0,
                  START     = 4'd1,
                  ADDRESS   = 4'd2,
                  READ_ACK  = 4'd3, 
                  WRITE     = 4'd4,
                  READ      = 4'd5,
                  READ_ACK_1  = 4'd6,
                  WRITE_ACK   = 4'd7,
                  STOP        = 4'd8;

reg [7:0] addr ;
reg [7:0] data ;
reg [7:0] count = 0 ;

always @(posedge clk or negedge rst_n)
if (~rst_n ) 
begin 
            addr<= 8'd0 ;
            data <=8'd0 ;
            st_ena <= 0 ;
            
end 
else if (scl_n)
begin 
    case (state)
    IDOL : 
     begin 
            addr<= 8'd0 ;
            data <=8'd0 ;
            st_ena <= 0 ;
     end 
     START : 
        begin 
            addr <= {address,rw};
            count <= 7;
            data <= data_in ;
            st_ena <=  1; 
         end
     ADDRESS : 
        begin 
            count <= count - 1'b1 ;
        end
                                 
    WRITE : 
        begin  
            count <= count - 1'b1 ;
        end 
    
    READ : 
        begin 
            data_out[count] <= sda_in ; 
            count <= count - 1'b1 ;
        end
    READ_ACK , READ_ACK_1 , WRITE_ACK : 
    begin 
        count <= 7;
    end
    endcase
end
// always @(posedge clk or negedge rst_n) begin
//     if(~rst_n) begin
//         count_o <= 0;
//     end else begin
//         count_o <= counter;
//     end
// end
assign counter = (((state == WRITE) ||(state == READ)) & (count == 0)) ? 1 : ((state == ADDRESS & count == 0 ) ? 1 : 0  );
//assign scl_en_tmp = ((state == IDOL) || (state == START) || (state == STOP)) ?1:0;
always @* begin
    sda_out = 1'd1;
case (state)
    START: begin
        sda_out = 1'b0;
    end // START
   ADDRESS :
   begin 
        sda_out = addr[count] ;
   end 
   WRITE : 
   begin 
        sda_out = data_in[count] ; 
   end 
   WRITE_ACK : 
   begin 
       sda_out = 1'b1 ;
   end 

   STOP : 
   begin 
       sda_out = 1'b1 ; 
   end
   endcase 
end
    
endmodule 