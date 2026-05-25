
//`include "interface.sv"

module apb_assertions(apb_inf inf);

   //default clock
   default clocking cb @(posedge inf.Pclk); 
   endclocking


   // 1) setup- address phase
   property setup_to_address;
	   disable iff (!inf.reset)
	   (inf.PSEL && !inf.PENABLE) |=>(inf.PSEL && inf.PENABLE);
   endproperty

   ass_setup_to_address: assert property(setup_to_address);
        //else $error("APB: setup to address phase not followed");

     //PENABLE only high when slave is selected
     property penable_implies_psel;
	     disable iff (!inf.reset)
	     (inf.PENABLE) |-> (inf.PSEL);
     endproperty

     ass_penable_implies_psel: assert property (penable_implies_psel);


     // 2) during wait state - PENABLE constant
     property p_wait_state_hold;
	     disable iff (!inf.reset)
	     (inf.PSEL && inf.PENABLE && !inf.PREADY) |=> (inf.PENABLE && inf.PSEL);
     endproperty

     ass_wait_state_hold: assert property(p_wait_state_hold);
       
       //PENABLE should drop after PREADY
       property p_complete_transfer;
	       disable iff (!inf.reset)
	       (inf.PSEL && inf.PENABLE && inf.PREADY) |=> (!inf.PENABLE);
       endproperty

       ass_complete_transfer : assert property (p_complete_transfer);


       //3 signal stability -
       //Address Control signals stable during PENABLE is high

       property p_ctrl_stable;
	       disable iff (!inf.reset)
	       (inf.PSEL && inf.PENABLE && !inf.PREADY) |-> $stable({inf.PADDR , inf.PWRITE});
       endproperty
       ass_ctrl_stable : assert property (p_ctrl_stable);

       //PWDATA should be stable if PREADY = 0
       property p_Wdata_stable;

	       disable iff (!inf.reset)
	       (inf.PSEL && inf.PENABLE && inf.PWRITE && !inf.PREADY) |-> $stable(inf.PWDATA);
       endproperty
       ass_Wdata_stable: assert property(p_Wdata_stable);

       //Read data valid when PREADY high
       property p_Rdata_valid;
	       disable iff(!inf.reset)
	       (inf.PSEL && inf.PENABLE && !inf.PWRITE && inf.PREADY) |-> !$isunknown(inf.PRDATA);
       endproperty

       ass_Rdata_valid: assert property(p_Rdata_valid);

       //4) basic rules of APB
       
       // when slave is not selected then PENABLE not asserted
       property p_idle_rule;
	       disable iff (!inf.reset)
	       (!inf.PSEL) |-> (!inf.PENABLE);
       endproperty
       ass_idle_rule:assert property(p_idle_rule);
        
       // when slave is selected then PADDR , PWRITE , PENABLE must not be X
       
       property p_ctrl_notunknown;
	       disable iff (!inf.reset)
	       inf.PSEL |-> !$isunknown({inf.PADDR , inf.PWRITE, inf.PENABLE});
       endproperty

       ass_ctrl_notunknown: assert property(p_ctrl_notunknown);


       // 5) ERROR handling

       //no error during wait states
       property p_noerror_wait;
	       disable iff(!inf.reset)
	       (inf.PSEL && inf.PENABLE && !inf.PREADY) |-> (inf.PSLVERR == 0);
       endproperty

       ass_noerror_wait: assert property(p_noerror_wait);

endmodule
       


