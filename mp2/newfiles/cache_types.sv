package cache_types;

typedef logic  [2:0] cache_offset;
typedef logic  [2:0] cache_index;
typedef logic  [8:0] cache_tag;
typedef logic [11:0] pmem_address_base;
typedef logic [7:0] [15:0] cache_line; 
typedef logic [11:0]    victim_tag;/*size = 12*/
   
endpackage : cache_types
