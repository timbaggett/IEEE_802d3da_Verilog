/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_147_3_3_param.v                                 */
/*        Date:   25/08/2019                                          */
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


// ESDBRS
// ------

parameter        ESDBRS              = 3'h7;


// BEACON
// ------

parameter        BEACON              = 4'h8;


// HB
// --

parameter        HB                  = 4'hD;


// duplex_mode
// -----------

parameter        DUPLEX_FULL         =  1'b0;
parameter        DUPLEX_HALF         =  1'b1;


// link_control
// ------------

parameter        ENABLE              =  1'b0;
parameter        DISABLE             =  1'b1;


// rx_cmd
// ------

parameter        NONE                =  2'b00;
parameter        COMMIT              =  2'b01;
parameter        HEARTBEAT           =  2'b10;

