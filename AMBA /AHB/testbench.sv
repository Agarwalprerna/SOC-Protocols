import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ahb_tb_package.sv"
`include "ahb_design.sv"

module top;
 
  ahb_if ahb_intf() ;
  ahb_rtl_slave_2 dut(.sintf(ahb_intf));
  
  initial begin
    uvm_config_db#(virtual ahb_if)::set(null,"*","dut_vif",ahb_intf);
  end
  
  always begin
    #5 ahb_intf.clk = ~ahb_intf.clk;
  end
  
  initial begin
    ahb_intf.HRESETn = 0;
    ahb_intf.clk = 0 ;
  
    #10 ahb_intf.HRESETn = 1;
  end
  
  initial begin
    run_test("ahb_test");
 

  end
  
  // initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
  //end
  
endmodule
