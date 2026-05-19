interface ahb_if  ;
  logic [1:0] HSELx,HWRITE,HCLK,HRESETn;
  logic clk,reset;
  logic [31:0] HADDR,HWDATA,HRDATA;
  logic [1:0] HSIZE;
  logic [2:0] HBURST;
 
  logic [1:0] HTRANS;
  
  logic HMASTLOCK;
  logic HREADY;
  logic state;
  logic [1:0] HRESP;

  logic [4:0]local_addr;

  logic count;
 
  clocking master_cb @(posedge clk);
    input HRDATA , HMASTLOCK, HREADY, HRESP ;
    output HWRITE , HRESETn, HSELx , HCLK , HADDR , HWDATA , HSIZE , HBURST, HTRANS ;
  endclocking: master_cb
  
  modport master(clocking master_cb);
  
endinterface

