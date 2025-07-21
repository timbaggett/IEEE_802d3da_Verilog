/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_4_4_param.v                                 */
/*        Date:   09/04/2025                                          */
/*                                                                    */
/**********************************************************************/


// dplca_txop_claim
// ----------------

parameter        UNCLAIMED           =  1'b0;
parameter        CLAIMED             =  1'b1;


// tx_cmd
// ------

//parameter      BEACON              =  2'b00;
//parameter      COMMIT              =  2'b01;
//parameter      NONE                =  2'b10;


// rx_cmd
// ------

parameter        BEACON              =  2'b00;
parameter        COMMIT              =  2'b01;
parameter        NONE                =  2'b10;


// dplca_aging
// -----------

parameter        OFF                 =  1'b0;
parameter        ON                  =  1'b1;


