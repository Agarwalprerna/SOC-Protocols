class ahb_write_seq extends uvm_sequence#(ahb_transaction);
  `uvm_object_utils(ahb_write_seq)
  ahb_transaction req;
  
 // rand bit [7:0] addr;
  bit [7:0] temp_addr ;
  
  function new(string name="");
    super.new(name);
  endfunction
  
  task body();
 
    repeat(2) begin
  
  //  req=new();
  //    req=ahb_transaction::type_id::create("ahb_transaction");
   // $display("inside body");
  //  start_item(req);
 //   $display("inside body: After start_item");
  //    req.randomize() with {req.HTRANS==2 & req.HBURST==1 & req.HADDR == 34 & req.HWRITE==0 & req.HSIZE==1;};
  //    req.randomize() with {req.HTRANS==2 & req.HBURST==1 & req.HADDR == 34 & req.HWRITE==1 & req.HSIZE==1;};
  //  req.print();
  //  finish_item(req);
   
   
  //    `uvm_rand_send_with(req,{req.HTRANS==2 & req.HBURST==1 & req.HADDR == 34 & req.HWRITE==1 & req.HSIZE==1;});
    //  `uvm_rand_send_with(req,{req.HTRANS==2 & req.HBURST==1 & req.HADDR == 34 & req.HWRITE==0 & req.HSIZE==1;});
      temp_addr = $urandom_range(0,90);
  //    `uvm_info("Scoreboard",$psprintf("temp_addr = %0h",temp_addr),UVM_LOW);
      `uvm_do_with(req,{req.HTRANS==2 &  req.HADDR == 40 & req.HWRITE==1 & req.HBURST==4  & req.HSIZE==3 ;});
    //  `uvm_do_with(req,{req.HTRANS==2 & req.HBURST==1 & req.HADDR == temp_addr & req.HWRITE==1 & req.HSIZE==1;});  
   //   #50 ;
      `uvm_do_with(req,{req.HTRANS==2  & req.HADDR == 40 & req.HWRITE==0 & req.HBURST==4 & req.HSIZE==3 ;});
    //  `uvm_do_with(req,{req.HTRANS==2 & req.HBURST==1 & req.HADDR == temp_addr & req.HWRITE==0 & req.HSIZE==1;});  
   //  $display("inside body: After rand");
      
 //   `uvm_do(req);
  //   req.print();
    end 
 //   end   //
  endtask
 
  
endclass
