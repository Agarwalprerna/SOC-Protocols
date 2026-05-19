class ahb_monitor extends uvm_monitor ;
  `uvm_component_utils(ahb_monitor)
  
  uvm_analysis_port #(ahb_transaction) trans_recv ;
 virtual ahb_if dut_vif;
   function new(string name , uvm_component parent);
    super.new(name,parent);
     trans_recv = new("trans_recv",this);  
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_if)::get(this, "", "dut_vif", dut_vif)) `uvm_fatal("Driver","interface is not set properly");
    `uvm_info("MONITOR","Build PHASE STARTED",UVM_LOW);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
    ahb_transaction trans;
    trans=new();
    @(posedge this.dut_vif.clk) begin
      
  //    `uvm_info("MONITOR","Inside Loop",UVM_LOW);
      if( this.dut_vif.HTRANS != 0) begin
        
       // `uvm_info("MONITOR","Inside if loop",UVM_LOW);
      trans.HWRITE = this.dut_vif.HWRITE ;
      trans.HSIZE = this.dut_vif.HSIZE ;
      trans.HADDR = this.dut_vif.HADDR ;
      trans.HBURST = this.dut_vif.HBURST ;
      trans.HTRANS = this.dut_vif.HTRANS ;
      
        @(posedge this.dut_vif.clk);
      if(this.dut_vif.HWRITE == 1)
        trans.HDATA[0]=this.dut_vif.HWDATA;
        if(this.dut_vif.HWRITE == 0)
          trans.HDATA[0]=this.dut_vif.HRDATA;
      
      trans_recv.write(trans);
    end
    end
    end
    
  endtask
  
  
endclass
