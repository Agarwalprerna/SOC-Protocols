package ahb_state_pkg;
typedef enum{IDLE,ACTIVE,WRITE_BURST,READ_BURST,AGAIN,LITTLE,OPERATION} state_e;

//endpackage
parameter NON_SEQ =4'b0000;
parameter SEQ     =4'b0001;
parameter BUSY    =4'b0010;
parameter IDLE_TRANS =4'b0011;
parameter OKAY    =4'b0100;
parameter ERROR   =4'b0101;
//parameter RETRY   =4'b0110;
//parameter SPLIT   =4'b0111;
//`include "uvm_macros.svh"
//`include "my_env.svh"
//`include "my_test.svh"
endpackage
`include "uvm_macros.svh"
//interface ahb_if_inst;
interface ahb_if  ;
  logic [1:0] HSELx;
  logic HWRITE;
  logic HCLK; 
  logic HRESETn;
  logic clk,reset;
  logic [31:0] HADDR,HWDATA,HRDATA;
  logic [1:0] HSIZE;
  logic [2:0] HBURST;
 // logic [3:0] HMASTER;
  logic [1:0] HTRANS;
  //logic  [2:0]READ_BURST;
  //logic  [2:0]WRITE_BURST;
  logic HMASTLOCK;
  logic HREADY;
  logic state;
  logic [1:0] HRESP;
 // logic [15:0]HSPLITx;
  logic [4:0]local_addr;
 // logic [3:0] SPLIT_RESP;
  //logic [31:0] memory_slave[31:0];
  //logic [1:0]ps_slave1,ns_slave1;
  logic count;
  
 /* modport DUT(input HSELx,HWRITE,HCLK,HRESETn,clk,reset, HWDATA,
               HSIZE,HBURST,HMASTER,HMASTLOCK,
             output  HREADY,HTRANS,HRESP,HRDATA,HSPLITx,state,HADDR,local_addr,SPLIT_RESP,count); */

  clocking master_cb @(posedge clk);
    input HRDATA , HMASTLOCK, HREADY, HRESP ;
    output HWRITE , HRESETn, HSELx , HCLK , HADDR , HWDATA , HSIZE , HBURST, HTRANS ;
  endclocking: master_cb
  
  modport master(clocking master_cb);
  

endinterface




import ahb_state_pkg::*;
module ahb_rtl_slave_2(ahb_if sintf);
//import ahb_state_pkg::*;
//slave_intf sintf(); 
logic [31:0] memory_slave[0:100];
state_e ps_slave1;
state_e ns_slave1;
reg [31:0] addr_buff;
bit opcode;
 
 always_ff @(posedge sintf.clk or negedge sintf.HRESETn)
 begin
   if(!sintf.HRESETn) 
     ps_slave1 <= IDLE;
   else       
     ps_slave1 <= ns_slave1;
 end
  
  //initial begin
    //memory_slave = new[100];
  //end
 
  always_ff @(posedge sintf.clk or negedge sintf.HRESETn) begin
//  always @(ps_slave1 or ns_slave1 or sintf.HRESETn or sintf.HSELx or sintf.HWDATA or sintf.HWRITE)
  if(!sintf.HRESETn) begin
    ns_slave1 <= OPERATION ;
    foreach (memory_slave[i])
      memory_slave[i] <= i;
  end
  else begin
  
  //first
  //foreach(memory_slave[i]) 
  //  begin
  //    memory_slave[sintf.HADDR]=32'b0;
  //  end
    case (ps_slave1)
    IDLE:begin   
          if(!sintf.HRESETn && sintf.HSELx==0)
           begin
             ns_slave1<=IDLE;
           end
          else 
           begin
             sintf.HREADY<=1'b1;
             sintf.local_addr<=5'b0;
             ns_slave1 <= OPERATION ;
             //ns_slave1=ACTIVE;
           end
         end
    OPERATION: begin
      if(sintf.HTRANS == 2'b10 || sintf.HTRANS == 2'b11) begin
               if(opcode ==1'b1 && sintf.HWRITE == 2'b0 && addr_buff == sintf.HADDR) begin
                  sintf.HRDATA = sintf.HWDATA; 
               end
               else if(sintf.HWRITE == 2'b0) begin
                 sintf.HRDATA = memory_slave[sintf.HADDR];
               end
               else begin
                   sintf.HRDATA = 32'b0;
               end
               addr_buff <= sintf.HADDR;
               opcode    <= sintf.HWRITE ; 
               ns_slave1 <= OPERATION ;
               if(opcode == 1'b1) begin
                   memory_slave[addr_buff] <= sintf.HWDATA;
               end
               //else begin
               //   sintf.HRDATA = memory_slave[addr_buff];
               //end
            end
            else begin
                sintf.HRESP <= OKAY;
            end             
    end
    ACTIVE: begin
            if(sintf.HRESETn && sintf.HSELx && sintf.HWRITE && sintf.HREADY)
             begin
             //sintf.HREADY=1'b0;
             addr_buff=sintf.HADDR;
             //  memory_slave[sintf.HADDR] = new[1];
             ns_slave1=WRITE_BURST;  
             end 
            else if(sintf.HRESETn && sintf.HSELx && !sintf.HWRITE && sintf.HREADY)
             begin
               //sintf.HREADY=1'b0;
               addr_buff=sintf.HADDR;
               //memory_slave[sintf.HADDR] = new[1];
               ns_slave1=READ_BURST;  
             end
             //else if(!sintf.HREADY)
             //begin
             //ns_slave1=AGAIN;
             // sintf.HRESP=RETRY;
             //end   
             else 
             begin
             ns_slave1=IDLE;
             end
            end // Active
  AGAIN: begin
              if(sintf.HREADY)
              begin
              ns_slave1=ACTIVE;
              end
              else
              ns_slave1= LITTLE; 
          end // AGAIN
 WRITE_BURST:begin
      //if(sintf.HRESETn && sintf.HSELx && sintf.HWRITE && sintf.HREADY)
      if(sintf.HRESETn && sintf.HSELx && sintf.HWRITE ) begin
      
      case(sintf.HBURST)     
      3'b000: begin
              memory_slave[addr_buff]<=sintf.HWDATA;
              addr_buff<=sintf.HADDR;
              //sintf.HREADY=1'b1;
              sintf.HRESP <=OKAY;
              //sintf.HTRANS=NON_SEQ;
              if(sintf.HWRITE ==2'b01)
                 ns_slave1<=WRITE_BURST;
              else
                 ns_slave1<=READ_BURST;
              end //000 single transfer
        
      3'b001: begin//incrementing Burst unspecified length
              memory_slave[sintf.HADDR]=sintf.HWDATA;
              sintf.HADDR=sintf.HADDR+1;
              sintf.count=sintf.count+1;
              if(sintf.count<32)
                ns_slave1= WRITE_BURST;
	      else begin
                sintf.HREADY=1'b1;
              sintf.HRESP=OKAY;
              ns_slave1=IDLE;
              $display("IDLE=%d",IDLE);
              end
          end//001
         3'b010: begin //4beat wrapping burst
                  memory_slave[sintf.HADDR]=sintf.HWDATA;
                  sintf.HADDR=sintf.HADDR+4;
                  sintf.count=sintf.count+1;
		  if(sintf.count==4) begin
                    
                     sintf.HREADY=1'b1;
                     sintf.HRESP=OKAY;
                     sintf.HADDR=sintf.local_addr;
                     sintf.count=0;
                     ns_slave1=IDLE;   
                  end //count<4
                  else
                    ns_slave1=WRITE_BURST;
                 end //010       
         3'b011: begin  //4beat incrementing burst
                    memory_slave[sintf.HADDR]=sintf.HWDATA;
                    sintf.HADDR=sintf.HADDR+4;
                    sintf.count=sintf.count+1;
                  if(sintf.count<4)
                      ns_slave1=WRITE_BURST;
	      else begin
                      sintf.HREADY=1'b1;
                      sintf.HRESP=OKAY;
                      ns_slave1=IDLE;
	      end
          end  //011
                  
          3'b100: begin  //8beat wrapping burst
                    memory_slave[sintf.HADDR]=sintf.HWDATA;
                    sintf.HADDR=sintf.HADDR+4;
                    sintf.count=sintf.count+1;
		    if(sintf.count==8) begin
                  
                      sintf.HREADY=1'b1;
                      sintf.HRESP=OKAY;
                      sintf.HADDR=sintf.local_addr;
                      sintf.count=0;
                      ns_slave1=IDLE;
                  end
                  else
                    ns_slave1=WRITE_BURST;
                  end  //100
          3'b101: begin //8beat incrementing burst
                   memory_slave[sintf.HADDR]=sintf.HWDATA;
                    sintf.HADDR=sintf.HADDR+4;
                    sintf.count=sintf.count+1;
                  if(sintf.count<8)
                      ns_slave1=WRITE_BURST;
	          else begin
                      sintf.HREADY=1'b1;
                      sintf.HRESP=OKAY;
                      ns_slave1=IDLE;
                  end //101
	  end
                  
           3'b110: begin//16beat wrapping burst
                     memory_slave[sintf.HADDR]=sintf.HWDATA;
                    sintf.HADDR=sintf.HADDR+4;
                    sintf.count=sintf.count+1;
		    if(sintf.count==16) begin
                
                      sintf.HREADY=1'b1;
                      sintf.HRESP=OKAY;
                      sintf.HADDR=sintf.local_addr;
                      sintf.count=0;
                      ns_slave1=IDLE;
                  end
                  else
                    ns_slave1=WRITE_BURST;
           end//110
                  
            3'b111: begin //16beat incrementing burst
                      memory_slave[sintf.HADDR]=sintf.HWDATA;
                      sintf.HADDR=sintf.HADDR+4;
                      sintf.count=sintf.count+1;
                  if(sintf.count<16)
                      ns_slave1=WRITE_BURST;
	          else begin
                      sintf.HREADY=1'b1;
                      sintf.HRESP=OKAY;
                      ns_slave1=IDLE;
	          end
                  end //111
          default:  begin
                      sintf.HREADY=1'b1;
                      sintf.HRESP=OKAY;
                      ns_slave1=IDLE;
                    end
      endcase//for write operation
      end
      else 
         sintf.HRESP=ERROR;
   end //if(write operation)   
      
  READ_BURST: begin
	  if(sintf.HRESETn && sintf.HSELx &&!sintf.HWRITE)begin
                    case(sintf.HBURST)
                    3'b000:begin 
              //sintf.HRDATA<=memory_slave[addr_buff];
                       sintf.HRDATA<= 32'h0878754;
                      addr_buff<=sintf.HADDR;
              //sintf.HREADY=1'b1;
                       $display($time,"the value of hwrite -%h", sintf.HWRITE);
                       $display($time,"the value of haddr -%h", sintf.HADDR);
                       if(sintf.HWRITE ==2'b01)
                             ns_slave1<=WRITE_BURST;
                       else
                             ns_slave1<=READ_BURST;
                             sintf.HRESP<=OKAY;
                   end  //single transfer
                  3'b001: begin //increment burst unspecified length
                        sintf.HRDATA=memory_slave[sintf.HADDR];
                        sintf.HADDR=sintf.HADDR+1;
                        sintf.count=sintf.count+1;
                       if(sintf.count<32)
                            ns_slave1=READ_BURST;
                       else
                           sintf.HREADY=1'b1;
                           sintf.HRESP=OKAY;    
                           ns_slave1=IDLE;
                   end//001
      
                 3'b010: begin  //4beat wrapping burst
                           sintf.HRDATA=memory_slave[sintf.HADDR];
                           sintf.HADDR=sintf.HADDR+4;
                           sintf.count=sintf.count+1;
			   if(sintf.count==4) begin
                             
                             sintf.HREADY=1'b1;
                             sintf.HADDR=sintf.local_addr;
                             sintf.count=0;
                             ns_slave1=IDLE;
                          end             
                          else
                             ns_slave1=READ_BURST;
                end//010;
                3'b011:  begin  //4beat incrementing
                           sintf.HRDATA=memory_slave[sintf.HADDR];
                            sintf.HADDR=sintf.HADDR+4;
                            sintf.count=sintf.count+1;
                      if(sintf.count<4)
                             ns_slave1=READ_BURST;
                      else
                              sintf.HREADY=1'b1;
                              sintf.HRESP=OKAY;    
                             ns_slave1=IDLE;
                end//011
               3'b100:  begin  //8beat wrapping burst
                          sintf.HRDATA=memory_slave[sintf.HADDR];
                           sintf.HADDR=sintf.HADDR+4;
                          sintf.count=sintf.count+1;
			  if(sintf.count==8) begin
               
                               sintf.HREADY=1'b1;
                               sintf.HADDR=sintf.local_addr;
                               sintf.count=0;
                               ns_slave1=IDLE;
                          end             
                         else
                              ns_slave1=READ_BURST;
            end //100
             3'b101:  begin  //8beat incrementing
                sintf.HRDATA=memory_slave[sintf.HADDR];
                sintf.HADDR=sintf.HADDR+4;
                sintf.count=sintf.count+1;
                if  (sintf.count<8)
                ns_slave1=READ_BURST;
	       else begin    
                sintf.HREADY=1'b1;
                sintf.HRESP=OKAY;    
                ns_slave1=IDLE;
        	end
            end                
              3'b110:  begin  //16beat wrapping burst
               sintf.HRDATA=memory_slave[sintf.HADDR];
               sintf.HADDR=sintf.HADDR+4;
               sintf.count=sintf.count+1;
	       if(sintf.count==16) begin
               
                 sintf.HREADY=1'b1;
                 sintf.HADDR=sintf.local_addr;
                 sintf.count=0;
                 ns_slave1=IDLE;
               end //110            
              else
                 ns_slave1=READ_BURST;
              end             
            3'b111:   begin  //16beat incrementing
                sintf.HRDATA=memory_slave[sintf.HADDR];
                sintf.HADDR=sintf.HADDR+4;
                sintf.count=sintf.count+1;
              if(sintf.count<16)
                ns_slave1=READ_BURST;
	      else begin
                sintf.HREADY=1'b1;
                sintf.HRESP=OKAY;    
                ns_slave1=IDLE;
             end //111  
           end     
           default:    begin
                sintf.HREADY=1'b1;
                sintf.HRESP=OKAY;
                ns_slave1=IDLE;
              end          
        endcase  //for read operation
        end  else
          sintf.HRESP=ERROR;    
    end 
    LITTLE:  begin
              //  sintf.SPLIT_RESP=sintf.HMASTER;
                if(sintf.HMASTLOCK)
                  ns_slave1=ACTIVE;
              else
                   // sintf.HSPLITx=sintf.SPLIT_RESP;
                    ns_slave1=IDLE;
              end 
      endcase
    
    end
    end
    

    endmodule

