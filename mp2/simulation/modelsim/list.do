onerror {resume}
add list -hex -notrig -width 56 -label {L2 Mem address} /mp2_tb/dut/memory/level_two/datapath_unit/mem_address
add list -hex -notrig -label {L1 pmem_wdata} /mp2_tb/dut/memory/level_one/dcache/datapath_unit/pmem_wdata
add list -hex -notrig -label {L1 pmem_write} /mp2_tb/dut/memory/level_one/icache/pmem_write
add list -hex -notrig -label {L2 mem_wdata} /mp2_tb/dut/memory/level_two/datapath_unit/mem_wdata
add list -hex -label {L2 mem_write} /mp2_tb/dut/memory/level_two/control_unit/mem_write
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
