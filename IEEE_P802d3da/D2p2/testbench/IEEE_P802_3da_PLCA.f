// Top level module and test bench

`include "IEEE_P802_3da_10M_DTE_PLCA_RS_top.v"
`include "IEEE_P802_3da_10M_DTE_PLCA_RS_tb.v"

// Include DTE

`include "IEEE_P802_3_10M_DTE.v"

// Include MAC

`include "Clause 4\code\IEEE_802_3_2022_MAC.v"

// Include PLS

`include "Clause 6\code\IEEE_802_3_2022_PLS.v"

// Include RS

`include "IEEE_P802_3da_PLCA_RS.v"
`include "mod_148_3.v"
`include "mod_148_5.v"
`include "mod_148_7.v"
`include "mod_148_8.v"
`include "mod_148_9.v"
`include "mod_148_4_4_timer.v"
`include "mod_148_4_5_timer.v"
`include "mod_148_4_6_timer.v"
`include "mod_148_4_7_timer.v"
`include "mod_148_4_5_func.v"
`include "mod_148_4_7_func.v"

// Include PHY

`include "Clause 147\code\10BASE_T1S_phy.v"
`include "Clause 147\code\mod_147_4.v"
`include "Clause 147\code\mod_147_7.v"
`include "Clause 147\code\mod_147_10.v"
`include "Clause 147\code\mod_147_11.v"
`include "Clause 147\code\mod_147_14.v"
`include "Clause 147\code\mod_147_3_7_1_timer.v"
`include "Clause 147\code\mod_147_3_7_2_timer.v"
`include "Clause 147\code\mod_147_3_2_timer.v"


// Include IEEE 802.3 timer

`include "generic\code\IEEE_802_3_timer.v"
`include "generic\code\IEEE_802_3_timing.v"
