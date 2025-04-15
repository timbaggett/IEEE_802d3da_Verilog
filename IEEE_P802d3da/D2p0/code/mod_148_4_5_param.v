/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_4_5_param.v                                 */
/*        Date:   26/11/2024                                          */
/*                                                                    */
/**********************************************************************/


// CARRIER_STATUS
// --------------

parameter        CARRIER_OFF         =  1'b0;
parameter        CARRIER_ON          =  1'b1;


// SIGNAL_STATUS
// -------------

parameter        NO_SIGNAL_ERROR     =  1'b0;
parameter        SIGNAL_ERROR        =  1'b1;


// tx_cmd_sync
// -----------

//parameter      BEACON              =  2'b00;
//parameter      COMMIT              =  2'b01;
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


// plca_status
// -----------

parameter        FAIL                =  1'b0;
parameter        OK                  =  1'b1;

