/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_147_3_2_param.v                                 */
/*        Date:   16/06/2019                                          */
/*                                                                    */
/**********************************************************************/


// SYNC
// ----

parameter        SYNC                = 5'h18;


// SSD
// ---

parameter        SSD                 = 3'h4;


// ESD
// ---

parameter        ESD                 = 4'hD;


// ESDERR
// ------

parameter        ESDERR              = 5'h11;


// ESDOK
// -----

parameter        ESDOK               = 3'h7;


// SILENCE
// -------

parameter        SILENCE             = 5'h1F;


// ESDJAB
// ------

parameter        ESDJAB              = 5'h19;


// COMMIT
// ------

parameter        COMMIT              = 5'h18;


// ESDBRS
// ------

parameter        ESDBRS              = 3'h7;


// link_control
// ------------

parameter        ENABLE              =  1'b0;
parameter        DISABLE             =  1'b1;


// tx_cmd
// ------

parameter        BEACON              =  5'b00000;





