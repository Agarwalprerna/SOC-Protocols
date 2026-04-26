`include "uvm_macros.svh"
`include "package.sv"
`include "apb_slave.sv"

module tb;
    import uvm_pkg::*;
    import pkg::*;

    bit Pclk;
    always #5 Pclk = ~Pclk;

    apb_inf inf(Pclk);

    apb_slave dut( 
	    .Pclk(Pclk) ,
	    .reset(inf.reset) ,
	    .PENABLE(inf.PENABLE) , 
	    .PSEL(inf.PSEL) ,
	    .PWRITE(inf.PWRITE) ,
	    .PWDATA(inf.PWDATA) ,
	    .PRDATA(inf.PRDATA) ,
	    .PADDR(inf.PADDR) , 
	    .PREADY(inf.PREADY) ,
	    .PSLVERR(inf.PSLVERR) 
	        );

	initial begin
			uvm_config_db #(virtual apb_inf)::set(null ,"*" ,"inf" , inf);
	end

	initial begin
		run_test("apb_test");
	end
	
	endmodule

