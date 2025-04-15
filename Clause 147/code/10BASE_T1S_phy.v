/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: 10BASE_T1S_phy.v                                    */
/*        Date:   29/01/2025                                          */
/*                                                                    */
/**********************************************************************/

module           base_t1s(
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

input            pcs_reset;
input            pma_reset;
input            duplex_mode;
input            multidrop;

output           TX_CLK;
input            TX_EN;
input            TX_ER;
input[3:0]       TXD;
output           CRS;

output           RX_CLK;
output           RX_DV;
output           RX_ER;
output[3:0]      RXD;
output           COL;

inout            BI_DA_P;
inout            BI_DA_N;

output           tx_activity;
input            collision;

wire             BI_DA_P_tx_out;
wire             BI_DA_N_tx_out;

assign BI_DA_P = BI_DA_P_tx_out;
assign BI_DA_N = BI_DA_N_tx_out;

wire             BI_DA_P_rx_in;
wire             BI_DA_N_rx_in;

assign BI_DA_P_rx_in = BI_DA_P;
assign BI_DA_N_rx_in = BI_DA_N;


`ifdef simulate
`include "Clause 147\code\IEEE_P802_3cg_param.v"
`include "Clause 147\code\IEEE_P802_3cg_10BASE_T1S_phy_timing.v"

/*                                                                    */
/* delay_type                                                         */
/*                                                                    */
/* This value selects between min, typ, max, random, none PHY delays. */
/*                                                                    */

reg[2:0]         delay_type;           // min, typ, max, random, none
reg[63:0]        delay_type_ASCII;

always@(delay_type)
begin
    casex(delay_type)
        no_delay      : delay_type_ASCII = "None";
        minimum_delay : delay_type_ASCII = "Minimum";
        typical_delay : delay_type_ASCII = "Typical";
        maximum_delay : delay_type_ASCII = "Maximum";
        random_delay  : delay_type_ASCII = "Random";
    endcase
end

/*                                                                    */
/* symb_timer                                                         */
/*                                                                    */
/* A continuous  free-running  timer.  PMA_UNITDATA.request  messages */
/* are  issued  by the  PCS concurrently  with  symb_timer_done  (see */
/* 147.2.2).  TX_CLK     (see  22.2.2.1)  shall  be  generated   from */
/* symb_timer  with   the  rising  edge   of   TX_TCLK      generated */
/* synchronously with symb_timer_done.                                */
/* Continuous timer: The condition symb_timer_done becomes  true upon */
/* timer expiration.                                                  */
/* Restart time: Immediately after expiration.                        */
/* Duration: 400 ns ± 100 ppm (see 22.2.2.1)                          */
/*                                                                    */
/* STD                                                                */
/*                                                                    */
/* STD Alias for symbol timer done.                                   */
/*                                                                    */

real        clock_offset;
initial     clock_offset = $urandom_range(base_t1s.mod_inst_147_3_2_timer.symb_timer.timer_duration, 0);

reg TX_CLK;
initial TX_CLK = FALSE;
initial #clock_offset forever #(base_t1s.mod_inst_147_3_2_timer.symb_timer.timer_duration/2) TX_CLK = !TX_CLK;

reg STD;
initial STD = FALSE;
always @(posedge TX_CLK) STD = TRUE;

/*                                                                    */
/* tx_cmd                                                             */
/*                                                                    */
/* Encoding present  on  TXD<3:0>, TX_ER,  and  TX_EN  as  defined in */
/* Table 22–1.                                                        */
/* Values:                                                            */
/* BEACON:  PLCA  BEACON  indication encoding  present  on  TXD<3:0>, */
/* TX_ER, and TX_EN.                                                  */
/* COMMIT:  PLCA  COMMIT  indication encoding  present  on  TXD<3:0>, */
/* TX_ER, and TX_EN.                                                  */
/* SILENCE: TXD<3:0> does not  encode any  of  the above requests, or */
/* TX_ER = FALSE, or TX_ER = TRUE.                                    */
/*                                                                    */

reg[4:0]  tx_cmd;
reg[63:0] tx_cmd_ASCII;

always @(TX_EN, TX_ER, TXD)
begin
    if(TX_EN == FALSE && TX_ER == TRUE && TXD == 4'b0010)
    begin
        tx_cmd = mod_inst_147_4.BEACON;
        tx_cmd_ASCII = "BEACON";
    end
    else if(TX_EN == FALSE && TX_ER == TRUE && TXD == 4'b0011)
    begin
        tx_cmd = mod_inst_147_4.COMMIT;
        tx_cmd_ASCII = "COMMIT";
    end
    else
    begin
        tx_cmd = mod_inst_147_4.SILENCE;
        tx_cmd_ASCII = "SILENCE";
    end
end

/*                                                                    */
/* 147.4.2 PMA Transmit function                                      */
/*                                                                    */
/* If  the tx_sym parameter value is  the special 5B symbol 'I',  the */
/* PMA shall, in order:                                               */
/* a) Transmit an additional DME encoded 0, if  the previous value of */
/* the tx_sym parameter was anything but the 5B symbol 'I',           */
/* b)   When  operating  in  multidrop  mode,  present   the  minimum */
/* impedance described  in  147.9.2  at the  MDI.  This shall  happen */
/* within  40  ns  after  the  additional  DME  encoded  0  has  been */
/* transmitted.                                                       */
/* c)  When  operating in point-to-point mode, the  PMA drives BI_DA+ */
/* and BI_DA– to the  same voltage with 100 Ohm nominal impedance, so */
/* that their difference is 0 V.                                      */
/*                                                                    */
/* If tx_sym value is  anything other than 'I'  the  following  rules */
/* apply:                                                             */
/* a) A “clock transition” shall always be  generated at the start of */
/* each bit.                                                          */
/* b) A “data  transition”  in  the middle of  a nominal  bit  period */
/* shall  be  generated,  if the bit to be transmitted  is a  logical */
/* '1'.  Otherwise  no  transition shall be generated until the  next */
/* bit.                                                               */
/*                                                                    */

reg              BI_DA_P_tx;
reg              BI_DA_N_tx;

reg[2:0]         tx_sym_bit;
reg[4:0]         tx_sym_n_1;

assign           #1 symbol_clock = TX_CLK;

always @(posedge symbol_clock)
begin
    tx_sym_n_1 <= tx_sym;
    if(tx_sym == base_t1s.mod_inst_147_4.SILENCE)
    begin
        if(tx_sym_n_1 != base_t1s.mod_inst_147_4.SILENCE)
        begin
            BI_DA_P_tx <= !BI_DA_P_tx;
            BI_DA_N_tx <= !BI_DA_N_tx;
            #((base_t1s.mod_inst_147_3_2_timer.symb_timer.timer_duration/5));
            BI_DA_P_tx <= 1'bZ;
            BI_DA_N_tx <= 1'bZ;
        end
        else
        begin
            BI_DA_P_tx <= 1'bZ;
            BI_DA_N_tx <= 1'bZ;
        end
    end
    else
    begin
        if(tx_sym_n_1 == base_t1s.mod_inst_147_4.SILENCE)
        begin
            BI_DA_P_tx <= 1'b1;
            BI_DA_N_tx <= 1'b0;
        end        
        else
        begin
            BI_DA_P_tx <= !BI_DA_P_tx;
            BI_DA_N_tx <= !BI_DA_N_tx;
        end
        for(tx_sym_bit = 0; tx_sym_bit <= 4; tx_sym_bit = tx_sym_bit + 1)
        begin
            #(base_t1s.mod_inst_147_3_2_timer.symb_timer.timer_duration/10);
            if(tx_sym_n_1[tx_sym_bit] == 1'b1)
            begin
                BI_DA_P_tx <= !BI_DA_P_tx;
                BI_DA_N_tx <= !BI_DA_N_tx;
            end
            if(tx_sym_bit < 4)
            begin
                #(base_t1s.mod_inst_147_3_2_timer.symb_timer.timer_duration/10);
                BI_DA_P_tx <= !BI_DA_P_tx;
                BI_DA_N_tx <= !BI_DA_N_tx;
            end
        end                
        tx_sym_bit <= 0;
    end
end 


reg  tx_activity;

always @(BI_DA_P_tx, BI_DA_N_tx)
begin
    if(BI_DA_P_tx === !BI_DA_N_tx)
    begin
        tx_activity = TRUE;
    end
    else
    begin
        tx_activity = FALSE;
    end
end

diff_delay_element   #(.delay_value_max(TX_EN_TX_ER_sampled_to_MDI_output_max), 
                       .delay_value_min(TX_EN_TX_ER_sampled_to_MDI_output_min)
                      )
delay_element_tx      (.delay_element_input_P(BI_DA_P_tx),
                       .delay_element_input_N(BI_DA_N_tx),

                      .delay_element_output_P(BI_DA_P_tx_out),
                      .delay_element_output_N(BI_DA_N_tx_out),

                      .delay_type(delay_type)
                      );

/*                                                                    */
/* Note that there is  an inherent 3 symbol time dealy in the PCS due */
/* to  the  use  of  Rxn-1  through Rxn-3 in Figure 147–7 PCS Receive */
/* state diagram, minus the 3/20 of a symbol time due to the sampling */
/* point, equal to 57/20 * symbol time = 57/20 * 400 = 1140 ns.       */
/*                                                                    */

diff_delay_element   #(.delay_value_max(MDI_input_to_RX_DV_asserted_max - 1_120), 
                       .delay_value_min(MDI_input_to_RX_DV_asserted_min - 1_120)
                      )
delay_element_rx      (.delay_element_input_P(BI_DA_P_rx_in),
                       .delay_element_input_N(BI_DA_N_rx_in),

                      .delay_element_output_P(BI_DA_P_rx),
                      .delay_element_output_N(BI_DA_N_rx),

                      .delay_type(delay_type)
                      );

reg  rx_activity;
wire rx_manchester;

always @(BI_DA_P_rx, BI_DA_N_rx)
begin
    if(BI_DA_P_rx === !BI_DA_N_rx)
    begin
        rx_activity = TRUE;
    end
    else
    begin
        rx_activity = FALSE;
    end
end

assign rx_manchester = rx_activity && BI_DA_P_rx;

reg  rx_manchester_n_1;
reg[2:0] rx_sym_bit;
reg[4:0] rx_sym_sipo;
reg[4:0] rx_sym;
reg      RX_CLK;

always @(posedge rx_activity)
begin
    rx_sym_bit = 0;
end

event recv_symb_conv_timer_done;

always @(rx_manchester)
begin
    rx_manchester_n_1 = rx_manchester;
    #((base_t1s.mod_inst_147_3_2_timer.symb_timer.timer_duration * 3)/20);
    if(rx_manchester_n_1 == rx_manchester)
    begin
       rx_sym_sipo[rx_sym_bit] = 1'b0;
    end
    else
    begin
       rx_sym_sipo[rx_sym_bit] = 1'b1;
    end
    if(rx_sym_bit == 4)
    begin
        rx_sym = rx_sym_sipo;
        RSCD_147_7 = TRUE;
        -> recv_symb_conv_timer_done;
        RX_CLK = FALSE;
        rx_sym_bit = 0;
    end
    else
    begin
        rx_sym_bit = rx_sym_bit + 1;
    end
end

initial RX_CLK = TRUE;


/*                                                                    */
/* 147.4.2 PMA Transmit function                                      */
/*                                                                    */
/* The RX_CLK is set FALSE during the last DME bit if the symbol. The */
/* sample point, where RX_CLK is set FALSE, is during the second half */
/* of the DME bit, 60 ns into the 80 ns DME bit, 20 ns before the end */
/* the the DME bit. There is also a DME encoded 0 at the  end of each */
/* transmission, see item a) of subclause 147.4.2. The means that the */
/* negedge of rx_activity, which restarts  the  free running clock is */
/* 100 ns after the RX_CLK set  to FALSE. As  a result, RX_CLK should */
/* note be set to FALSE  again  for 300 ns, or 3/4 of a  clock  cycle */
/* later.                                                             */

always @(negedge rx_activity)
begin : local_clock
    forever
    begin
        #((base_t1s.mod_inst_147_3_2_timer.symb_timer.timer_duration * 15)/20 );
        rx_sym = base_t1s.mod_inst_147_4.SILENCE;
        RSCD_147_7 = TRUE;
        -> recv_symb_conv_timer_done;
        RX_CLK = FALSE;
        #(base_t1s.mod_inst_147_3_2_timer.symb_timer.timer_duration * 0.25);
    end
end

always @(negedge RX_CLK)
begin
    #(base_t1s.mod_inst_147_3_2_timer.symb_timer.timer_duration/2);   
    RX_CLK = TRUE;
end

always @(posedge rx_activity)
begin
    disable local_clock;
end
    

/*                                                                    */
/* recv_symb_conv_timer                                               */
/*                                                                    */
/* A continuous timer which  expires when the PMA_UNITDATA.indication */
/* message is generated (see 147.2.1).                                */
/* Continuous timer: The condition  recv_symb_conv_timer_done becomes */
/* true upon timer expiration.                                        */
/* Restart time: Immediately after expiration.                        */
/* Duration: timed by the PMA_UNITDATA.indication message generation. */
/*                                                                    */
/* RSCD                                                               */
/*                                                                    */
/* Alias for recv_symb_conv_timer_done.                               */
/*                                                                    */

reg RSCD_147_7;
initial RSCD_147_7 = FALSE;

/*                                                                    */
/* RXn                                                                */
/*                                                                    */
/* The rx_sym  parameter of  the  PMA_UNITADATA.indication  primitive */
/* defined in 147.2.1.                                                */
/* The 'n' subscript denotes the  rx_sym conveyed in the  most recent */
/* recv_symb_conv_timer cycle.                                        */
/* The  'n-x'  subscript  indicates  the rx_sym conveyed  'x'  cycles */
/* behind the most recent one.                                        */
/*                                                                    */

reg[23:0] rx_sym_ASCII;
reg[4:0]  RXn;
reg[23:0] RXn_ASCII;
reg[4:0]  RXn_1;
reg[23:0] RXn_1_ASCII;
reg[4:0]  RXn_2;
reg[23:0] RXn_2_ASCII;
reg[4:0]  RXn_3;
reg[23:0] RXn_3_ASCII;

always @(posedge RX_CLK)
begin
    RXn   <= rx_sym;
    RXn_1 <= RXn;
    RXn_2 <= RXn_1;
    RXn_3 <= RXn_2;
end

always @(rx_sym) rx_sym_ASCII = FIVEB_ASCII(rx_sym);
always @(RXn) RXn_ASCII = FIVEB_ASCII(RXn);
always @(RXn_1) RXn_1_ASCII = FIVEB_ASCII(RXn_1);
always @(RXn_2) RXn_2_ASCII = FIVEB_ASCII(RXn_2);
always @(RXn_3) RXn_3_ASCII = FIVEB_ASCII(RXn_3);


/*                                                                    */
/* 147.3.6 Carrier sense                                              */
/*                                                                    */
/* When operating  in half-duplex mode,  the  10BASE-T1S  PHY  senses */
/* when the media  is busy and conveys 
this information to the MAC by */
/* asserting the signal CRS on the MII as specified in 22.2.2.11.     */
/* CRS is  generated by  mapping the PMA_CARRIER.indication (pma_crs) */
/* primitive to the MII signal CRS:                                   */
/* a) CRS shall be asserted when the pma_crs parameter is CARRIER_ON. */
/* b)  CRS  shall  be   deasserted  when  the  pma_crs  parameter  is */
/* CARRIER_OFF.                                                       */
/*                                                                    */

reg              raw_CRS;
wire             CRS;

always @(BI_DA_P_rx_in, BI_DA_N_rx_in)
begin
    if((BI_DA_P_rx_in === !BI_DA_N_rx_in) && duplex_mode == mod_inst_147_7.DUPLEX_HALF)
    begin
        raw_CRS = TRUE;
    end
    else
    begin
        raw_CRS = FALSE;
    end
end

delay_element   #(MDI_input_to_CRS_asserted_max, MDI_input_to_CRS_deasserted_min)
delay_element_CRS(
                 .delay_element_input(raw_CRS),
                 .delay_element_output(CRS),

                 .delay_type(delay_type)
                 );

/*                                                                    */
/* ACTIVE_CNT                                                         */
/*                                                                    */
/* Number  of  combined  HBs and receive packets  required  to signal */
/* pcs_status = OK.                                                   */
/* Value: integer number between 0 and 7                              */
/* Default value: 2                                                   */
/*                                                                    */

reg[3:0]         ACTIVE_CNT;
initial          ACTIVE_CNT = 2;


/*                                                                    */
/* INACTIVE_CNT                                                       */
/*                                                                    */
/* Number  of  link_hold_timer expirations  without  HBs  or  receive */
/* packets required to signal pcs_status = NOT_OK.                    */
/* Value: integer number between 0 and 7                              */
/* Default value: 5                                                   */
/*                                                                    */

reg[3:0]         INACTIVE_CNT;
initial          INACTIVE_CNT = 5;



reg              mr_autoneg_enable;
reg              an_link_good;
reg              master;


wire             COL;
wire             raw_COL;
assign           raw_COL = collision;

delay_element   #(MDI_input_to_COL_deasserted_max, MDI_input_to_COL_deasserted_min)
delay_element_COL(
                 .delay_element_input(raw_COL),
                 .delay_element_output(COL),

                 .delay_type(delay_type)
                 );


reg              loc_rcv_status;

wire             symb_timer_done;
wire             unjab_timer_done;
wire             xmit_max_timer_done;
wire             symb_timer_not_done;
wire             unjab_timer_not_done;
wire             xmit_max_timer_not_done;

wire[3:0]        mod_147_4_state;
wire             transmitting;
wire             err;
wire[4:0]        tx_sym;

wire[3:0]        mod_147_7_state;
wire             RX_DV;
wire             RX_ER;
wire[3:0]        RXD;
wire[1:0]        rx_cmd;
wire[7:0]        precnt;
wire[3:0]        null_value;

wire             hb_send_timer_done;
wire             hb_timer_done;
wire             hb_send_timer_not_done;
wire             hb_timer_not_done;

wire[3:0]        mod_147_10_state;
wire             hb_cmd;

wire             link_hold_timer_done;
wire             link_hold_timer_not_done;

wire[2:0]        mod_147_11_state;
wire             pcs_status;
wire[7:0]        cnt_h;
wire[7:0]        cnt_l;

wire             mod_147_14_state;
wire             link_status;

mod_147_3_2_timer mod_inst_147_3_2_timer(
                .symb_timer_done(symb_timer_done),
                .unjab_timer_done(unjab_timer_done),
                .xmit_max_timer_done(xmit_max_timer_done),
                .symb_timer_not_done(symb_timer_not_done),
                .unjab_timer_not_done(unjab_timer_not_done),
                .xmit_max_timer_not_done(xmit_max_timer_not_done)
                 );

mod_147_4 mod_inst_147_4(
                 .pcs_reset(pcs_reset),
                 .link_control(link_control),
                 .TX_EN(TX_EN),
                 .tx_cmd(tx_cmd),
                 .STD(STD),
                 .xmit_max_timer_not_done(xmit_max_timer_not_done),
                 .xmit_max_timer_done(xmit_max_timer_done),
                 .unjab_timer_done(unjab_timer_done),
                 .hb_cmd(hb_cmd),
                 .TXDn(TXD),
                 .TX_ER(TX_ER),

                 .mod_147_4_state(mod_147_4_state),
                 .transmitting(transmitting),
                 .err(err),
                 .tx_sym(tx_sym)
                 );

mod_147_7 mod_inst_147_7(
                 .pcs_reset(pcs_reset),
                 .transmitting(transmitting),
                 .duplex_mode(duplex_mode),
                 .link_control(link_control),
                 .RSCD(RSCD_147_7),
                 .RXn(RXn),
                 .multidrop(multidrop),
                 .fc_supported(fc_supported),
                 .RXn_2(RXn_2),
                 .RXn_1(RXn_1),
                 .RXn_3(RXn_3),

                 .mod_147_7_state(mod_147_7_state),
                 .RX_DV(RX_DV),
                 .RX_ER(RX_ER),
                 .RXD(RXD),
                 .rx_cmd(rx_cmd),
                 .precnt(precnt),
                 .null_value(null_value)
                 );

mod_147_3_7_1_timer mod_inst_147_3_7_1_timer(
                .hb_send_timer_done(hb_send_timer_done),
                .hb_timer_done(hb_timer_done),
                .hb_send_timer_not_done(hb_send_timer_not_done),
                .hb_timer_not_done(hb_timer_not_done)
                 );

mod_147_10 mod_inst_147_10(
                 .pcs_reset(pcs_reset),
                 .mr_autoneg_enable(mr_autoneg_enable),
                 .an_link_good(an_link_good),
                 .multidrop(multidrop),
                 .rx_cmd(rx_cmd),
                 .tx_cmd(tx_cmd),
                 .master(master),
                 .hb_timer_done(hb_timer_done),
                 .CRS(CRS),
                 .hb_send_timer_done(hb_send_timer_done),
                 .COL(COL),
                 .RX_DV(RX_DV),

                 .mod_147_10_state(mod_147_10_state),
                 .hb_cmd(hb_cmd)
                 );

mod_147_3_7_2_timer mod_inst_147_3_7_2_timer(
                .link_hold_timer_done(link_hold_timer_done),
                .link_hold_timer_not_done(link_hold_timer_not_done)
                 );

mod_147_11 mod_inst_147_11(
                 .pcs_reset(pcs_reset),
                 .mr_autoneg_enable(mr_autoneg_enable),
                 .an_link_good(an_link_good),
                 .multidrop(multidrop),
                 .rx_cmd(rx_cmd),
                 .RX_DV(RX_DV),
                 .CRS(CRS),
                 .link_hold_timer_done(link_hold_timer_done),
                 .INACTIVE_CNT(INACTIVE_CNT),
                 .ACTIVE_CNT(ACTIVE_CNT),

                 .mod_147_11_state(mod_147_11_state),
                 .pcs_status(pcs_status),
                 .cnt_h(cnt_h),
                 .cnt_l(cnt_l)
                 );

mod_147_14 mod_inst_147_14(
                 .pma_reset(pma_reset),
                 .link_control(link_control),
                 .pcs_status(pcs_status),
                 .loc_rcv_status(loc_rcv_status),

                 .mod_147_14_state(mod_147_14_state),
                 .link_status(link_status)
                 );


`endif

endmodule
