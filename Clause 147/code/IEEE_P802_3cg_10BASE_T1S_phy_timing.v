/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: IEEE_P802_3cg_10BASE_T1S_phy_timing.v               */
/*        Date:   29/01/2025                                          */
/*                                                                    */
/**********************************************************************/


/*                                                                    */
/* +----------------------------------------+-------+-------+-------+ */
/* | Parameter                              |  min  |  max  | units | */
/* +----------------------------------------+-------+-------+-------+ */
/* | TX_EN/TX_ER_sampled_to_MDI_output      |  120  |   440 |    ns | */
/* +----------------------------------------+-------+-------+-------+ */
/*                                                                    */

parameter TX_EN_TX_ER_sampled_to_MDI_output_min =   120;
parameter TX_EN_TX_ER_sampled_to_MDI_output_max =   440;

/*                                                                    */
/* +----------------------------------------+-------+-------+-------+ */
/* | Parameter                              |  min  |  max  | units | */
/* +----------------------------------------+-------+-------+-------+ */
/* | MDI input to RX_DV asserted            |   2.4 |     4 |    us | */
/* +----------------------------------------+-------+-------+-------+ */
/* | MDI input to RX_ER asserted            |   1.6 |     4 |    us | */
/* +----------------------------------------+-------+-------+-------+ */
/*                                                                    */

parameter MDI_input_to_RX_DV_asserted_min       = 2_400;
parameter MDI_input_to_RX_DV_asserted_max       = 4_000;

parameter MDI_input_to_RX_ER_asserted_min       = 1_600;
parameter MDI_input_to_RX_ER_asserted_max       = 4_000;

/*                                                                    */
/* +----------------------------------------+-------+-------+-------+ */
/* | Parameter                              |  min  |  max  | units | */
/* +----------------------------------------+-------+-------+-------+ */
/* | MDI input to CRS asserted              |  400  |  1040 |    ns | */
/* +----------------------------------------+-------+-------+-------+ */
/* | MDI input to CRS deasserted            |  640  |  1120 |    ns | */
/* +----------------------------------------+-------+-------+-------+ */
/*                                                                    */

parameter MDI_input_to_CRS_asserted_min         =   400;
parameter MDI_input_to_CRS_asserted_max         = 1_040;

parameter MDI_input_to_CRS_deasserted_min       =   640;
parameter MDI_input_to_CRS_deasserted_max       = 1_128;

/*                                                                    */
/* +----------------------------------------+-------+-------+-------+ */
/* | Parameter                              |  min  |  max  | units | */
/* +----------------------------------------+-------+-------+-------+ */
/* | MDI input to COL asserted              |     0 |     5 |    us | */
/* +----------------------------------------+-------+-------+-------+ */
/* | MDI input to COL deasserted            |     0 |   3.2 |    us | */
/* +----------------------------------------+-------+-------+-------+ */

parameter MDI_input_to_COL_asserted_min         =     0;
parameter MDI_input_to_COL_asserted_max         = 5_000;

parameter MDI_input_to_COL_deasserted_min       =     0;
parameter MDI_input_to_COL_deasserted_max       = 3_200;