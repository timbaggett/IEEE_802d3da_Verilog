/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_8.v                                         */
/*        Date:   09/04/2025                                          */
/*                                                                    */
/**********************************************************************/

module           mod_148_8(

                 plca_reset,
                 dplca_en,
                 plca_en,
                 wait_beacon_timer_done,
                 beacon_timeout_timer_done,
                 coordinator_role_allowed,
                 plca_status,
                 rx_cmd,
                 dplca_txop_table_upd,
                 plca_node_count,
                 dplca_new_age,
                 tx_cmd,
                 local_nodeID,
                 dplca_txop_id,
                 dplca_txop_node_count,
                 txop_claim_table,
                 aging_cycles,

                 mod_148_8_state,
                 dplca_aging
                 );

input            plca_reset;
input            dplca_en;
input            plca_en;
input            wait_beacon_timer_done;
input            beacon_timeout_timer_done;
input            coordinator_role_allowed;
input            plca_status;
input[1:0]       rx_cmd;
input            dplca_txop_table_upd;
input[7:0]       plca_node_count;
input            dplca_new_age;
input[1:0]       tx_cmd;
input[7:0]       local_nodeID;
input[7:0]       dplca_txop_id;
input[7:0]       dplca_txop_node_count;
input[255:0]     txop_claim_table;
input[15:0]      aging_cycles;

output[3:0]      mod_148_8_state;
output           dplca_aging;

reg[3:0]         mod_148_8_state;
reg[3:0]         next_mod_148_8_state;
reg              dplca_aging;
reg[15:0]        pick_wait_cycles;
reg[15:0]        pick_wait_count;

`ifdef simulate
`include "IEEE_P802_3da_param.v"
`include "mod_148_4_7_param.v"

parameter        DISABLED            =  4'b0000;
parameter        WAIT_BEACON         =  4'b0001;
parameter        COORDINATOR         =  4'b0010;
parameter        REDUCE_NODE_COUNT   =  4'b0011;
parameter        LOOPBACK_TX         =  4'b0100;
parameter        LOOPBACK_RX         =  4'b0101;
parameter        LEARNING            =  4'b0110;
parameter        INCREASE_NODE_COUNT =  4'b0111;
parameter        PICK_WAIT           =  4'b1000;
parameter        PICK_WAIT_INCREMENT =  4'b1001;
parameter        FOLLOWER            =  4'b1010;

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

always@(mod_148_8_state, plca_reset, dplca_en, plca_en, wait_beacon_timer_done, beacon_timeout_timer_done, coordinator_role_allowed, plca_status, rx_cmd, dplca_txop_table_upd, plca_node_count, dplca_new_age, tx_cmd, local_nodeID, dplca_txop_id, dplca_txop_node_count, txop_claim_table, plca.mod_inst_148_4_7_func.CLAIMING_change, plca.mod_inst_148_4_7_func.MAX_CLAIM_change)

begin

    next_mod_148_8_state <= mod_148_8_state;

    if(plca_reset || (!dplca_en) || (!plca_en))
    begin
        next_mod_148_8_state <= !DISABLED;
        next_mod_148_8_state <= DISABLED;
    end

    else
    begin

    case(mod_148_8_state)

    DISABLED:
    begin
        begin
            next_mod_148_8_state <= WAIT_BEACON;
        end
    end

    WAIT_BEACON:
    begin
        if(wait_beacon_timer_done && (!coordinator_role_allowed) && (plca_status == FAIL))
        begin
            next_mod_148_8_state <= DISABLED;
        end
        if(wait_beacon_timer_done && coordinator_role_allowed && (plca_status == FAIL))
        begin
            next_mod_148_8_state <= COORDINATOR;
        end
        if(plca_status == OK)
        begin
            next_mod_148_8_state <= LEARNING;
        end
    end

    COORDINATOR:
    begin
        if((!plca.mod_inst_148_4_7_func.CLAIMING(0)) && (rx_cmd != BEACON) && dplca_txop_table_upd && (!plca.mod_inst_148_4_7_func.CLAIMING(plca_node_count - 1)) && (plca_node_count > 8) && dplca_new_age)
        begin
            next_mod_148_8_state <= REDUCE_NODE_COUNT;
        end
        if((tx_cmd == BEACON))
        begin
            next_mod_148_8_state <= LOOPBACK_TX;
        end
        if(( dplca_txop_table_upd && plca.mod_inst_148_4_7_func.CLAIMING(0) ) || (rx_cmd == BEACON))
        begin
            next_mod_148_8_state <= LEARNING;
        end
        if((!plca.mod_inst_148_4_7_func.CLAIMING(0)) && (rx_cmd != BEACON) && dplca_txop_table_upd && plca.mod_inst_148_4_7_func.CLAIMING(plca_node_count - 1) && (plca_node_count < 255) && dplca_new_age)
        begin
            next_mod_148_8_state <= INCREASE_NODE_COUNT;
        end
    end

    REDUCE_NODE_COUNT:
    begin
        if(!dplca_new_age)
        begin
            next_mod_148_8_state <= COORDINATOR;
        end
    end

    LOOPBACK_TX:
    begin
        if((rx_cmd == BEACON))
        begin
            next_mod_148_8_state <= LOOPBACK_RX;
        end
        if(beacon_timeout_timer_done)
        begin
            next_mod_148_8_state <= DISABLED;
        end
    end

    LOOPBACK_RX:
    begin
        if((rx_cmd != BEACON))
        begin
            next_mod_148_8_state <= COORDINATOR;
        end
    end

    LEARNING:
    begin
        if(plca_status == FAIL)
        begin
            next_mod_148_8_state <= DISABLED;
        end
        if(dplca_txop_table_upd && dplca_new_age && (plca_status == OK))
        begin
`ifdef USE_PICK_WAIT
            next_mod_148_8_state <= PICK_WAIT;
