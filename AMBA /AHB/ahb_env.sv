class ahb_env extends uvm_env ;
  
  ahb_agent agent;
  ahb_scoreboard scoreboard ;
  
   virtual ahb_if dut_vif;
  
   function new(string name , uvm_component parent);
    super.new(name,parent);
  endfunction
  
  `uvm_component_utils(ahb_env)
  
    function void build_phase (uvm_phase phase);
    super.build_phase(phase);
      agent= ahb_agent::type_id::create("agent",this);
      scoreboard= ahb_scoreboard::type_id::create("scoreboard",this);
      if(!uvm_config_db#(virtual ahb_if)::get(this,"","dut_vif", dut_vif)) `uvm_fatal("Scoreboard","interface is not set properly");
      `uvm_info("ENV","Build PHASE STARTED",UVM_LOW);
    endfunction
  
  
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    agent.monitor.trans_recv.connect(scoreboard.trans_received);
    `uvm_info("ENV","Connect PHASE STARTED",UVM_LOW);
  endfunction
  
  
endclass
