/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_3.v                                         */
/*        Date:   09/04/2025                                          */
/*                                                                    */
/**********************************************************************/

module           mod_148_3(

                 plca_reset,
                 plca_en,
                 local_nodeID,
                 dplca_en,
                 invalid_beacon_timer_done,
                 PMCD,
                 CRS,
                 TX_EN,
                 beacon_timer_done,
                 packetPending,
                 to_timer_done,
                 rx_cmd,
                 beacon_det_timer_done,
                 receiving,
                 beacon_det_timer_not_done,
                 COL,
                 to_timer_not_done,
                 max_bc,
                 burst_timer_done,
                 append_commit_timer_done,
                 dplca_txop_table_upd,
                 dplca_aging,
                 plca_node_count,

                 mod_148_3_state,
                 tx_cmd,
                 committed,
                 curID,
                 plca_active,
                 dplca_txop_claim,
                 dplca_txop_end,
                 dplca_txop_id,
                 dplca_txop_node_count,
                 bc,
                 plca_tx_beacon
                 );

input            plca_reset;
input            plca_en;
input[7:0]       local_nodeID;
input            dplca_en;
input            invalid_beacon_timer_done;
input            PMCD;
input            CRS;
input            TX_EN;
input            beacon_timer_done;
input            packetPending;
input            to_timer_done;
input[1:0]       rx_cmd;
input            beacon_det_timer_done;
input            receiving;
input            beacon_det_timer_not_done;
input            COL;
input            to_timer_not_done;
input[7:0]       max_bc;
input            burst_timer_done;
input            append_commit_timer_done;
input            dplca_txop_table_upd;
input            dplca_aging;
input[7:0]       plca_node_count;

output[3:0]      mod_148_3_state;
output[1:0]      tx_cmd;
output           committed;
output[7:0]      curID;
output           plca_active;
output[1:0]      dplca_txop_claim;
output           dplca_txop_end;
output[7:0]      dplca_txop_id;
output[7:0]      dplca_txop_node_count;
output[7:0]      bc;
output           plca_tx_beacon;

reg[3:0]         mod_148_3_state;
reg[3:0]         next_mod_148_3_state;
reg[1:0]         tx_cmd;
reg              committed;
reg[7:0]         curID;
reg              plca_active;
reg[1:0]         dplca_txop_claim;
reg              dplca_txop_end;
reg[7:0]         dplca_txop_id;
reg[7:0]         dplca_txop_node_count;
reg[7:0]         bc;
reg              plca_tx_beacon;

