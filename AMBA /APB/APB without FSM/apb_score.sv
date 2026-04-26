class apb_score extends uvm_scoreboard;
	`uvm_component_utils(apb_score)
	`COMP_constructor(apb_score)

        apb_trans exp_tr;
	uvm_analysis_imp #(apb_trans , apb_score) ap_sb;

	bit [`DATA_WIDTH -1:0] mem[int];  //for storing PWDATA

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		ap_sb = new("ap_sb" , this);
	endfunction

       virtual 	function write(apb_trans actual_tr);
		exp_tr = apb_trans::type_id::create("exp_tr");

		//print actual trans
		`uvm_info(get_type_name() , $sformatf("actual tr: PADDR = %0d PWRITE = %0d PWDATA= %0d PRDATA= %0d" , actual_tr.PADDR , actual_tr.PWRITE , actual_tr.PWDATA , actual_tr.PRDATA) , UVM_LOW)


		if(actual_tr.PWRITE) begin
			mem[actual_tr.PADDR] = actual_tr.PWDATA;

			`uvm_info(get_type_name() , $sformatf("WRITE ::storedata = %0d at addr = %0d" , actual_tr.PWDATA , actual_tr.PADDR) , UVM_LOW)

		end
		else begin
			if( mem.exists(actual_tr.PADDR))begin
                                //if actual adddr present in memory then  we
				//should have expected data 
				`uvm_info(get_type_name() , $sformatf("expected tr: PADDR = %0d PRDATA=%0d", actual_tr.PADDR , mem[actual_tr.PADDR] ) ,UVM_LOW)

				if(actual_tr.PRDATA == mem[actual_tr.PADDR])begin
					`uvm_info(get_type_name() , "READ PASS :: ACT == EXP" , UVM_LOW)
				end
				else begin
                                 	`uvm_error(get_type_name() , $sformatf("READ FAIL :: ACT = %0d EXP = %0d" ,actual_tr.PRDATA , mem[actual_tr.PADDR] ))
				end
			end
			else begin
				//if data not exists in memory 
				`uvm_warning(get_type_name() , $sformatf("read to uninitialized addr = %0d" , actual_tr.PADDR))
			end
		end
	endfunction
endclass




