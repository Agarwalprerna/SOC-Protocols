class ahb_scoreboard extends uvm_scoreboard ;
  `uvm_component_utils(ahb_scoreboard)
  
  uvm_analysis_imp#(ahb_transaction,ahb_scoreboard) trans_received ;
  ahb_transaction expt_que[$];
  bit [31:0] mem [255:0];
  ahb_transaction recv_data ;
  

  
function new(string name , uvm_component parent);
    super.new(name,parent);
  trans_received = new("trans_received",this);  
  endfunction
  
  
  virtual task run_phase(uvm_phase phase) ;
    super.run_phase(phase);
   
    forever begin
   // always @(expt_que.size()) begin
   // forever begin
    
      wait(expt_que.size() > 0)  //begin
   //   `uvm_info("Scoreboard",$psprintf("Size is  %0h", expt_que.size() ),UVM_LOW) ; 
  //  `uvm_info("Scoreboard","Main Operation Started",UVM_LOW);
    recv_data = expt_que.pop_front();
    
    if(recv_data.HWRITE == 0) begin
      if (mem[recv_data.HADDR] == recv_data.HDATA[0]) 
     //   `uvm_info("Scoreboard","Read Operation : Matching",UVM_LOW);
       `uvm_info("Scoreboard",$psprintf("Read Operation : DATA is matching recv_data is %0h and expected data is %0h for addr %0h", recv_data.HDATA[0], mem[recv_data.HADDR], recv_data.HADDR),UVM_LOW) ; 
      if (mem[recv_data.HADDR] != recv_data.HDATA[0])    begin
                 `uvm_error("Scoreboard",$psprintf("Read Operation : DATA is not matching recv_data is %0h and expected data is %0h for addr %0h", recv_data.HDATA[0], mem[recv_data.HADDR] , recv_data.HADDR)) ;  
      end       
    end       
    if(recv_data.HWRITE == 1) begin  
      mem[recv_data.HADDR] = recv_data.HDATA[0] ;
 //     `uvm_info("Scoreboard",$psprintf("Write Operation : Adding to expected queue"),UVM_LOW);  
      `uvm_info("Scoreboard",$psprintf("Write Operation : DATA is  %0h for addr %0h ", recv_data.HDATA[0], recv_data.HADDR),UVM_LOW) ; 
    end
      end
  //  end
   
  endtask 
  
  function  write(ahb_transaction recv);
    expt_que.push_back(recv);
 //   recv.print();
  //  `uvm_info("Scoreboard","Inside write function",UVM_LOW);
  endfunction
    
endclass
  
  
  
  
  
  
