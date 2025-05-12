module           plca(
                 RX_CLK,
                 RXD,
                 RX_DV,
                 RX_ER,
                 CRS,
                 COL,
                 TX_CLK,

                 TXD,
                 TX_EN,
                 TX_ER
                 );

input            RX_CLK;
input[3:0]       RXD;
input            RX_DV;
input            RX_ER;
input            CRS;
input            COL;

input            TX_CLK;

output[3:0]      TXD;
output           TX_EN;
output           TX_ER;

`ifdef simulate
`include "IEEE_P802_3da_param.v"

/**********************************************************************/
/*                                                                    */
/*         PLCA Management and Configuration registers                */
/*         ===========================================                */
/*                                                                    */
/* plca_node_count                                                    */
/*                                                                    */
/* Maximum  number of  PLCA nodes  on  the  mixing  segment receiving */
/* transmit  opportunities  before the  node  with  local_nodeID =  0 */
/* generates  a  new  BEACON, reflecting the value of aPLCANodeCount. */
/* This parameter is meaningful only for the node  with  local_nodeID */
/* = 0; otherwise, it is ignored.                                     */
/*                                                                    */
/* Values: integer number from 0 to 255.                              */
/*                                                                    */
reg[7:0]         plca_node_count;
/*                                                                    */
/* local_nodeID                                                       */
/*                                                                    */
/* ID representing the  PLCA transmit opportunity number  assigned to */
/* the node. This signal maps to aPLCALocalNodeID.                    */
/*                                                                    */
reg[7:0]         local_nodeID;
/*                                                                    */
/* max_bc                                                             */
/*                                                                    */
/* Maximum  number  of  additional packets  the  node  is  allowed to */
/* transmit  in   a       single  burst.   This    signal  maps    to */
/* aPLCAMaxBurstCount attribute                                       */
/*                                                                    */
reg[7:0]         max_bc;
/*                                                                    */
/* plca_reset                                                         */
/*                                                                    */
/* The plca_reset signal is used to reset  the optional PLCA function */
/* in  the RS.  This signal maps to TRUE when acPLCAReset is in reset */
/* and to FALSE when acPLCAReset is normal, but is further qualified. */
/*                                                                    */
/* Values: TRUE or FALSE                                              */
/*                                                                    */
reg              plca_reset;
/*                                                                    */
/* plca_en                                                            */
/*                                                                    */
/* The plca_en signal  controls the optional PLCA function in the RS. */
/* This  signal maps to TRUE when  aPLCAAdminState is  enabled and to */
/* FALSE when aPLCAAdminState is disabled.                            */
/*                                                                    */
/* Values: TRUE or FALSE                                              */
/*                                                                    */
reg              plca_en;
/*                                                                    */
/* dplca_en                                                           */
/*                                                                    */
/* The dplca_en signal  controls  the  optional D-PLCA function. This */
/* signal maps to TRUE when aDPLCAAdminState is enabled  and to FALSE */
/* when aDPLCAAdminState is disabled.                                 */
/*                                                                    */
reg              dplca_en;
/*                                                                    */
/* coordinator_role_allowed                                           */
/*                                                                    */
/* This  variable controls whether the local  node is allowed to take */
/* the coordinator role  (local_nodeID =  0) during the  D-PLCA  node */
/* assignment       procedure.     This   variable   maps   on    the */
/* aDPLCACoordinatorRoleAllowed attribute in 30.16.1.1.10.            */
/*                                                                    */
/* Values: TRUE or FALSE                                              */
/*                                                                    */
reg              coordinator_role_allowed;
/*                                                                    */
/* aging_cycles                                                       */
/*                                                                    */
/* Defines the number  of BEACON cycles  before transmit opportunity  */
/* expire.  This  variable  maps  to  the aDPLCAHardAgingCycles       */
/* attribute defined in 30.16.1.1.9.                                  */
/*                                                                    */
reg[15:0]        aging_cycles;
/*                                                                    */
/**********************************************************************/

