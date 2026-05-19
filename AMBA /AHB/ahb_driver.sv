class ahb_driver extends uvm_driver #(ahb_transaction);

 virtual ahb_if dut_vif;
  ahb_transaction req ;
  
  `uvm_component_utils(ahb_driver)
  function new(string name , uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_if)::get(this, "", "dut_vif", dut_vif))
	    `uvm_fatal("Driver","interface is not set properly");
    `uvm_info("DRIVER","Build PHASE STARTED",UVM_LOW);
    endfunction
    
  virtual task run_phase (uvm_phase phase);
    super.run_phase(phase);
  //  phase.raise_objection(this,"Objection Raised from driver");
    `uvm_info("DRIVER","Run PHASE STARTED",UVM_LOW);
    forever begin
      
   //   `uvm_info("DRIVER","Inside forver block",UVM_LOW);
      
      	if(!dut_vif.HRESETn)begin
    //    $display($time,"ENTER_IN_RST_PHASE");
                dut_vif.HREADY <= 'h0;
	 	dut_vif.HWRITE <= 'h0;
 	 	dut_vif.HSIZE  <= 'h0;
	 	dut_vif.HBURST <= 'h0;
         	dut_vif.HWDATA <= 'habcd;
        	dut_vif.HRDATA <= 'h0;
     	       //dut_vif.HADDR  <= 'h0;
                dut_vif.HTRANS <= 'h0;
        wait (dut_vif.HRESETn);
    end
      
 
      @(this.dut_vif.master_cb) 
      seq_item_port.get_next_item(req);
      drive();
      req.print();
      seq_item_port.item_done();
    end 
  //  phase.drop_objection(this,"Objection Droped from driver");
    endtask
  
  task drive();
 
    @(negedge this.dut_vif.clk) begin
    fork
     
      drive_address();
      drive_data();
    join
    end
    
  endtask
  
    task drive_address() ;
  
         this.dut_vif.HADDR  <= req.HADDR;
         this.dut_vif.HBURST <= req.HBURST;
         this.dut_vif.HSIZE  <= req.HSIZE ;
       	 this.dut_vif.HTRANS <= req.HTRANS ;
         this.dut_vif.HWRITE <= req.HWRITE;

      if(req.HTRANS==2 & req.HBURST != 0 ) begin
   //     `uvm_info("DRIVER","Inside HTRANS if loop  ",UVM_LOW);
        calc_next_addr();   
      end
    endtask
  
    task calc_next_addr();
      
      bit [31:0] temp_addr = req.HADDR;
      bit [7:0] temp_wrap = 0 ;
      bit [15:0] temp_sizexwrap = 0 ;
   //   `uvm_info("DRIVER","Inside calc_next_addr task",UVM_LOW);
    
      for (int i=0; i<req.addr_length ; i++) begin
          if(req.HBURST==3'b001 | req.HBURST==3'b011 | req.HBURST==3'b111)        
        temp_addr =  temp_addr + addr_num();
        if(req.HBURST==3'b010 | req.HBURST==3'b100 | req.HBURST==3'b110 ) begin
          case (req.HBURST)
              3'b010: temp_wrap = 4 ;
              3'b100: temp_wrap = 8 ;
              3'b110: temp_wrap = 16 ;
            default :  temp_wrap = 0;
          endcase
            
            temp_sizexwrap = temp_wrap*addr_num();
    //      `uvm_info("Driver",$psprintf("Value of temp_wrap  is  %0h for temp_sizexwrap is %0h ", temp_wrap, temp_sizexwrap),UVM_LOW) ; 
   // end
          if(temp_addr%temp_sizexwrap == temp_sizexwrap-addr_num())
              temp_addr = temp_addr - temp_sizexwrap + addr_num();
            else 
              temp_addr = temp_addr + addr_num() ;
          
        end
            
        @(negedge this.dut_vif.clk)begin
        this.dut_vif.HTRANS <= 2'b11;
        this.dut_vif.HADDR <= temp_addr ;
        end
      end  
  //    end
      this.dut_vif.HTRANS <= 0;
    endtask
    
    function int addr_num();
      
       if(req.HSIZE== 3'b001) return(2);
       if(req.HSIZE== 3'b010) return(4);
       if(req.HSIZE== 3'b011) return(8);
       if(req.HSIZE== 3'b100) return(16);
       if(req.HSIZE== 3'b101) return(32);
       if(req.HSIZE== 3'b110) return(64);
       if(req.HSIZE== 3'b111) return(128);
       endfunction
    
  
    task  drive_data() ;
      if(req.HWRITE==1) begin
          @(negedge this.dut_vif.clk)
        this.dut_vif.HWDATA = req.HDATA[0];
        if(req.HTRANS==2 & req.HBURST==1 ) begin
          for(int i=1 ; i< req.addr_length ; i++) begin
           @(negedge this.dut_vif.clk)
            this.dut_vif.HWDATA = req.HDATA[i];
          
        end
      end
      end
      
    endtask
    
     
  
endclass



    
 
 
  