`else
            next_mod_148_8_state <= FOLLOWER;
`endif
        end
    end

    INCREASE_NODE_COUNT:
    begin
        if(!dplca_new_age)
        begin
            next_mod_148_8_state <= COORDINATOR;
        end
    end

    PICK_WAIT:
    begin
        if(rx_cmd == BEACON)
        begin
            next_mod_148_8_state <= PICK_WAIT_INCREMENT;
        end
        if(pick_wait_count >= pick_wait_cycles)
        begin
            next_mod_148_8_state <= FOLLOWER;
        end
        if(plca_status == FAIL)
        begin
            next_mod_148_8_state <= DISABLED;
        end
    end

    PICK_INCREMENT:
    begin
        if(rx_cmd != BEACON)
        begin
            next_mod_148_8_state <= PICK_WAIT;
        end
    end

    FOLLOWER:
    begin
        if(plca_status == FAIL)
        begin
            next_mod_148_8_state <= DISABLED;
        end
        if(dplca_txop_table_upd && (plca_status == OK) && ( plca.mod_inst_148_4_7_func.CLAIMING(local_nodeID) || ( (dplca_txop_id == 0) && (dplca_txop_node_count <= local_nodeID) ) || ( dplca_new_age && (local_nodeID > plca.mod_inst_148_4_7_func.MAX_CLAIM(txop_claim_table)) )))
        begin
`ifdef USE_PICK_WAIT
            next_mod_148_8_state <= PICK_WAIT;
`else
            next_mod_148_8_state <= !FOLLOWER;
            next_mod_148_8_state <= FOLLOWER;
`endif
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

always@(next_mod_148_8_state)

begin

    case(next_mod_148_8_state)

    DISABLED:
    begin
        -> plca.mod_inst_148_4_7_timer.wait_beacon_timer.start;
        dplca_aging = OFF;
    end

    WAIT_BEACON:
    begin
        plca.local_nodeID = 254;    /* Initialize to highest PLCA TO to avoid CSMA/CD */
        plca.plca_node_count = 8;
    end

    COORDINATOR:
    begin
        plca.local_nodeID = 0;
        dplca_aging = ON;
    end

    REDUCE_NODE_COUNT:
    begin
        plca.plca_node_count = plca.mod_inst_148_4_7_func.MAX_CLAIM(txop_claim_table) + 2;
        $display("time = %0t %m REDUCE_NODE_COUNT: Reducing plca_node_count to 0x%02h", $time, plca.plca_node_count);
    end

    LOOPBACK_TX:
    begin
        -> plca.mod_inst_148_4_7_timer.beacon_timeout_timer.start;
    end

    LEARNING:
    begin
        plca.local_nodeID = 254;    /* Initialize to highest PLCA TO to avoid CSMA/CD */
        dplca_aging = ON;
        pick_wait_cycles = $urandom_range(0, aging_cycles/2);
        pick_wait_count = 0;
    end

    INCREASE_NODE_COUNT:
    begin
        plca.plca_node_count = plca_node_count + 1;
        $display("time = %0t %m INCREASE_NODE_COUNT: Increasing plca_node_count to 0x%02h", $time, plca.plca_node_count);
    end

    PICK_WAIT:
    begin
    end

    PICK_WAIT_INCREMENT:
    begin
        pick_wait_count = pick_wait_count + 1;
    end

    FOLLOWER:
    begin
        plca.local_nodeID = plca.mod_inst_148_4_7_func.PICK_FREE_TXOP(txop_claim_table);
        pick_wait_cycles = $urandom_range(0, aging_cycles/2);
        pick_wait_count = 0;
    end

    endcase

    mod_148_8_state = next_mod_148_8_state;

end


reg [31:0]       plca_status_ASCII;
initial          plca_status_ASCII = "- X -";

always@(plca_status)
begin
    case(plca_status)
        1'b0 : plca_status_ASCII = "FAIL";
        1'b1 : plca_status_ASCII = "OK";
        default : plca_status_ASCII = "- X -";
    endcase
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

reg [47:0]       tx_cmd_ASCII;
initial          tx_cmd_ASCII = "- X -";

always@(tx_cmd)
begin
    case(tx_cmd)
        2'b00 : tx_cmd_ASCII = "BEACON";
        2'b01 : tx_cmd_ASCII = "COMMIT";
        2'b10 : tx_cmd_ASCII = "NONE";
        default : tx_cmd_ASCII = "- X -";
    endcase
end

reg [151:0]       mod_148_8_state_ASCII;
initial           mod_148_8_state_ASCII = "- X -";

always@(mod_148_8_state)
begin
    case(mod_148_8_state)
        4'b0000 : mod_148_8_state_ASCII = "DISABLED";
        4'b0001 : mod_148_8_state_ASCII = "WAIT_BEACON";
        4'b0010 : mod_148_8_state_ASCII = "COORDINATOR";
        4'b0011 : mod_148_8_state_ASCII = "REDUCE_NODE_COUNT";
        4'b0100 : mod_148_8_state_ASCII = "LOOPBACK_TX";
        4'b0101 : mod_148_8_state_ASCII = "LOOPBACK_RX";
        4'b0110 : mod_148_8_state_ASCII = "LEARNING";
        4'b0111 : mod_148_8_state_ASCII = "INCREASE_NODE_COUNT";
        4'b1000 : mod_148_8_state_ASCII = "PICK_WAIT";
        4'b1001 : mod_148_8_state_ASCII = "PICK_WAIT_INCREMENT";
        4'b1010 : mod_148_8_state_ASCII = "FOLLOWER";
        default : mod_148_8_state_ASCII = "- X -";
    endcase
end

`endif

endmodule

