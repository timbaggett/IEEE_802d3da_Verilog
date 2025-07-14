/**********************************************************************/
/*                           IEEE P802.3br                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_99_4_7_param.v                                  */
/*        Date:   17/01/2022                                          */
/*                                                                    */
/**********************************************************************/

// minFrag
// -------

parameter        minFrag             = 7'h40;


// PREAMBLE
// --------

parameter        PREAMBLE            = 8'h55;


// verifyLimit
// -----------

parameter        verifyLimit         = 4'h3;


// SFD
// ---

parameter        SFD                 = 8'hD5;


// SMD values
// ----------

parameter        SMD_S0              = 8'hE6;
parameter        SMD_S1              = 8'h4C;
parameter        SMD_S2              = 8'h7F;
parameter        SMD_S3              = 8'hB3;

parameter        SMD_C0              = 8'h61;
parameter        SMD_C1              = 8'h52;
parameter        SMD_C2              = 8'h9E;
parameter        SMD_C3              = 8'h2A;

parameter        SMD_V               = 8'h07;
parameter        SMD_R               = 8'h19;
parameter        SMD_E               = 8'hD5;