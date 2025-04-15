/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: IEEE_P802_3da_10M_DTE_PLCA_RS_top.v                 */
/*        Date:   20/11/2024                                          */
/*                                                                    */
/**********************************************************************/

`timescale 1ns/100ps

module top();

reg null_value;

`include "IEEE_P802_3da_param.v"

event            new_values;           // Generate new values for urandom_range

reg              scramble_enable;

initial
begin
    #2 -> new_values;
end

wire             BI_DA_N;
wire             BI_DA_P;

wire[15:0]       tx_activity;
reg              collision;

reg[4:0]         i;
reg[3:0]         tx_active_count;

always @(tx_activity)
begin
    tx_active_count = 0;
    for (i = 0; i <= 16; i = i + 1)
    if(tx_activity[i]) tx_active_count = tx_active_count + 1;
    if(tx_active_count > 1) collision = TRUE; else collision = FALSE; 
end    


`define dte_inst(i)                                                    \
                                                                       \
dte              dte_node_``i``(                                       \
                 .tx_activity(tx_activity[``i``]),                     \
                 .BI_DA_N(BI_DA_N),                                    \
                 .BI_DA_P(BI_DA_P),                                    \
                 .collision(collision)                                 \
                 );                                                    \
                                                                       \

`dte_inst(0)
`dte_inst(1)
`dte_inst(2)
`dte_inst(3)
`dte_inst(4)
`dte_inst(5)
`dte_inst(6)
`dte_inst(7)
`dte_inst(8)
`dte_inst(9)
`dte_inst(10)
`dte_inst(11)
`dte_inst(12)
`dte_inst(13)
`dte_inst(14)
`dte_inst(15)

endmodule
