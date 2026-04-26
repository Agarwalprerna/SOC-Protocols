
class apb_b2b_seq extends uvm_sequence #(apb_trans);
	`uvm_object_utils(apb_b2b_seq)

	`OBJ_constructor(apb_b2b_seq)

	apb_trans tr;

	task body();
		repeat(5)begin
			tr= apb_trans::type_id::create("tr");
			start_item(tr);
			tr.invalid_addr_range.constraint_mode(0);
			if(! tr.randomize() with { tr.reset==1;})begin
				`uvm_error(get_type_name() , "failed randomization")
			end
			finish_item(tr);
			tr.print();
		end
	endtask
endclass
