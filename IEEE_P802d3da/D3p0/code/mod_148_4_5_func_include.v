/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_4_5_func_include.v                          */
/*        Date:   22/11/2024                                          */
/*                                                                    */
/**********************************************************************/


/**********************************************************************/
/*                                                                    */
/* ENCODE_TXER function                                               */
/*                                                                    */
/* This  function takes as  its argument  the tx_cmd variable defined */
/* in 148.4.5.2.                                                      */
/* It  returns  TRUE  if  tx_cmd  is BEACON or  COMMIT. Otherwise  it */
/* returns the value of the plca_txer variable, defined in 148.4.6.2. */
/*                                                                    */
/**********************************************************************/

function      ENCODE_TXER_function;
input[1:0]    tx_cmd_sync;
begin

    case(tx_cmd_sync)

    BEACON : ENCODE_TXER_function = TRUE;
    COMMIT : ENCODE_TXER_function = TRUE;
    default: ENCODE_TXER_function = plca.plca_txer;

    endcase

end
endfunction


/**********************************************************************/
/*                                                                    */
/* ENCODE_TXD function                                                */
/* This  function takes as  its argument the  tx_cmd variable defined */
/* in 148.4.5.2.                                                      */
/* If tx_cmd is BEACON, the return value is the  TXD encoding defined */
/* in Table 22–1 for the BEACON request.                              */
/* If tx_cmd is COMMIT, the return value  is the TXD encoding defined */
/* in Table 22–1 for the COMMIT request.                              */
/* Otherwise, the return value is 0000.                               */
/*                                                                    */
/**********************************************************************/

function[3:0] ENCODE_TXD_function;
input[1:0]    tx_cmd_sync;
begin

    case(tx_cmd_sync)

    BEACON : ENCODE_TXD_function = 4'b0010;
    COMMIT : ENCODE_TXD_function = 4'b0011;
    default: ENCODE_TXD_function = 4'b0000;

    endcase

end
endfunction





