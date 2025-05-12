/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_4_7_param.v                                 */
/*        Date:   26/11/2024                                          */
/*                                                                    */
/**********************************************************************/


// dplca_aging
// -----------

parameter        OFF                 =  1'b0;
parameter        ON                  =  1'b1;


// dplca_txop_claim
// ----------------

parameter        UNCLAIMED           =  2'b00;
parameter        CLAIMED             =  2'b01;


// plca_status
// -----------

parameter        FAIL                =  1'b0;
parameter        OK                  =  1'b1;


// rx_cmd
// ------

parameter        BEACON              =  2'b00;
parameter        COMMIT              =  2'b01;
//parameter      NONE                =  2'b10;


// txop_claim_table
// ----------------

//parameter      UNCLAIMED           =  2'b00;
//parameter      CLAIMED             =  2'b01;


// txop_claim_table_new
// --------------------

//parameter      UNCLAIMED           =  2'b00;
//parameter      CLAIMED             =  2'b01;


// table_name
// ----------

parameter        CLAIM_TABLE         =  1'b0;
parameter        CLAIM_TABLE_NEW     =  1'b1;


