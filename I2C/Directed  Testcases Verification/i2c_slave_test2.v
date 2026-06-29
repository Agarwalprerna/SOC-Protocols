`include "I2C_slave.v"
//`include "I2C_interface.sv"
//`include "test.sv"


  module i2c_top_tb;

      reg clk;
      reg RESETn;
      reg sda;  //as a input  for address , data
     //
     // reg SCL;
      wire [6:0] ADDRESS_OUT;
      wire [7:0] DATA_OUT;
      wire SDA;   //as a output in case of acknowledge signal 
     // wire SCL;

     
       I2C_slave DUT ( .SCL(clk) ,
		        .SDA(SDA) ,
			.RESET_IN(RESETn),
			.DATA_OUT(DATA_OUT),
			.ADDRESS_OUT(ADDRESS_OUT)
			);


      assign SCL = clk;
     
      assign SDA = DUT.dir_en? 1'bz:sda;


      //for initializing input values
         task initialization;
             begin
                  clk=0;
                  sda = 0;
                  RESETn= 0;
             end
         endtask

        //reset task
        task rst;
            begin
                RESETn= 1;
                repeat(2) @(negedge clk);
                #2;
                RESETn = 0;
            end
       endtask
            
          
          //clock generation
         always #10 clk=!clk;


         //task to generate start condition
          task start_gen;
             begin
                sda =1; 
                @(posedge clk);
                #2;
                sda =0;
                @(negedge clk);
             end
           endtask

          //task to generate stop condition
 
           task stop_gen;
              begin
                  @(negedge clk);
                  sda = 0;
                  @(posedge clk);
                  #2;
                  sda = 1;

               end
            endtask


           //task to generate address values
               task wr_address;
                    reg [7:0] temp;
                begin
                     temp = 8'b1100_1110;  //1100111 = 67 address  0:write
                     repeat(8)begin
                       @(negedge clk);
                       #2;
                       //sda = temp;
		       sda = temp[0];
                       temp = temp>>1;
                     end
                       @(negedge clk); //for ack signal
	       end
                endtask


            task rd_address;
                 reg [7:0] temp;
               begin
                   temp = 8'b1100_1111;
                   repeat(8)begin
                        @(negedge clk);
                        //sda = temp;
			sda = temp[0];
                        temp = temp >> 1;
                   end
                      @(negedge clk); //for ack signal
               end
           endtask

            //task to generate write data alues
           task write_data;
                reg [7:0] temp;
             begin
                temp = 8'b1101_1101;  //DD
                repeat(8)begin
                   @(negedge clk);
                   //sda = temp;
		   sda = temp[0];
                   temp = temp>>1;
                end
                @(negedge clk);
             end
            endtask


           //task to get read data alues
           task read_data;
             begin
                repeat(8)begin
                   @(negedge clk);
                end
                @(negedge clk);
                sda =0; //ack
             end
            endtask
  
            //calling all task

            initial begin
                  initialization;
                  rst;
                  start_gen();
                  wr_address();
                  write_data;
                  rd_address();
                  read_data;
                  #200;
                  $finish;
             end
endmodule

 
 
