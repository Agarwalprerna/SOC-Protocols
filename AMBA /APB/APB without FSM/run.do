vlib work
vlog tb.sv +acc
vsim -voptargs=+acc tb +UVM_TESTNAME=apb_test
#do wave.do
run -all

