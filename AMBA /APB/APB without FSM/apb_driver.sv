class apb_driver extends uvm_driver #(apb_trans);
	`uvm_component_utils(apb_driver)
	`COMP_constructor(apb_driver)

	apb_trans tr;
	virtual apb_inf inf;

	function void build_phase( uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db #(virtual apb_inf)::get(this , "" , "inf" , inf);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		forever begin
			tr= apb_trans::type_id::create("tr");
			seq_item_port.get_next_item(tr);
			send_to_dut(tr);
			seq_item_port.item_done();
		end
	endtask

	task send_to_dut(apb_trans tr);
		@(inf.dr_cb);
		if(!tr.reset)begin  //rst = 0
			inf.dr_cb.PADDR <= 0;
			inf.dr_cb.PWDATA <= 0;
		end
		else begin
			inf.dr_cb.PADDR <= tr.PADDR;
			inf.dr_cb.PWRITE <= tr.PWRITE;
			inf.dr_cb.reset <= tr.reset;
			inf.dr_cb.PSEL <= 1'b1;
			inf.dr_cb.PENABLE <= 1'b0;
			inf.dr_cb.PWDATA <= tr.PWDATA;
			@(inf.dr_cb);
			inf.dr_cb.PENABLE <= 1'b1;
			wait(inf.dr_cb.PREADY);

			if(!tr.PWRITE)
			       tr.PRDATA<= inf.dr_cb.PRDATA;
	       end
       endtask
endclass



