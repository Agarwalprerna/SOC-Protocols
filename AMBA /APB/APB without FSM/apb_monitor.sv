
class apb_monitor extends uvm_monitor;
	`uvm_component_utils(apb_monitor)

	//`COMP_constructor(apb_monitor)


	 virtual apb_inf inf;
	 apb_trans tr;
	 uvm_analysis_port #(apb_trans) ap_mon;
 /*covergroup apb_cg @(posedge vif.PCLK);

  option.per_instance = 1;

  // Operation type
  cp_write: coverpoint vif.PWRITE {
    bins READ  = {0};
    bins WRITE = {1};
  }

  // Address (bucketized)
  cp_addr: coverpoint vif.PADDR {
    bins low  = {[0:15]};
    bins mid  = {[16:127]};
    bins high = {[128:255]};
  }

  // Data patterns
  cp_data: coverpoint vif.PWDATA {
    bins zero = {0};
    bins max  = {'1};
    bins others = default;
  }

  // Error response
  cp_error: coverpoint vif.PSLVERR {
    bins no_error = {0};
    bins error    = {1};
  }

  // Cross coverage
  cross cp_write, cp_addr;
  cross cp_write, cp_error;

endgroup
*/
    
         bit PWRITE , PSLVERR;
	 bit [`ADDR_WIDTH-1:0] PADDR;
	 bit [`DATA_WIDTH-1:0] PWDATA;

	 //COVERAGE GROUPS
	 covergroup apb_cg;

		 option.per_instance = 1;

		 //operation type
		 cp_write: coverpoint PWRITE{
			 bins READ = {0};
			 bins WRITE = {1};
			 }
		  
		 //Address 
		 cp_addr: coverpoint PADDR{
		         bins low = {[0:15]};
		         bins mid = {[16:127]};
		         bins high = {[128:255]};
		          }
		 //DATA patterns
		 cp_data: coverpoint PWDATA{
	                 bins zero = {0};
	                 bins others = default;
	                 }

	          //ERROR response
		  cp_error: coverpoint PSLVERR{
	                  bins no_error = {0};
	                  bins error = {1};
	             }

                  //cross coverage
		  cross cp_write , cp_addr;
                  cross cp_write , cp_error;
           endgroup
     
             

	     function new(string name = "apb_monitor" , uvm_component parent);
		     super.new(name , parent);
		     apb_cg = new();
	     endfunction


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
			 tr.PSLVERR = inf.mon_cb.PSLVERR;
			 if(tr.PWRITE)
				 tr.PWDATA = inf.mon_cb.PWDATA;
			 else
				 tr.PRDATA =  inf.mon_cb.PRDATA;

			 PWRITE = tr.PWRITE;
			 PSLVERR= tr.PSLVERR;
			 PADDR = tr.PADDR;
			 PWDATA = tr.PWDATA;

			 apb_cg.sample(); //coverage collector
			 ap_mon.write(tr);
		 end
	 endtask
 endclass

			 