/*                                                                    */
/* txop_claim_table                                                   */
/*                                                                    */
/* This variable  contains  the  claim  state  of  the  256  transmit */
/* opportunities IDs. The claim state of each ID can be:              */
/* UNCLAIMED, meaning that the transmit opportunity ID is available   */
/* to be returned by the pick_free_txop function.                     */
/* CLAIMED, meaning  the ID  is currently claimed by a node           */
/* packet transmission.                                               */
/* The  transmit opportunity table is maintained by  the D-PLCA aging */
/* state diagram defined in Figure 148-9.                             */
/*                                                                    */
/* Values: Array of 256 elements,  each having a value of UNCLAIMED   */
/* or CLAIMED.                                                        */
/*                                                                    */

reg [1:0] txop_claim_table [255:0];


/*                                                                    */
/* txop_claim_table_new                                               */
/*                                                                    */
/* Copy  of txop_claim_table  used by the D-PLCA Aging  State Diagram */
/* to handle the expiration of claims.                                */
/* Values: same as txop_claim_table.                                  */
/*                                                                    */

reg[1:0] txop_claim_table_new [255:0];

event transition;
reg[1:0] temp;
always @(posedge dplca_txop_end)
begin
    -> transition;
    temp = dplca_txop_claim;
end


/*                                                                    */
/* rx_cmd                                                             */
/*                                                                    */
/* Encoding  present  on  RXD<3:0>,  RX_ER, and RX_DV  as  defined in */
/* Table 22-2.                                                        */
/*                                                                    */
/* BEACON:  PLCA  BEACON  indication  encoding  present on  RXD<3:0>, */
/* RX_ER, and RX_DV                                                   */
/* COMMIT:  PLCA  COMMIT  indication  encoding present  on  RXD<3:0>, */
/* RX_ER, and RX_DV                                                   */
/* NONE:  PLCA  BEACON  or COMMIT  indication encoding not present on */
/* RXD<3:0>, RX_ER, and RX_DV                                         */
/*                                                                    */
/*   +-------+-------+-------------------+------------------------+   */
/*   | RX_DV | RX_ER |     RXD<3:0>      |  Indication            |   */
/*   +-------+-------+-------------------+------------------------+   */
/*   |   0   |   1   |       0010        | PLCA BEACON indication |   */
/*   +-------+-------+-------------------+------------------------+   */
/*   |   0   |   1   |       0011        | PLCA COMMIT indication |   */
/*   +-------+-------+-------------------+------------------------+   */
/*   |   0   |   1   | 0100 through 1101 | Reserved               |   */
/*   +-------+-------+-------------------+------------------------+   */
/*                                                                    */

reg[1:0] rx_cmd;

always @(RX_CLK)
begin
    case({RX_DV, RX_ER, RXD})

    6'b010010: rx_cmd = mod_inst_148_3.BEACON;
    6'b010011: rx_cmd = mod_inst_148_3.COMMIT;
    default:   rx_cmd = mod_inst_148_3.NONE;

    endcase
end

reg [103:0]       rx_cmd_ASCII;

