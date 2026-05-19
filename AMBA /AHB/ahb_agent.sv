class ahb_agent extends uvm_agent;
  ahb_sequencer seqr;
  ahb_driver drvr ;
  ahb_monitor monitor ;
// virtual ahb_if dut_vif ;
    function new(string name , uvm_component parent);
    super.new(name,parent);
  endfunction
  
  `uvm_component_utils_begin(ahb_agent)
  `uvm_field_object(seqr, UVM_ALL_ON)
  `uvm_field_object(drvr, UVM_ALL_ON)
  `uvm_field_object(monitor, UVM_ALL_ON)
  `uvm_component_utils_end
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("AGENT","Build PHASE STARTED",UVM_LOW);
    seqr= ahb_sequencer::type_id::create("seqr",this);
    drvr= ahb_driver::type_id::create("drvr",this);
    monitor= ahb_monitor::type_id::create("monitor",this);
 
    
  endfunction
  
   function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
     if(get_is_active()==UVM_ACTIVE)
       drvr.seq_item_port.connect(seqr.seq_item_export) ;
     `uvm_info("AGENT","Connect PHASE STARTED",UVM_LOW);
   endfunction
endclass
