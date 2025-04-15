/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_4_4_param.v                                 */
/*        Date:   20/11/2024                                          */
/*                                                                    */
/**********************************************************************/


// dplca_txop_claim
// ----------------

parameter        SOFT                =  2'b00;
parameter        HARD                =  2'b01;
//parameter      NONE                =  2'b10;


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

