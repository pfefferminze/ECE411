//####################################################################
//#                                                                  #
//#                L2cache.sv                                        #
//#                                                                  #
//#               Created by Nick Moore                              #
//#                for group Random2to use                           #
//#                in MP3 in ECE 411 at                              #
//#                University of Illinois                            #
//#                Fall 2015                                         #
//#                                                                  #
//####################################################################

import lc3b_types::*;
import cache_types::*;

module L2cache ();



   L2cache_datapath();
   L2cache_control();
   
endmodule // L2cache
