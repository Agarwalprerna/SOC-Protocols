
  module I2C_slave( input wire RESET_IN ,
                     input SCL ,
                     inout SDA ,   // master can drive and slave can also drive
                       output reg [7:0] DATA_OUT ,    //received data from master
                      output  reg [6:0] ADDRESS_OUT); //address received on bus from MASTER  



  //signal 
      wire wr_rd;  //0 write  , read 1
  
      reg [7:0] address_in ;
      reg [7:0] wr_data , rd_data;
      reg [7:0] sipo_data;
      reg piso_data;
      reg [3:0] count ; //upto 8
     reg sda_out;  
       reg dir_en;
       reg [7:0] mem[255:0];
       reg wr_en;
       reg rd_en;
       reg start;
       reg stop;
        reg count_en;
       reg sipo_en;

        reg piso_en;
        reg sipo_valid;
        reg stop_en;
        reg piso_valid;
        reg start_en;



       reg [3:0] present_state , next_state;


     parameter  IDLE = 4'b0000,
                START = 4'b0001,
                reg_addr = 4'b0010,
                reg_addr_ack = 4'b0011,
               // WRITE_DATA = 4'b0100,
	       WRITE =4'b0100,
                //WRITE_DATA_ACK = 4'b0101,
		WRITE_ACK = 4'b0101,
                //READ_DATA = 4'b0110,
		READ = 4'b0110,
               // READ_DATA_ACK = 4'b0111,
	       READ_ACK = 4'b0111,
                STOP = 4'b1000,
                STOP_m = 4'b1001;

 
            assign SDA = dir_en? sda_out:1'bz;
	    assign DATA_OUT = rd_data;
	    assign {ADDRESS_OUT,wr_rd} = address_in;
               
            //logic to change state
          always @( negedge SCL or posedge RESET_IN) begin
               if(RESET_IN) present_state <= IDLE;
               else  
                        present_state <= next_state;
          end
                     
            
           //logic for slave
           always @( posedge SCL or posedge RESET_IN)begin
                  if(!RESET_IN)begin
                       if(wr_en) 
                             mem[ADDRESS_OUT] <= wr_data;
                       if(rd_en)
                             rd_data <= mem[ADDRESS_OUT];
                   end
            end

 
             //counter logic
            always @(negedge SCL or posedge RESET_IN)begin
                   if(RESET_IN) count <= 0;
                   else begin
                          if(count_en) count<= count+1;
                          else count <= 0;
                   end
             end






             //start condition
              always @(negedge SDA) begin
                          start <= 0;
                          if(SCL && start_en) 
                                       start <= 1;
             end

               //stop condition
               always @(posedge SDA)begin
                          stop <= 0;
                          if(SCL && stop_en)
                                      stop <= 1;
                end











            //next state logic
            always @(*)begin
                    case(present_state)
                            IDLE:begin
                                   if(start) next_state = START;
                                   else next_state = IDLE;
                            end
                          
                            START: begin
                                     next_state = reg_addr;
                            end
 
                            reg_addr: begin
                                     if(count >= 0 && count <7)begin //wait for 8 clock cycle
                                             next_state = reg_addr;
                                      end 
                                      else begin
                                             next_state = reg_addr_ack;
                                       end
                             end

                             reg_addr_ack:begin   //slave will generate ack
                                       if( sda_out == 0) begin  //ACK signal on SDA line
                                              if(wr_rd == 0) begin  //WRITE oprn
                                                    next_state = WRITE;
                                               end
                                              else begin //read
                                                    next_state = READ;
                                              end
                                         end
                                        else begin //NACK
                                              next_state = STOP_m;
                                        end
                              end

                               WRITE:begin
                                          //waiting for 8 clock period

                                         if( count >= 0 && count <7)begin
                                                 next_state = WRITE;
                                         end
                                         else begin
                                                 next_state = WRITE_ACK;
                                         end
                               end

                               WRITE_ACK:begin  //slave generate ack
                                      if(sda_out == 0)
                                                 next_state = reg_addr; //transfer completed , for more transfer go to address state
                                      else 
                                               next_state = STOP_m;
                               end
                             
                               READ:begin 
                                      if(count>=0 && count <7)begin
                                               next_state = READ;
                                      end
                                   else begin
                                             next_state = READ_ACK;
                                   end
                               end
                             
                               READ_ACK:begin  //master will generate ack
                                         if(SDA == 0) 
                                                   next_state = reg_addr;
                                          else 
                                                   next_state = STOP_m;
                               end
                            
                               STOP_m: begin
                                       if(stop) 
                                                 next_state = STOP;
                                        else if(start) 
                                                 next_state = START;
                               end
                            
                               STOP: begin
                                      if(start)
                                               next_state = START;
                                      else
                                               next_state = STOP;
                              end
                               default: next_state = IDLE;
                        
                                                 
                        endcase
                end





         //code for SIPO
         
             always @(posedge SCL) begin
                  if(RESET_IN) sipo_data <= 0;
                  else begin
                      if(sipo_en)
                             sipo_data <= {SDA , sipo_data[7:1]};
                  end
             end

            //code for PISO
              always @(negedge SCL)begin
                      if(RESET_IN)  piso_data <= 0;
                      else begin
                            if(piso_en)begin
                                 piso_data <= rd_data[count+1];
                            end
                       end
             end


	     //output logic

	     always @(*)begin
		     case(present_state)
			     IDLE: begin
				     dir_en = 0;
				     sda_out =0;
				     count_en = 0;
				     piso_en = 0;
				     sipo_en = 0;
				     wr_en = 0;
				     rd_en = 0;
				     stop_en = 0;
				     start_en = 1;
				     address_in = 0;
				     wr_data = 0;
			     end
			     START:begin
                                     dir_en = 0;
				     sda_out =0;
				     count_en = 0;
				     piso_en = 0;
				     sipo_en = 0;
				     wr_en = 0;
				     rd_en = 0;
				     stop_en = 0;
				     start_en = 0;
				     address_in = 0;
				     wr_data = 0;
			     end
			     reg_addr:begin
                                     dir_en = 0;
				     sda_out =0;
				     count_en = 1;
				     piso_en = 0;
				     sipo_en = 1;
				     wr_en = 0;
				     rd_en = 0;
				     //stop_en = 0;
				     start_en = 0;
				     address_in = 0;
				     wr_data = 0;
			     end
			     reg_addr_ack:begin  //slave will generate ack
                                     dir_en = 1;
				     sda_out =0;
				     count_en = 0;
				     piso_en = 0;
				     sipo_en = 0;
				     wr_en = 0;
				     rd_en = 0;
				     //stop_en = 0;
				     //start_en = 1;
				     address_in = sipo_data;
				     wr_data = 0;
			     end
			     WRITE:begin
                                     dir_en = 0;
				     sda_out =0;
				     count_en = 1;
				     piso_en = 0;
				     sipo_en = 1;
				     wr_en = 0;
				     rd_en = 0;
				     //stop_en = 0;
				     //start_en = 1;
				     address_in = 0;
				     wr_data = 0;
			     end

			     WRITE_ACK:begin
                                     dir_en = 1;
				     sda_out =0;
				     count_en = 0;
				     piso_en = 0;
				     sipo_en = 0;
				     wr_en = 1;
				     rd_en = 0;
				    // stop_en = 0;
				     //start_en = 1;
				     address_in = 0;
				     wr_data = sipo_data;
			     end

			     READ:begin
                                     dir_en = 1;//slave to Master
				     sda_out = piso_data;
				     count_en = 1;
				     piso_en = 1;
				     sipo_en = 0;
				     wr_en = 0;
				     rd_en = 1;
				     //stop_en = 0;
				     //start_en = 1;
				     address_in = 0;
				     wr_data = 0;
			     end

			     READ_ACK:begin
                                     dir_en = 0;
				     sda_out =0;
				     count_en = 0;
				     piso_en = 0;
				     sipo_en = 0;
				     wr_en = 0;
				     rd_en = 0;
				     //stop_en = 0;
				     //start_en = 1;
				     address_in = 0;
				     wr_data = 0;
			     end

			     STOP_m:begin
                                     dir_en = 0;
				     sda_out =0;
				     count_en = 0;
				     piso_en = 0;
				     sipo_en = 0;
				     wr_en = 0;
				     rd_en = 0;
				     stop_en = 1;
				    // start_en = 1;
				     address_in = 0;
				     wr_data = 0;
			     end
			     STOP:begin
                                     dir_en = 0;
				     sda_out =0;
				     count_en = 0;
				     piso_en = 0;
				     sipo_en = 0;
				     wr_en = 0;
				     rd_en = 0;
				     //stop_en = 0;
				     //start_en = 1;
				     address_in = 0;
				     wr_data = 0;
			     end
			     default:begin
                                     dir_en = 0;
				     sda_out =0;
				     count_en = 0;
				     piso_en = 0;
				     sipo_en = 0;
				     wr_en = 0;
				     rd_en = 0;
				     //stop_en = 0;
				     //start_en = 0;
				     address_in = 0;
				     wr_data = 0;
			     end
		     endcase
	     end











endmodule




                  
                                        

                                            
