class apb_test extends uvm_test;
	`uvm_component_utils(apb_test)
	`COMP_constructor(apb_test)

	apb_env env;

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = apb_env::type_id::create("env" , this);
	endfunction

	task run_phase (uvm_phase phase);
		apb_write_seq wr_seq;
		apb_read_seq rd_seq;
		phase.raise_objection(this);

		wr_seq = apb_write_seq::type_id::create("wr_seq");
		rd_seq = apb_read_seq::type_id::create("rd_seq");

		wr_seq.start(env.agt.sqr);
		rd_seq.start(env.agt.sqr);
		phase.drop_objection(this);
	endtask
endclass