`ifdef simulate
`include "IEEE_P802_3da_param.v"
`include "mod_148_4_4_param.v"

parameter        DISABLE             =  4'b0000;
parameter        RESYNC              =  4'b0001;
parameter        RECOVER             =  4'b0010;
parameter        SEND_BEACON         =  4'b0011;
parameter        SYNCING             =  4'b0100;
parameter        WAIT_TO             =  4'b0101;
parameter        EARLY_RECEIVE       =  4'b0110;
parameter        COMMIT_STATE        =  4'b0111;
parameter        YIELD               =  4'b1000;
parameter        RECEIVE             =  4'b1001;
parameter        TRANSMIT            =  4'b1010;
parameter        BURST               =  4'b1011;
parameter        NEXT_TX_OPPORTUNITY =  4'b1100;
parameter        ABORT               =  4'b1101;

/*                                                                    */
/* IEEE 802.3 state diagram operation                                 */
/* The actions inside a  state block execute instantaneously. Actions */
/* inside  state  blocks  are  atomic (i.e., uninterruptible).  After */
/* performing all the actions listed in a  state  block one time, the */
/* state block then continuously evaluates its  exit conditions until */
/* one  is  satisfied,  at  which  point  control  passes  through  a */
/* transition  arrow  to  the  next  block.  While  the  state awaits */
/* fulfilment  of  one of  its exit conditions, the actions inside do */
/* not implicitly repeat.                                             */
/*                                                                    */
 
/*                                                                    */
/* State diagram next state                                           */
/* Non-blocking assignment of next state based on  current state  and */
/* inputs.                                                            */
/*                                                                    */

always@(mod_148_3_state, plca_reset, plca_en, local_nodeID, dplca_en, invalid_beacon_timer_done, PMCD, CRS, TX_EN, beacon_timer_done, packetPending, to_timer_done, rx_cmd, beacon_det_timer_done, receiving, beacon_det_timer_not_done, COL, to_timer_not_done, max_bc, burst_timer_done, append_commit_timer_done, dplca_txop_table_upd, dplca_aging, plca_node_count)

begin

    next_mod_148_3_state <= mod_148_3_state;

    if(plca_reset || (!plca_en) || (local_nodeID == 255) && (!dplca_en))
    begin
        next_mod_148_3_state <= !DISABLE;
        next_mod_148_3_state <= DISABLE;
    end
    else if(invalid_beacon_timer_done)
    begin
        next_mod_148_3_state <= !RESYNC;
        next_mod_148_3_state <= RESYNC;
    end

    else
    begin

    case(mod_148_3_state)

    DISABLE:
    begin
        if(plca_en && (local_nodeID != 0) && ( (local_nodeID != 255) || dplca_en ))
        begin
            next_mod_148_3_state <= RESYNC;
        end
        if(plca_en && (local_nodeID == 0))
        begin
            next_mod_148_3_state <= RECOVER;
        end
    end

    RESYNC:
    begin
        if(PMCD && (!CRS) && (!TX_EN) && (local_nodeID == 0))
        begin
            next_mod_148_3_state <= SEND_BEACON;
        end
        if((local_nodeID != 0) && CRS)
        begin
            next_mod_148_3_state <= EARLY_RECEIVE;
        end
    end

    RECOVER:
    begin
        begin
            next_mod_148_3_state <= WAIT_TO;
        end
    end

    SEND_BEACON:
    begin
        if(beacon_timer_done)
        begin
            next_mod_148_3_state <= SYNCING;
        end
    end

    SYNCING:
    begin
        if(!CRS)
        begin
            next_mod_148_3_state <= WAIT_TO;
        end
    end

    WAIT_TO:
    begin
        if(CRS)
        begin
            next_mod_148_3_state <= EARLY_RECEIVE;
        end
        if(plca_active && (curID == local_nodeID) && packetPending && (!CRS))
        begin
            next_mod_148_3_state <= COMMIT_STATE;
        end
        if((curID == local_nodeID) && ((!packetPending) || (!plca_active)) && (!CRS))
        begin
            next_mod_148_3_state <= YIELD;
        end
        if(to_timer_done && (curID != local_nodeID) && (!CRS))
        begin
            next_mod_148_3_state <= NEXT_TX_OPPORTUNITY;
        end
    end

    EARLY_RECEIVE:
    begin
        if((!CRS) && (local_nodeID != 0) && (rx_cmd != BEACON) && beacon_det_timer_done)
        begin
            next_mod_148_3_state <= RESYNC;
        end
        if((!CRS) && (local_nodeID == 0))
        begin
            next_mod_148_3_state <= RECOVER;
        end
        if((local_nodeID != 0) && (!receiving) && ((rx_cmd == BEACON) || ((!CRS) && beacon_det_timer_not_done)))
        begin
            next_mod_148_3_state <= SYNCING;
        end
        if(receiving && CRS)
        begin
            next_mod_148_3_state <= RECEIVE;
        end
    end

    COMMIT_STATE:
    begin
        if(COL && (!TX_EN) && packetPending)
        begin
            next_mod_148_3_state <= !COMMIT_STATE;
            next_mod_148_3_state <= COMMIT_STATE;
        end
        if(TX_EN)
        begin
            next_mod_148_3_state <= TRANSMIT;
        end
        if((!TX_EN) && (!packetPending))
        begin
            next_mod_148_3_state <= ABORT;
        end
    end

    YIELD:
    begin
        if(CRS && to_timer_not_done)
        begin
            next_mod_148_3_state <= EARLY_RECEIVE;
        end
        if(to_timer_done)
        begin
            next_mod_148_3_state <= NEXT_TX_OPPORTUNITY;
        end
    end

    RECEIVE:
    begin
        if(CRS)
        begin
            next_mod_148_3_state <= !RECEIVE;
            next_mod_148_3_state <= RECEIVE;
        end
        if(!CRS)
        begin
            next_mod_148_3_state <= NEXT_TX_OPPORTUNITY;
        end
    end

    TRANSMIT:
    begin
        if(COL && (TX_EN || CRS))
        begin
            next_mod_148_3_state <= !TRANSMIT;
            next_mod_148_3_state <= TRANSMIT;
        end
        if((!TX_EN) && ((bc < max_bc) || dplca_en))
        begin
            next_mod_148_3_state <= BURST;
        end
        if((!TX_EN) && (!CRS) && (bc >= max_bc))
        begin
            next_mod_148_3_state <= NEXT_TX_OPPORTUNITY;
        end
    end

    BURST:
    begin
        if(TX_EN && (max_bc > 0))
        begin
            next_mod_148_3_state <= TRANSMIT;
        end
        if((!TX_EN) && (burst_timer_done || append_commit_timer_done))
        begin
            next_mod_148_3_state <= ABORT;
        end
    end

    NEXT_TX_OPPORTUNITY:
    begin
        if(((local_nodeID == 0) && (curID >= plca_node_count)) || (curID == 255) && ((dplca_txop_table_upd || (dplca_aging == OFF)) || (!dplca_en)))
        begin
            next_mod_148_3_state <= RESYNC;
        end
        if((((local_nodeID != 0) || (curID < plca_node_count)) && (curID != 255)) && ((dplca_txop_table_upd || (dplca_aging == OFF)) || (!dplca_en)))
        begin
            next_mod_148_3_state <= WAIT_TO;
        end
    end

    ABORT:
    begin
        if(!CRS)
        begin
            next_mod_148_3_state <= NEXT_TX_OPPORTUNITY;
        end
    end

    endcase

    end

end

/*                                                                    */
/* State diagram actions                                              */
/* Blocking assignment of actions, once complete assign  the  current */
/* state to be the next state value.                                  */
/*                                                                    */

always@(next_mod_148_3_state)

begin

    case(next_mod_148_3_state)

    DISABLE:
    begin
        tx_cmd = NONE;
        committed = FALSE;
        curID = 0;
        plca_active = FALSE;
        dplca_txop_claim = NONE;
        dplca_txop_end = FALSE;
        dplca_txop_id = 0;
        dplca_txop_node_count = plca_node_count;
        plca_tx_beacon = FALSE;
    end

    RESYNC:
    begin
        plca_active = FALSE;
        dplca_txop_end = FALSE;
    end

    RECOVER:
    begin
        plca_active = FALSE;
    end

    SEND_BEACON:
    begin
        -> plca.mod_inst_148_4_4_timer.beacon_timer.start;
        tx_cmd = BEACON;
        plca_active = TRUE;
        plca_tx_beacon = TRUE;
    end

    SYNCING:
    begin
        curID = 0;
        tx_cmd = NONE;
        plca_active = TRUE;
        if((local_nodeID != 0) && (rx_cmd != BEACON))
        begin
            -> plca.mod_inst_148_4_4_timer.invalid_beacon_timer.start;
        end
        dplca_txop_node_count = dplca_txop_id;
    end

    WAIT_TO:
    begin
        -> plca.mod_inst_148_4_4_timer.to_timer.start;
        dplca_txop_claim = NONE;
        dplca_txop_end = FALSE;
        dplca_txop_id = curID;
    end

    EARLY_RECEIVE:
    begin
        -> plca.mod_inst_148_4_4_timer.to_timer.stop;
        -> plca.mod_inst_148_4_4_timer.beacon_det_timer.start;
        dplca_txop_claim = SOFT;
    end

    COMMIT_STATE:
    begin
        tx_cmd = COMMIT;
        committed = TRUE;
        -> plca.mod_inst_148_4_4_timer.to_timer.stop;
        bc = 0;
        if( COL)
        begin
            dplca_txop_claim = SOFT;
        end
    end

    RECEIVE:
    begin
        if( rx_cmd == COMMIT)
        begin
            dplca_txop_claim = HARD;
        end
    end

    TRANSMIT:
    begin
        tx_cmd = NONE;
        if( bc >= max_bc)
        begin
            committed = FALSE;
        end
        if( COL)
        begin
            dplca_txop_claim = SOFT;
        end
    end

    BURST:
    begin
        bc = bc + 1;
        tx_cmd = COMMIT;
        if( max_bc > 0)
        begin
            -> plca.mod_inst_148_4_4_timer.burst_timer.start;
            end
        else
        begin
                -> plca.mod_inst_148_4_4_timer.append_commit_timer.start;
            end
    end

    NEXT_TX_OPPORTUNITY:
    begin
        curID = curID + 1;
        committed = FALSE;
        dplca_txop_end = TRUE;
    end

    ABORT:
    begin
        tx_cmd = NONE;
        committed = FALSE;
    end

    endcase

    mod_148_3_state = next_mod_148_3_state;

end


always@(tx_cmd, rx_cmd)
begin
        if( (tx_cmd != BEACON) && (rx_cmd != BEACON) )
        begin
                plca_tx_beacon = FALSE;
        end
end


reg [47:0]       rx_cmd_ASCII;
initial          rx_cmd_ASCII = "- X -";

always@(rx_cmd)
begin
    case(rx_cmd)
        2'b00 : rx_cmd_ASCII = "BEACON";
        2'b01 : rx_cmd_ASCII = "COMMIT";
        2'b10 : rx_cmd_ASCII = "NONE";
        default : rx_cmd_ASCII = "- X -";
    endcase
end

reg [23:0]       dplca_aging_ASCII;
initial          dplca_aging_ASCII = "- X -";

always@(dplca_aging)
begin
    case(dplca_aging)
        1'b0 : dplca_aging_ASCII = "OFF";
        1'b1 : dplca_aging_ASCII = "ON";
        default : dplca_aging_ASCII = "- X -";
    endcase
end


reg [151:0]       mod_148_3_state_ASCII;
initial           mod_148_3_state_ASCII = "- X -";

always@(mod_148_3_state)
begin
    case(mod_148_3_state)
        4'b0000 : mod_148_3_state_ASCII = "DISABLE";
        4'b0001 : mod_148_3_state_ASCII = "RESYNC";
        4'b0010 : mod_148_3_state_ASCII = "RECOVER";
        4'b0011 : mod_148_3_state_ASCII = "SEND_BEACON";
        4'b0100 : mod_148_3_state_ASCII = "SYNCING";
        4'b0101 : mod_148_3_state_ASCII = "WAIT_TO";
        4'b0110 : mod_148_3_state_ASCII = "EARLY_RECEIVE";
        4'b0111 : mod_148_3_state_ASCII = "COMMIT_STATE";
        4'b1000 : mod_148_3_state_ASCII = "YIELD";
        4'b1001 : mod_148_3_state_ASCII = "RECEIVE";
        4'b1010 : mod_148_3_state_ASCII = "TRANSMIT";
        4'b1011 : mod_148_3_state_ASCII = "BURST";
        4'b1100 : mod_148_3_state_ASCII = "NEXT_TX_OPPORTUNITY";
        4'b1101 : mod_148_3_state_ASCII = "ABORT";
        default : mod_148_3_state_ASCII = "- X -";
    endcase
end

`endif


endmodule

