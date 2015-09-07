onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mp1_tb/clk
add wave -noupdate /mp1_tb/mem_resp
add wave -noupdate /mp1_tb/mem_read
add wave -noupdate /mp1_tb/mem_write
add wave -noupdate -radix hexadecimal /mp1_tb/mem_byte_enable
add wave -noupdate -radix hexadecimal /mp1_tb/mem_address
add wave -noupdate -radix hexadecimal /mp1_tb/mem_rdata
add wave -noupdate -radix hexadecimal /mp1_tb/mem_wdata
add wave -noupdate -radix hexadecimal -childformat {{{/mp1_tb/dut/data_path/rfile/data[7]} -radix hexadecimal} {{/mp1_tb/dut/data_path/rfile/data[6]} -radix hexadecimal} {{/mp1_tb/dut/data_path/rfile/data[5]} -radix hexadecimal} {{/mp1_tb/dut/data_path/rfile/data[4]} -radix hexadecimal} {{/mp1_tb/dut/data_path/rfile/data[3]} -radix hexadecimal} {{/mp1_tb/dut/data_path/rfile/data[2]} -radix hexadecimal} {{/mp1_tb/dut/data_path/rfile/data[1]} -radix hexadecimal} {{/mp1_tb/dut/data_path/rfile/data[0]} -radix hexadecimal}} -expand -subitemconfig {{/mp1_tb/dut/data_path/rfile/data[7]} {-height 15 -radix hexadecimal} {/mp1_tb/dut/data_path/rfile/data[6]} {-height 15 -radix hexadecimal} {/mp1_tb/dut/data_path/rfile/data[5]} {-height 15 -radix hexadecimal} {/mp1_tb/dut/data_path/rfile/data[4]} {-height 15 -radix hexadecimal} {/mp1_tb/dut/data_path/rfile/data[3]} {-height 15 -radix hexadecimal} {/mp1_tb/dut/data_path/rfile/data[2]} {-height 15 -radix hexadecimal} {/mp1_tb/dut/data_path/rfile/data[1]} {-height 15 -radix hexadecimal} {/mp1_tb/dut/data_path/rfile/data[0]} {-height 15 -radix hexadecimal}} /mp1_tb/dut/data_path/rfile/data
add wave -noupdate -radix hexadecimal /mp1_tb/dut/data_path/ir_unit/data
add wave -noupdate -radix hexadecimal /mp1_tb/dut/data_path/ir_unit/src1
add wave -noupdate -radix hexadecimal /mp1_tb/dut/data_path/ir_unit/src2
add wave -noupdate /mp1_tb/dut/data_path/ir_unit/dest
add wave -noupdate /mp1_tb/dut/data_path/ir_unit/opcode
add wave -noupdate /mp1_tb/dut/data_path/cccomp/br_en
add wave -noupdate -expand /mp1_tb/dut/data_path/cc/data
add wave -noupdate {/mp1_tb/dut/data_path/cc/data[1]}
add wave -noupdate /mp1_tb/dut/data_path/cccomp/n
add wave -noupdate /mp1_tb/dut/data_path/cccomp/inst_n
add wave -noupdate /mp1_tb/dut/data_path/cccomp/z
add wave -noupdate /mp1_tb/dut/data_path/cccomp/inst_z
add wave -noupdate /mp1_tb/dut/data_path/cccomp/p
add wave -noupdate /mp1_tb/dut/data_path/cccomp/inst_p
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {17572 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 557
configure wave -valuecolwidth 71
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1 us}
