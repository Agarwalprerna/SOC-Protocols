class apb_error_seq extends uvm_sequence #(apb_trans);
	`uvm_object_utils(apb_error_seq)

	`OBJ_constructor(apb_error_seq)

	apb_trans tr;

	task body();
		repeat(5)begin
			tr= apb_trans::type_id::create("tr");
			start_item(tr);
			tr.invalid_addr_range.constraint_mode(1);
			if(! tr.randomize() with { tr.reset==1;})begin
				`uvm_error(get_type_name() , "failed randomization")
			end
			finish_item(tr);
			tr.print();
		end
	endtask
endclass
