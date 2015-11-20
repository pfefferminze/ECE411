onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label {pc} -radix hexadecimal /mp2_tb/dut/core/data_path/pc/data
add wave -noupdate -label registers -radix hexadecimal /mp2_tb/dut/core/data_path/rfile/data
add wave -noupdate -label {clk
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/clk
add wave -noupdate -label pc -radix hexadecimal /mp2_tb/dut/core/data_path/pc/data
add wave -noupdate -label pmem_resp -radix hexadecimal /mp2_tb/pmem_resp
add wave -noupdate -label pmem_read -radix hexadecimal /mp2_tb/pmem_read
add wave -noupdate -label pmem_write -radix hexadecimal /mp2_tb/pmem_write
add wave -noupdate -label pmem_address -radix hexadecimal /mp2_tb/pmem_address
add wave -noupdate -label pmem_rdata -radix hexadecimal /mp2_tb/pmem_rdata
add wave -noupdate -label pmem_wdata -radix hexadecimal /mp2_tb/pmem_wdata
add wave -noupdate -label cpu_state -radix hexadecimal /mp2_tb/dut/core/control_unit/state
add wave -noupdate -label {i_mem_write
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/i_mem_write
add wave -noupdate -label {d_mem_write
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/d_mem_write
add wave -noupdate -label i_mem_read -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/i_mem_read
add wave -noupdate -label {i_resp
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/i_resp
add wave -noupdate -label {d_resp
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/d_resp
add wave -noupdate -label {d_mem_read
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/d_mem_read
add wave -noupdate -label {L2_resp
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/L2_resp
add wave -noupdate -label {L2_read
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/L2_read
add wave -noupdate -label {L2_write
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/L2_write
add wave -noupdate -label {L2_rdata
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/L2_rdata
add wave -noupdate -label {i_rdata
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/i_rdata
add wave -noupdate -label {d_rdata
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/d_rdata
add wave -noupdate -label {i_raddr
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/i_raddr
add wave -noupdate -label {d_raddr
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/d_raddr
add wave -noupdate -label {L2_wdata
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/L2_wdata
add wave -noupdate -label {d_wdata
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/d_wdata
add wave -noupdate -label {L2_addr
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/L2_addr
add wave -noupdate -label {state
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/state
add wave -noupdate -label {next_state
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/next_state
add wave -noupdate -label {req_type
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/req_type
add wave -noupdate -label {next_req_type
} -radix hexadecimal /mp2_tb/dut/memory/level_one/arbitor_unit/next_req_type
add wave -noupdate -label dcache_mem_address -radix hexadecimal /mp2_tb/dut/memory/level_one/dcache/mem_address
add wave -noupdate -label dcache_mem_wdata -radix hexadecimal /mp2_tb/dut/memory/level_one/dcache/mem_wdata
add wave -noupdate -label dcache_mem_read -radix hexadecimal /mp2_tb/dut/memory/level_one/dcache/mem_read
add wave -noupdate -label dcache_mem_write -radix hexadecimal /mp2_tb/dut/memory/level_one/dcache/mem_write
add wave -noupdate -label dcache_mem_byte_enable -radix hexadecimal /mp2_tb/dut/memory/level_one/dcache/mem_byte_enable
add wave -noupdate -label dcache_mem_rdata -radix hexadecimal /mp2_tb/dut/memory/level_one/dcache/mem_rdata
add wave -noupdate -label {dcache mem_resp} -radix hexadecimal /mp2_tb/dut/memory/level_one/dcache/mem_resp
add wave -noupdate -label {dcache pmem_rdata} -radix hexadecimal /mp2_tb/dut/memory/level_one/dcache/pmem_rdata
add wave -noupdate -label {dcache pmem_resp} -radix hexadecimal /mp2_tb/dut/memory/level_one/dcache/pmem_resp
add wave -noupdate -label {dcache pmem_wdata} -radix hexadecimal /mp2_tb/dut/memory/level_one/dcache/pmem_wdata
add wave -noupdate -label {dcache pmem_address} -radix hexadecimal /mp2_tb/dut/memory/level_one/dcache/pmem_address
add wave -noupdate -label {dcache pmem_read} -radix hexadecimal /mp2_tb/dut/memory/level_one/dcache/pmem_read
add wave -noupdate -label dcache_pmem_write -radix hexadecimal /mp2_tb/dut/memory/level_one/dcache/pmem_write
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12719709 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 196
configure wave -valuecolwidth 136
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 100000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {556651 ps}
