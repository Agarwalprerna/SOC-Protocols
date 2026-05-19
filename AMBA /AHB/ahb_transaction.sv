class ahb_transaction extends uvm_sequence_item;
  rand bit [1:0] HSELx ;
  rand bit HWRITE;
  rand bit [31:0] HADDR,HDATA[8];
  rand bit [1:0] HSIZE;
  rand bit [2:0] HBURST;
  rand bit [1:0] HTRANS;
  rand bit [3:0] addr_length ;
 
 
  `uvm_object_utils_begin(ahb_transaction)
     `uvm_field_int(HWRITE,UVM_ALL_ON)
     `uvm_field_int(HSELx,UVM_ALL_ON)
     `uvm_field_int(HADDR,UVM_ALL_ON)
     `uvm_field_int(HDATA[0],UVM_ALL_ON)
     `uvm_field_int(HSIZE,UVM_ALL_ON)
     `uvm_field_int(HBURST,UVM_ALL_ON)
     `uvm_field_int(HTRANS,UVM_ALL_ON)
  `uvm_object_utils_end

  
  /* 
  HBURST == 000   --   SINGLE              
  HBURST == 001   --   INCR
  HBURST == 010   --   WRAP4
  HBURST == 011   --   INC4
  HBURST == 100   --   WRAP8
  HBURST == 101   --   INC8
  HBURST == 110   --   WRAP16
  HBURST == 111   --   INC16
  HSIZE == 000   --   8bit
  HSIZE == 001   --   16bit
  HSIZE == 010   --   32bit
  HSIZE == 011   --   64bit
  HSIZE == 100   --   128bit
  HSIZE == 101   --   256bit
  HSIZE == 110   --   512bit
  HSIZE == 111   --   1024bit
  */
  
  constraint addr_length_CONS {  
if(HBURST==3'b001 ) addr_length ==8 ;
if(HBURST==3'b010 ) addr_length ==4 ;          
if(HBURST==3'b011 ) addr_length ==4 ;          
if(HBURST==3'b100 ) addr_length ==8 ;         
if(HBURST==3'b101 ) addr_length ==8 ;           
if(HBURST==3'b110 ) addr_length ==16 ;
if(HBURST==3'b111 ) addr_length ==16 ;
                              }
  
  constraint HBURST_CONS {soft HBURST inside {0,1};}
  
  constraint HTRANS_CONS {soft HTRANS inside {0,2,3};}
  
  constraint HWRITE_CONS {HWRITE inside {0,1};}
  
  constraint HSEL_CONS {HSELx == 1'b1 ;}
  
 // constraint addr_length_CONS {addr_length== 6;}
  
  
    constraint HADDR_RANGE {if(HSIZE== 3'b001) soft HADDR%2==0;
                            if(HSIZE== 3'b010) soft HADDR%4==0;
                            if(HSIZE== 3'b011) soft HADDR%8==0;
                          if(HSIZE== 3'b100) HADDR%16==0;
                          if(HSIZE== 3'b101) HADDR%32==0;
                          if(HSIZE== 3'b110) HADDR%64==0;
                          if(HSIZE== 3'b111) HADDR%128==0;
                          HADDR inside {[0:100]};
                         }  
  
  function new(string name="" );
    super.new(name);
  endfunction
  
  
   function void post_randomize();
  //  $display("Post rand");
  endfunction
  
  
   function void pre_randomize();
  //   $display("Pre rand");
  endfunction

  
  
endclass
