transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/zero_extender.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/sign_extender.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/shift_left_2.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/serial_buf.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/register.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/processor.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/pc.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/mux4.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/mux2.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/load_extender.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/inst_rom.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/data_memory.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/control_unit.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/async_memory.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/alu.v}
vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/adder.v}

vlog -vlog01compat -work work +incdir+C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula {C:/Mac/Home/Documents/COE181/quartus_codes/lab9_v2/lab9-acebu-cagula/testbench.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
