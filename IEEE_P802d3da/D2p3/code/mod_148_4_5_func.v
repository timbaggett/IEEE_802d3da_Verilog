/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_4_5_func.v                                  */
/*        Date:   26/11/2024                                          */
/*                                                                    */
/**********************************************************************/

module           mod_148_4_5_func();


`ifdef simulate
`include "IEEE_P802_3da_param.v"
`include "mod_148_4_5_param.v"
`include "mod_148_4_5_func_include.v"


/**********************************************************************/
/*                                                                    */
/* ENCODE_TXER function                                               */
/*                                                                    */
/**********************************************************************/

function      ENCODE_TXER;
input[1:0]    tx_cmd_sync;
begin
    ENCODE_TXER = plca.mod_inst_148_4_5_func.ENCODE_TXER_function(tx_cmd_sync);
end
endfunction


/**********************************************************************/
/*                                                                    */
/* ENCODE_TXD function                                                */
/*                                                                    */
/**********************************************************************/

function[3:0] ENCODE_TXD;
input[1:0]    tx_cmd_sync;
begin
    ENCODE_TXD = plca.mod_inst_148_4_5_func.ENCODE_TXD_function(tx_cmd_sync);
end
endfunction

`endif

endmodule