always@(rx_cmd)
begin
    casex(rx_cmd)
        2'b00  : rx_cmd_ASCII = "BEACON";
        2'b01  : rx_cmd_ASCII = "COMMIT";
        2'b10  : rx_cmd_ASCII = "NONE";
        default: rx_cmd_ASCII = "XXXX";
    endcase
    if( rx_cmd == 2'b00)
    begin
        -> plca.mod_inst_148_4_4_timer.invalid_beacon_timer.stop;
    end
end

/*                                                                    */
/* 148.4.3.2 Mapping of PLS_DATA.indication                           */
/*                                                                    */
/* 22.2.1.2.2 Semantics of the service primitive                      */
/*                                                                    */
/* PLS_DATA.indication (INPUT_UNIT)                                   */
/*                                                                    */
/* The INPUT_UNIT parameter can take one of  two values: ONE or ZERO. */
/* It  represents a  single data  bit.  The values  ONE and ZERO  are */
/* derived from the signals RXD<3>,  RXD<2>, RXD<1>, and RXD<0>, each */
/* of which represents one bit of data while RX_DV is asserted.       */
/*                                                                    */

reg[2:0] rx_bit_count;

always @(posedge RX_CLK)
begin

    #5;

    rx_bit_count  = 3'b000;

    if(true) // (RX_DV == true)
    begin
        while(rx_bit_count <= 3)
        begin
            if(RXD[rx_bit_count] == 1'b0 || receive_error)
            begin
                `PLS.INPUT_UNIT = `PLS.ZERO;
            end
            else
            begin
                `PLS.INPUT_UNIT = `PLS.ONE;
            end

        -> `PLS.PLS_DATA_indication;
        #1 rx_bit_count = rx_bit_count + 1;

        end
    end
end

/*                                                                    */
/* 22.2.1.5 Response to RX_ER indication from MII                     */
/*                                                                    */
/* If, during frame reception,  both  RX_DV  and RX_ER are  asserted, */
/* the Reconciliation  sublayer shall ensure that the MAC will detect */
/* a FrameCheckError in that frame.                                   */
/*                                                                    */

reg receive_error;

always @(negedge RX_CLK)
begin
    if(!RX_DV)
    begin
        receive_error = false;
    end
    if(RX_DV && RX_ER)
    begin
        receive_error = true;
    end
end

/*                                                                    */
/* 148.4.3.1.2 Semantic of the service primitive                      */
/*                                                                    */
/* PLS_DATA.request (OUTPUT_UNIT)                                     */
/*                                                                    */
/* The  OUTPUT_UNIT parameter  can take  one  of  three values:  ONE, */
/* ZERO,  or DATA_COMPLETE.  It  represents  a single data  bit.  The */
/* values ONE and ZERO are  conveyed  by the  individual bits of  the */
/* four-bit  variable   plca_txd<3:0>.  Each   bit  of  plca_txd<3:0> */
/* conveys one bit of  data while plca_txen is set to TRUE. The value */
/* DATA_COMPLETE is  conveyed by setting  the  variable plca_txen  to */
/* FALSE. MII signals TXD<3:0> and TX_EN are generated  by way of the */
/* PLCA  DATA state  diagrams specified  in  148.4.6. Synchronization */
/* between the  RS  and  the  PHY  is  achieved by way  of the TX_CLK */
/* signal.                                                            */
/*                                                                    */
/* 148.4.3.1.3 When generated                                         */
/*                                                                    */
/* The plca_txd<3:0>  and  plca_txen  variables  are  assigned  after */
/* every group of  four  PLS_DATA.request transactions from  the  MAC */
/* sublayer to  request the PLCA  functions  to transmit a  nibble of */
/* data when  the transmit opportunity is met,  or to  signal the end */
/* of  the  transmission. The TX_CLK signal is generated  by the PHY. */
/* The TXD<3:0> and TX_EN signals are  generated  by the RS according */
/* to PLCA DATA state diagrams (see 148.4.6).                         */
/*                                                                    */

reg[3:0]         plca_txd;
reg              plca_txen;
reg              plca_txer;

reg[2:0]         tx_bit_count;
reg[3:0]         txen_array;
reg[3:0]         txd_array;

initial
begin
    plca_txd   = 4'h0;
    plca_txen = false;
    plca_txer = false;
end

always @(`PLS.PLS_DATA_request)
begin

    if(plca_txen == false || tx_bit_count == 3'b100)
    begin
        tx_bit_count = 3'b000;
        @(posedge TX_CLK);
    end

    if(`PLS.OUTPUT_UNIT == `PLS.DATA_COMPLETE)
    begin

        #2.5 plca_txen = false;
        plca_txd[tx_bit_count] = 1'bx;
        
    end

    else if(`PLS.OUTPUT_UNIT == `PLS.ONE || `PLS.OUTPUT_UNIT == `PLS.ZERO)
    begin

        #2.5 plca_txen = true;

        if(`PLS.OUTPUT_UNIT == `PLS.ZERO)
        begin
            plca_txd[tx_bit_count] = 1'b0;
        end

        else if(`PLS.OUTPUT_UNIT == `PLS.ONE)
        begin
            plca_txd[tx_bit_count] = 1'b1;
        end

        tx_bit_count = tx_bit_count + 3'b001;

    end

    else
    begin
        plca_txd[tx_bit_count] = 1'bx;
        tx_bit_count = tx_bit_count + 3'b001;
    end

    -> `PLS.PLS_DATA_request_serviced;

end


/*                                                                    */
/* 148.4.3.3.2 Semantic of the service primitive                      */
/*                                                                    */
/* PLS_CARRIER.indication (CARRIER_STATUS)                            */
/*                                                                    */
/* The  CARRIER_STATUS  parameter  can   take  one  of  two   values: */
/* CARRIER_ON or CARRIER_OFF.  For EEE capability, CARRIER_STATUS  is */
/* overridden as specified in 22.2.1.3.3.                             */
/*                                                                    */

always @(CARRIER_STATUS)
begin
    `PLS.CARRIER_STATUS = CARRIER_STATUS;
    -> `PLS.PLS_CARRIER_indication;
end

/*                                                                    */
/* 148.4.3.4.2 Semantic of the service primitive                      */
/*                                                                    */
/* PLS_SIGNAL.indication (SIGNAL_STATUS)                              */
/*                                                                    */
/* The   SIGNAL_STATUS   parameter  can   take  one  of  two  values: */
/* SIGNAL_ERROR or NO_SIGNAL_ERROR.                                   */
/*                                                                    */

always @(SIGNAL_STATUS)
begin
    `PLS.SIGNAL_STATUS = SIGNAL_STATUS;
    -> `PLS.PLS_SIGNAL_indication;
end


/*                                                                    */
/* 148.4.3.5 Mapping of PLS_DATA_VALID.indication                     */
/*                                                                    */
/* Map  of the primitive  PLS_DATA_VALID.indication shall comply with */
/* 22.2.1.7.                                                          */
/*                                                                    */
/* 22.2.1.7.2 Semantics of the service primitive                      */
/*                                                                    */
/* PLS_DATA_VALID.indication (DATA_VALID_STATUS)                      */
/*                                                                    */
/* The  DATA_VALID_STATUS  parameter  can  take  one  of two  values: */
/* DATA_VALID or DATA_NOT_VALID. DATA_VALID_STATUS  assumes the value */
/* DATA_VALID when the MII signal RX_DV  is asserted, and assumes the */
/* value DATA_NOT_VALID when RX_DV is deasserted.                     */
/*                                                                    */

parameter DATA_NOT_VALID = 1'b0;
parameter DATA_VALID     = 1'b1;

always @(RX_DV)
begin
    if(RX_DV)
    begin
        `PLS.DATA_VALID_STATUS = DATA_VALID;
    end
    else
    begin
        `PLS.DATA_VALID_STATUS = DATA_NOT_VALID;
    end
    -> `PLS.PLS_DATA_VALID_indication;
end        

/*                                                                    */
/* mii_clock_timer                                                    */
/*                                                                    */
/* A continuous free-running timer that  shall  expire  synchronously */
/* with the rising edge of the MII TX_CLK.                            */
/* Restart time: Immediately  after  expiration; restarting the timer */
/* resets the condition mii_clock_timer_done.                         */
/* Duration: see 22.2.2.1.                                            */
/*                                                                    */
/* MCD                                                                */
/*                                                                    */
/* Alias for mii_clock_timer_done.                                    */
/*                                                                    */

reg MCD;

initial MCD = false;

always @(posedge TX_CLK)
begin
    MCD <= true;
    #0.1 MCD <= false;
end

/*                                                                    */
/* PMCD                                                               */
/*                                                                    */
/* Prescient mii_clock_timer_done. This variable  is  set to FALSE on */
/* entry to the RESYNC state  and becomes TRUE 1 ± ½ bit  time  prior */
/* to mii_clock_timer_done becoming TRUE.                             */
/*                                                                    */

reg PMCD;

initial PMCD = false;

always@(mod_inst_148_3.next_mod_148_3_state)
begin
    if(mod_inst_148_3.next_mod_148_3_state == mod_inst_148_3.RESYNC)
    begin
        PMCD <= false;
    end
end

always @(negedge TX_CLK)
begin
    #150;
    PMCD <= true;
end


/*                                                                    */
/* delay_line_length                                                  */
/*                                                                    */
/* This  constant  is  implementation  dependent  and  specifies  the */
/* maximum length  of the  PLCA  RS  variable delay line  depicted in */
/* Figure 148–2.                                                      */
/*                                                                    */
/* Value: up to 396 bit times.                                        */
/*                                                                    */

reg[7:0] delay_line_length;
initial delay_line_length = 9'd99;  // Compared to 'a' which is a nible count


/* The  variable   delay  line  is  a  small  buffer  that  aligns  a */
/* transmission  with the transmit  opportunity.  The variable  delay */
/* line length  is no  greater  than  to_timer  ×  plca_node_count  + */
/* beacon_timer.                                                      */

reg[3:0] delay_line[511:0];
reg[8:0] n;
reg[8:0] n_a;

initial n = 0;

always @(posedge TX_CLK) n = n + 1;
always @(n or plca_txd or posedge TX_CLK) delay_line[n] = plca_txd;
always @(n or a) n_a = n - a;

wire[3:0] plca_txdn_a = delay_line[n_a];


/*                                                                    */
/* receiving                                                          */
/*                                                                    */
/* Defined as: (RX_DV = TRUE) + (rx_cmd = COMMIT).                    */
/* Values: TRUE or FALSE                                              */
/*                                                                    */

wire             receiving = (RX_DV || (rx_cmd == mod_inst_148_3.COMMIT)) ? TRUE : FALSE;


/*                                                                    */
/* 22.3.1 Signals that are synchronous to TX_CLK                      */
/*                                                                    */

parameter  TX_CLK_setup = 375;

posedge_setup #(TX_CLK_setup) TXD0_setup(.clock(TX_CLK), .data(TXD[0]));
posedge_setup #(TX_CLK_setup) TXD1_setup(.clock(TX_CLK), .data(TXD[1]));
posedge_setup #(TX_CLK_setup) TXD2_setup(.clock(TX_CLK), .data(TXD[2]));
posedge_setup #(TX_CLK_setup) TXD3_setup(.clock(TX_CLK), .data(TXD[3]));
posedge_setup #(TX_CLK_setup) TX_EN_setup(.clock(TX_CLK), .data(TX_EN));
posedge_setup #(TX_CLK_setup) TX_ER_setup(.clock(TX_CLK), .data(TX_ER));


reg[1:0] tx_cmd_sync;

always @(posedge TX_CLK)  // Fix
begin                     
    tx_cmd_sync = tx_cmd; 
end                       


reg [31:0]       plca_status_ASCII;

always@(plca_status)
begin
    casex(plca_status)
        2'b00   : plca_status_ASCII = "FAIL";
        2'b01   : plca_status_ASCII = " OK ";
        default : plca_status_ASCII = "XXXX";
    endcase
end

reg [47:0]       tx_cmd_sync_ASCII;

always@(tx_cmd_sync)
begin
    casex(tx_cmd_sync)
        2'b00   : tx_cmd_sync_ASCII = "BEACON";
        2'b01   : tx_cmd_sync_ASCII = "COMMIT";
        2'b10   : tx_cmd_sync_ASCII = " NONE ";
        default : tx_cmd_sync_ASCII = " XXXX ";
    endcase
end


wire             beacon_timer_done;
wire             beacon_det_timer_done;
wire             invalid_beacon_timer_done;
wire             burst_timer_done;
wire             to_timer_done;
wire             beacon_timer_not_done;
wire             beacon_det_timer_not_done;
wire             invalid_beacon_timer_not_done;
wire             burst_timer_not_done;
wire             to_timer_not_done;

wire[3:0]        mod_148_3_state;
wire[1:0]        tx_cmd;
wire             committed;
wire[7:0]        curID;
wire             plca_active;
wire[1:0]        dplca_txop_claim;
wire             dplca_txop_end;
wire[7:0]        dplca_txop_id;
wire[7:0]        dplca_txop_node_count;
wire[7:0]        bc;


wire             commit_timer_done;
wire             mii_clock_timer_done;
wire             pending_timer_done;
wire             commit_timer_not_done;
wire             mii_clock_timer_not_done;
wire             pending_timer_not_done;

wire[3:0]        mod_148_5_state;
wire             packetPending;
wire             CARRIER_STATUS;
wire[3:0]        TXD;
wire             TX_EN;
wire             TX_ER;
wire             SIGNAL_STATUS;
wire[6:0]        a;
wire[6:0]        b;


wire             plca_status_timer_done;
wire             plca_status_timer_not_done;

wire[1:0]        mod_148_7_state;
wire             plca_status;


mod_148_4_4_timer mod_inst_148_4_4_timer(
                .beacon_timer_done(beacon_timer_done),
                .beacon_det_timer_done(beacon_det_timer_done),
                .invalid_beacon_timer_done(invalid_beacon_timer_done),
                .burst_timer_done(burst_timer_done),
                .to_timer_done(to_timer_done),
                .beacon_timer_not_done(beacon_timer_not_done),
                .beacon_det_timer_not_done(beacon_det_timer_not_done),
                .invalid_beacon_timer_not_done(invalid_beacon_timer_not_done),
                .burst_timer_not_done(burst_timer_not_done),
                .to_timer_not_done(to_timer_not_done)
                 );

mod_148_3 mod_inst_148_3(
                 .plca_reset(plca_reset),
                 .plca_en(plca_en),
                 .local_nodeID(local_nodeID),
                 .dplca_en(dplca_en),
                 .PMCD(PMCD),
                 .CRS(CRS),
                 .TX_EN(TX_EN),
                 .beacon_timer_done(beacon_timer_done),
                 .packetPending(packetPending),
                 .to_timer_done(to_timer_done),
                 .rx_cmd(rx_cmd),
                 .beacon_det_timer_done(beacon_det_timer_done),
                 .receiving(receiving),
                 .beacon_det_timer_not_done(beacon_det_timer_not_done),
                 .COL(COL),
                 .to_timer_not_done(to_timer_not_done),
                 .max_bc(max_bc),
                 .burst_timer_done(burst_timer_done),
                 .invalid_beacon_timer_done(invalid_beacon_timer_done),
                 .plca_node_count(plca_node_count),
                 .dplca_txop_table_upd(dplca_txop_table_upd),
                 .dplca_aging(dplca_aging),

                 .mod_148_3_state(mod_148_3_state),
                 .tx_cmd(tx_cmd),
                 .committed(committed),
                 .curID(curID),
                 .plca_active(plca_active),
                 .dplca_txop_claim(dplca_txop_claim),
                 .dplca_txop_end(dplca_txop_end),
                 .dplca_txop_id(dplca_txop_id),
                 .dplca_txop_node_count(dplca_txop_node_count),
                 .bc(bc)
                 );


mod_148_4_5_func mod_inst_148_4_5_func();

mod_148_4_5_timer mod_inst_148_4_5_timer(
                .commit_timer_done(commit_timer_done),
                .mii_clock_timer_done(mii_clock_timer_done),
                .pending_timer_done(pending_timer_done),
                .commit_timer_not_done(commit_timer_not_done),
                .mii_clock_timer_not_done(mii_clock_timer_not_done),
                .pending_timer_not_done(pending_timer_not_done)
                 );

mod_148_5 mod_inst_148_5(
                 .plca_reset(plca_reset),
                 .plca_en(plca_en),
                 .plca_status(plca_status),
                 .CRS(CRS),
                 .committed(committed),
                 .MCD(MCD),
                 .local_nodeID(local_nodeID),
                 .plca_txen(plca_txen),
                 .receiving(receiving),
                 .tx_cmd(tx_cmd),
                 .plca_txer(plca_txer),
                 .pending_timer_done(pending_timer_done),
                 .commit_timer_done(commit_timer_done),
                 .delay_line_length(delay_line_length),
                 .plca_txd(plca_txd),
                 .plca_txdn_a(plca_txdn_a),
                 .COL(COL),
                 .rx_cmd(rx_cmd),
                 .tx_cmd_sync(tx_cmd_sync),

                 .mod_148_5_state(mod_148_5_state),
                 .packetPending(packetPending),
                 .CARRIER_STATUS(CARRIER_STATUS),
                 .TXD(TXD),
                 .TX_EN(TX_EN),
                 .TX_ER(TX_ER),
                 .SIGNAL_STATUS(SIGNAL_STATUS),
                 .a(a),
                 .b(b)
                 );



mod_148_4_6_timer mod_inst_148_4_6_timer(
                .plca_status_timer_done(plca_status_timer_done),
                .plca_status_timer_not_done(plca_status_timer_not_done)
                 );

mod_148_7 mod_inst_148_7(
                 .plca_reset(plca_reset),
                 .plca_en(plca_en),
                 .plca_active(plca_active),
                 .plca_status_timer_done(plca_status_timer_done),

                 .mod_148_7_state(mod_148_7_state),
                 .plca_status(plca_status)
                 );


mod_148_4_7_func mod_inst_148_4_7_func();

mod_148_4_7_timer mod_inst_148_4_7_timer(
                .wait_beacon_timer_done(wait_beacon_timer_done),
                .wait_beacon_timer_not_done(wait_beacon_timer_not_done)
                 );

wire[3:0]        mod_148_8_state;
wire             dplca_aging;

mod_148_8 mod_inst_148_8(
                 .plca_reset(plca_reset),
                 .dplca_en(dplca_en),
                 .plca_en(plca_en),
                 .wait_beacon_timer_done(wait_beacon_timer_done),
                 .coordinator_role_allowed(coordinator_role_allowed),
                 .plca_status(plca_status),
                 .rx_cmd(rx_cmd),
                 .tx_cmd(tx_cmd),
                 .dplca_txop_table_upd(dplca_txop_table_upd),
                 .dplca_new_age(dplca_new_age),
                 .dplca_txop_id(dplca_txop_id),
                 .dplca_txop_node_count(dplca_txop_node_count),
                 .txop_claim_table_unpacked(txop_claim_table_unpacked),

                 .mod_148_8_state(mod_148_8_state),
                 .dplca_aging(dplca_aging),
                 .local_nodeID(local_nodeID),
                 .plca_node_count(plca_node_count)
                 );


wire[2:0]        mod_148_9_state;
wire[15:0]       aging_cnt;
wire             dplca_new_age;
wire             dplca_txop_table_upd;

/*                                                                    */
/* Unpack multidimensional arrays                                     */
/* Verilog does not support the  use  of  multidimensional arrays  in */
/* module  ports. As a result, unpack the multidimensional array into */
/* a vector and use  this  as  a module port. The vector must then be */
/* packed back into an array after passing through the port.          */
/*                                                                    */

/*                                                                    */
/* Unpack txop_claim_table                                            */
/*                                                                    */

wire [511:0] txop_claim_table_unpacked;

genvar txop_claim_table_index;
generate for (txop_claim_table_index = 0; txop_claim_table_index < 256; txop_claim_table_index = txop_claim_table_index + 1)
begin : txop_claim_table_unpack
    reg[71:0] ASCII;
    wire[1:0] txop_claim_table_location;
    assign txop_claim_table_location = txop_claim_table[txop_claim_table_index];
    assign txop_claim_table_unpacked[((txop_claim_table_index + 1) * 2) - 1 : (txop_claim_table_index * 2)] = txop_claim_table[txop_claim_table_index];

    always@(txop_claim_table_location)
    begin
        casex(txop_claim_table_location)
            RS.mod_inst_148_8.UNCLAIMED : ASCII = "UNCLAIMED";
            RS.mod_inst_148_8.CLAIMED   : ASCII = "CLAIMED";
            default :                     ASCII = "XXXX ";
        endcase
    end

end
endgenerate

/*                                                                    */
/* Unpack txop_claim_table_new                                        */
/*                                                                    */

wire [511:0] txop_claim_table_new_unpacked;

genvar txop_claim_table_new_index;
generate for (txop_claim_table_new_index = 0; txop_claim_table_new_index < 256; txop_claim_table_new_index = txop_claim_table_new_index + 1)
begin : txop_claim_table_new_unpack
    reg[71:0] ASCII;
    wire[1:0] txop_claim_table_new_location;
    assign txop_claim_table_new_location = txop_claim_table_new[txop_claim_table_new_index];
    assign txop_claim_table_new_unpacked[((txop_claim_table_new_index + 1) * 2) - 1 : (txop_claim_table_new_index * 2)] = txop_claim_table_new[txop_claim_table_new_index];

    always@(txop_claim_table_new_location)
    begin
        casex(txop_claim_table_new_location)
            RS.mod_inst_148_8.UNCLAIMED : ASCII = "UNCLAIMED";
            RS.mod_inst_148_8.CLAIMED   : ASCII = "CLAIMED";
            default :                     ASCII = "XXXX ";
        endcase
    end

end
endgenerate


mod_148_9 mod_inst_148_9(
                 .dplca_aging(dplca_aging),
                 .dplca_txop_end(dplca_txop_end),
                 .dplca_txop_claim(dplca_txop_claim),
                 .txop_claim_table_unpacked(txop_claim_table_unpacked),
                 .txop_claim_table_new_unpacked(txop_claim_table_new_unpacked),
                 .dplca_txop_id(dplca_txop_id),
                 .aging_cycles(aging_cycles),

                 .mod_148_9_state(mod_148_9_state),
                 .aging_cnt(aging_cnt),
                 .dplca_new_age(dplca_new_age),
                 .dplca_txop_table_upd(dplca_txop_table_upd)
                 );



`endif


endmodule

