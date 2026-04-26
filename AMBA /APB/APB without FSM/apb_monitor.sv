
class apb_monitor extends uvm_monitor;
	`uvm_component_utils(apb_monitor)

	`COMP_constructor(apb_monitor)


	 virtual apb_inf inf;
	 apb_trans tr;
	 uvm_analysis_port #(apb_trans) ap_mon;

	 function void build_phase(uvm_phase phase);
		 super.build_phase(phase);
		 uvm_config_db #(virtual apb_inf)::get(this , "" , "inf" ,inf);
		 ap_mon = new("ap_mon" , this);
	 endfunction

	 task run_phase(uvm_phase phase);
		 super.run_phase(phase);
		 forever begin
			 tr= apb_trans::type_id::create("tr");
	 		 @(inf.mon_cb.PSEL && inf.mon_cb.PENABLE && inf.mon_cb.PREADY);  // if all these 3 high then data sample takes place
			 tr.PADDR = inf.mon_cb.PADDR;
			 tr.PWRITE = inf.mon_cb.PWRITE;
			 if(tr.PWRITE)
				 tr.PWDATA = inf.mon_cb.PWDATA;
			 else
				 tr.PRDATA =  inf.mon_cb.PRDATA;

			 ap_mon.write(tr);
		 end
	 endtask
 endclass

			 
