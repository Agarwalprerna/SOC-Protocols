class ahb_test extends uvm_test;
        `uvm_component_utils(ahb_test)

  ahb_env env ;
  virtual ahb_if dut_vif;
  ahb_write_seq wr_seq;
 
  function new(string name="ahb_test", uvm_component parent );
    super.new(name, parent);
  endfunction
  
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
  
    if(!uvm_config_db#(virtual ahb_if)::get(this,"","dut_vif",dut_vif))
	    `uvm_error("TEST","interface is not set properly");
    env=ahb_env::type_id::create("env",this);
  //  wr_seq = ahb_write_seq::type_id::create("wr_seq",this);
  
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    `uvm_info("TEST","RUN PHASE STARTED",UVM_LOW);
    wr_seq = ahb_write_seq::type_id::create("wr_seq",this);
  //  `uvm_info("TEST",$psprintf("TEST STARTED"),UVM_LOW);
     phase.raise_objection(this,"seq started");
   
     @(posedge this.dut_vif.clk)
     wr_seq.start(env.agent.seqr);
  //  #100 ;
    `uvm_info("TEST","TEST ENDED",UVM_LOW);
    phase.drop_objection(this,"seq ended");
  endtask
  
  
  
   virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction
  
  
  
endclass
