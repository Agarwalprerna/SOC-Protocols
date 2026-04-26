class apb_write_seq extends uvm_sequence #(apb_trans);
	`uvm_object_utils(apb_write_seq)

	`OBJ_constructor(apb_write_seq)

	apb_trans tr;

	task body();
		repeat(5)begin
			tr= apb_trans::type_id::create("tr");
			start_item(tr);
			tr.invalid_addr_range.constraint_mode(0);
			if(! tr.randomize() with {tr.PWRITE == 1 ; tr.reset==1;})begin
				`uvm_error(get_type_name() , "FAILED RANDOMIZATION")
			end
			finish_item(tr);
			tr.print();
		end
	endtask
endclass

