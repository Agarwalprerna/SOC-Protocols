interface apb_inf( input Pclk);
	logic reset;
	logic PSEL;
	logic PWRITE;
	logic PENABLE;
	logic PREADY;
	logic PSLVERR;
	logic [`ADDR_WIDTH -1:0] PADDR;
	logic [`DATA_WIDTH-1:0] PRDATA;
	logic [`DATA_WIDTH-1:0] PWDATA;

	clocking dr_cb @(posedge Pclk);
		default input #1 output #0;
		input PRDATA , PREADY , PSLVERR;
		output PENABLE , PSEL ,PWRITE , PADDR , PWDATA, reset;
	endclocking

        clocking mon_cb @(posedge Pclk);
		default input #1 output #0;
		input PRDATA , PREADY , PSLVERR;
		input PENABLE , PSEL ,PWRITE , PADDR , PWDATA, reset;
	endclocking

endinterface


