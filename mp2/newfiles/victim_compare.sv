//####################################################################
//####################################################################
//####################################################################
//################ Created by Nick Moore  ############################
//################  for MP2 in ECE 411 at ############################
//################ University of Illinois ############################
//################ Fall 2015              ############################
//####################################################################
//####################################################################
//####################################################################
//#                                                                  #
//#   compare.sv                                                     #
//#     Implements a comparator for comparing tags                   #
//#                                                                  #
//#     takes 2 different tags as input to be compared               #
//#                                                                  #
//#     outputs logic bit showing if tags are equal or not           #
//#            1 = equal                                             #
//#            0 = not equal                                         #
//####################################################################

import lc3b_types::*;
import cache_types::*;
module victim_compare 
(
	input victim_tag tag_a, tag_b,
	output logic isEqual
);

assign isEqual = (tag_a == tag_b);

endmodule : victim_compare
