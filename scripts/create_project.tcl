# This file sets up the simulation environment.


create_project vlsi2_group5 -part xc7z010iclg225-1L
set_property target_language Verilog [current_project]
set_property "default_lib" "work" [current_project]
tclapp::install ultrafast -quiet


add_files {../rtl/aes/aes_cipher_top.v}
add_files {../rtl/aes/aes_inv_cipher_top.v}
add_files {../rtl/aes/aes_inv_sbox.v}
add_files {../rtl/aes/aes_key_expand_128.v}
add_files {../rtl/aes/aes_rcon.v}
add_files {../rtl/aes/aes_sbox.v}
update_compile_order -fileset sources_1

add_files {../rtl/hash_ip/controller.vhd}
add_files {../rtl/hash_ip/SHA_IP.vhd}
add_files {../rtl/hash_ip/sha256.v}
update_compile_order -fileset sources_1

add_files -norecurse ../rtl/config_pkg.vh
add_files -norecurse ../rtl/timescale.v

add_files {../rtl/aes_apb_s00.v}
add_files {../rtl/aes_s00_wrapper_top.v}
add_files {../rtl/hash_apb_s01.v}
add_files {../rtl/hash_s01_wrapper_top.v}
add_files {../rtl/master.v}
add_files {../rtl/master_wrapper_top.v}
add_files {../rtl/top.v}

update_compile_order -fileset sources_1

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse  ../tb/top_tb.v

set_property top top_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

set_property -name {xsim.simulate.runtime} -value {1000us} -objects [get_filesets sim_1]

launch_simulation 	

current_wave_config {Untitled 1}

add_wave 	{{/top_tb/U0/clk}}
add_wave	{{/top_tb/U0/rstn}}
add_wave	{{/top_tb/U0/host_instruction}} 
add_wave	{{/top_tb/U0/host_data}} 
add_wave	{{/top_tb/U0/start}} 
add_wave	{{/top_tb/U0/operation_done}} 
add_wave	{{/top_tb/U0/out}}
			
add_wave	{{/top_tb/U0/S00/U0/encode/ld}} 
add_wave	{{/top_tb/U0/S00/U0/encode/key}} 
add_wave	{{/top_tb/U0/S00/U0/encode/text_in}} 
add_wave	{{/top_tb/U0/S00/U0/encode/w0}} 
add_wave	{{/top_tb/U0/S00/U0/encode/w1}} 
add_wave	{{/top_tb/U0/S00/U0/encode/w2}} 
add_wave	{{/top_tb/U0/S00/U0/encode/w3}} 
add_wave	{{/top_tb/U0/M00/encrypt_output_data_r}}
add_wave	{{/top_tb/U0/S00/U0/encode/done}} 
add_wave	{{/top_tb/U0/S00/U0/encode/dcnt}} 
add_wave	{{/top_tb/U0/S00/U0/encode/tj_trig}} 
add_wave	{{/top_tb/U0/S00/U0/encode/shift_reg}} 

save_wave_config {top_tb.wcfg}
add_files -fileset sim_1 top_tb.wcfg
set_property xsim_view top_tb.wcfg [get_filesets sim_1]

restart
run all

start_gui