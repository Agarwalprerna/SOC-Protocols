class apb_trans extends uvm_sequence_item;

	`OBJ_constructor(apb_trans)

	rand bit reset;
	rand bit PWRITE;
	rand bit [`DATA_WIDTH-1:0] PWDATA;
	rand bit [`ADDR_WIDTH-1:0] PADDR;

	 bit PSEL ; //slave select
	 bit PENABLE;
	 bit [`DATA_WIDTH-1:0] PRDATA;
	 bit PREADY;
	 bit PSLVERR;

	 `uvm_object_utils_begin(apb_trans)
	 `uvm_field_int(reset , UVM_ALL_ON)
         `uvm_field_int(PSEL , UVM_ALL_ON)
         `uvm_field_int(PENABLE , UVM_ALL_ON)
          `uvm_field_int(PWRITE, UVM_ALL_ON)
          `uvm_field_int(PADDR , UVM_ALL_ON)
         `uvm_field_int(PWDATA , UVM_ALL_ON)
          `uvm_field_int(PRDATA , UVM_ALL_ON)
          `uvm_field_int(PREADY , UVM_ALL_ON)
          `uvm_field_int(PSLVERR , UVM_ALL_ON)
          `uvm_object_utils_end
 
	  //to check error 
	  constraint invalid_addr_range{
		  PADDR inside {[10:11]};
		  }
	 
	 
  endclass




	

