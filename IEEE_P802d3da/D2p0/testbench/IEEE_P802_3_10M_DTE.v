/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: IEEE_P802_3_10M_DTE.v                               */
/*        Date:   20/11/2024                                          */
/*                                                                    */
/**********************************************************************/

module           dte(
                 BI_DA_P,
                 BI_DA_N,
                 tx_activity,
                 collision
                 );

inout            BI_DA_P;
inout            BI_DA_N;

output           tx_activity;
input            collision;

wire             RX_CLK;
wire[3:0]        RXD;
wire             RX_DV;
wire             RX_ER;
wire             CRS;
wire             COL;

wire             TX_CLK;

wire[3:0]        TXD;
wire             TX_EN;
wire             TX_ER;

wire[3:0]        RX;
wire             RXC;
wire             RXE;
wire             RXF;


`ifdef simulate

MAC              MAC();

PLS              PLS();

plca             RS(
                 .RX_CLK(RX_CLK),
                 .RXD(RXD),
                 .RX_DV(RX_DV),
                 .RX_ER(RX_ER),
                 .CRS(CRS),
                 .COL(COL),
                 .TX_CLK(TX_CLK),

                 .TXD(TXD),
                 .TX_EN(TX_EN),
                 .TX_ER(TX_ER)
                 );

reg              pcs_reset;
reg              pma_reset;
reg              duplex_mode;
reg              multidrop;


base_t1s         PHY(
                 pcs_reset,
                 pma_reset,
                 duplex_mode,
                 multidrop,

                 TX_CLK,
                 TX_EN,
                 TX_ER,
                 TXD,
                 CRS,

                 RX_CLK,
                 RX_DV,
                 RX_ER,
                 RXD,
                 COL,

                 BI_DA_P,
                 BI_DA_N,

                 tx_activity,
                 collision
                 );


`endif

endmodule