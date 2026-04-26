class apb_env extends uvm_env;
	`uvm_component_utils(apb_env)
	`COMP_constructor(apb_env)

	apb_score sb;
	apb_agent agt;

	function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		sb = apb_score::type_id::create("sb" , this);
            	agt = apb_agent::type_id::create("agt" , this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		agt.mon.ap_mon.connect(sb.ap_sb);
	endfunction

endclass



