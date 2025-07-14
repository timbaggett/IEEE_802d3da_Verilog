/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_147_3_7_1_param.v                               */
/*        Date:   21/06/2019                                          */
/*                                                                    */
/**********************************************************************/

// hb_cmd
// ------

//               HEARTBEAT           =  1'b0;
//               NONE                =  1'b1;


// rx_cmd
// ------

//parameter      BEACON              =  2'b00;
parameter        COMMIT              =  2'b01;
parameter        HEARTBEAT           =  2'b10;
parameter        NONE                =  2'b11;


// tx_cmd
// ------

parameter        BEACON              =  2'b00;
parameter        TX_COMMIT           =  2'b01;
parameter        TX_SILENCE          =  2'b10;

