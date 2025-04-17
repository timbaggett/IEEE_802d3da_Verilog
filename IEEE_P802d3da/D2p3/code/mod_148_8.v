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
                 coordinator_role_allowed,
                 plca_status,
                 rx_cmd,
                 dplca_txop_table_upd,
                 plca_node_count,
                 dplca_new_age,
                 tx_cmd,
                 CRS,
                 COL,
                 local_nodeID,
                 dplca_txop_id,
                 dplca_txop_node_count,
                 txop_claim_table_unpacked,
                 plca_tx_beacon,
                 dplca_min_node_count,

                 mod_148_8_state,
                 dplca_aging
                 );

input            plca_reset;
input            dplca_en;
input            plca_en;
input            wait_beacon_timer_done;
input            coordinator_role_allowed;
input            plca_status;
input[1:0]       rx_cmd;
input            dplca_txop_table_upd;
input[7:0]       plca_node_count;
input            dplca_new_age;
input[1:0]       tx_cmd;
input            CRS;
input            COL;
input[7:0]       local_nodeID;
input[7:0]       dplca_txop_id;
input[7:0]       dplca_txop_node_count;
input[511:0]     txop_claim_table_unpacked;
input            plca_tx_beacon;
input[7:0]       dplca_min_node_count;

output[2:0]      mod_148_8_state;
output           dplca_aging;

reg[2:0]         mod_148_8_state;
reg[2:0]         next_mod_148_8_state;
reg              dplca_aging;

`ifdef simulate
`include "IEEE_P802_3da_param.v"
`include "mod_148_4_7_param.v"

parameter        DISABLED            =  3'b000;
parameter        WAIT_BEACON         =  3'b001;
parameter        COORDINATOR         =  3'b010;
parameter        REDUCE_NODE_COUNT   =  3'b011;
parameter        LOOPBACK            =  3'b100;
parameter        LEARNING            =  3'b101;
parameter        INCREASE_NODE_COUNT =  3'b110;
parameter        FOLLOWER            =  3'b111;

/*                                                                    */
/* Pack multidimensional arrays                                       */
/* Verilog does not support the  use  of  multidimensional arrays  in */
/* module  ports. As a result, unpack the multidimensional array into */
/* a vector and use  this  as  a module port. The vector must then be */
/* packed back into an array after passing through the port.          */
/*                                                                    */

/*                                                                    */
/* Pack txop_claim_table                                              */
/*                                                                    */

wire [1:0] txop_claim_table [255:0];

genvar txop_claim_table_index;
generate for (txop_claim_table_index = 0; txop_claim_table_index < 256; txop_claim_table_index = txop_claim_table_index + 1)
begin : txop_claim_table_pack
    assign txop_claim_table[txop_claim_table_index] = txop_claim_table_unpacked[((txop_claim_table_index + 1) * 2) - 1 : (txop_claim_table_index * 2)];
    wire[1:0] txop_claim_table_location;
    assign txop_claim_table_location = txop_claim_table[txop_claim_table_index];
end
endgenerate

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

always@(mod_148_8_state, plca_reset, dplca_en, plca_en, wait_beacon_timer_done, coordinator_role_allowed, plca_status, rx_cmd, dplca_txop_table_upd, plca_node_count, dplca_new_age, tx_cmd, CRS, COL, local_nodeID, dplca_txop_id, dplca_txop_node_count, txop_claim_table_unpacked, plca_tx_beacon, plca.mod_inst_148_4_7_func.HARD_CLAIMING_change, plca.mod_inst_148_4_7_func.MAX_HARD_CLAIM_change, plca.mod_inst_148_4_7_func.SOFT_CLAIMING_change)

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
        if((!plca.mod_inst_148_4_7_func.HARD_CLAIMING(0)) && (rx_cmd != BEACON) && dplca_txop_table_upd && (!plca.mod_inst_148_4_7_func.HARD_CLAIMING(plca_node_count - 1)) && (plca_node_count > dplca_min_node_count) && dplca_new_age)
        begin
            next_mod_148_8_state <= REDUCE_NODE_COUNT;
        end
        if(plca_tx_beacon)
        begin
            next_mod_148_8_state <= COORDINATOR;
        end
        if(( dplca_txop_table_upd && plca.mod_inst_148_4_7_func.HARD_CLAIMING(0) ) || ( (rx_cmd == BEACON) && (!plca_tx_beacon) ))
        begin
            next_mod_148_8_state <= LEARNING;
        end
        if((!plca.mod_inst_148_4_7_func.HARD_CLAIMING(0)) && (rx_cmd != BEACON) && dplca_txop_table_upd && plca.mod_inst_148_4_7_func.HARD_CLAIMING(plca_node_count - 1) && (plca_node_count < 255) && dplca_new_age)
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

    LOOPBACK:
    begin
        if((tx_cmd != BEACON) && (rx_cmd != BEACON) && (!CRS) && (!COL)) // Fix to prevent infinite loop.
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
            next_mod_148_8_state <= FOLLOWER;
        end
    end

    INCREASE_NODE_COUNT:
    begin
        if(!dplca_new_age)
        begin
            next_mod_148_8_state <= COORDINATOR;
        end
    end

    FOLLOWER:
    begin
        if(plca_status == FAIL)
        begin
            next_mod_148_8_state <= DISABLED;
        end
        if(dplca_txop_table_upd && (plca_status == OK) && ( plca.mod_inst_148_4_7_func.HARD_CLAIMING(local_nodeID) || plca.mod_inst_148_4_7_func.SOFT_CLAIMING(local_nodeID) || ( (dplca_txop_id == 0) && (dplca_txop_node_count <= local_nodeID) ) || ( dplca_new_age && (local_nodeID > plca.mod_inst_148_4_7_func.MAX_HARD_CLAIM(txop_claim_table_unpacked)) )))
        begin
            next_mod_148_8_state <= !FOLLOWER;
            next_mod_148_8_state <= FOLLOWER;
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
        plca.local_nodeID = 255;
        plca.plca_node_count = dplca_min_node_count;
    end

    COORDINATOR:
    begin
        plca.local_nodeID = 0;
        dplca_aging = ON;
    end

    REDUCE_NODE_COUNT:
    begin
        plca.plca_node_count = plca.mod_inst_148_4_7_func.MAX_HARD_CLAIM(txop_claim_table_unpacked) + 2;
    end

    LEARNING:
    begin
        plca.local_nodeID = 255;
        dplca_aging = ON;
    end

    INCREASE_NODE_COUNT:
    begin
        plca.plca_node_count = plca_node_count + 1;
    end

    FOLLOWER:
    begin
        plca.local_nodeID = plca.mod_inst_148_4_7_func.PICK_FREE_TXOP(txop_claim_table_unpacked);
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
        3'b000 : mod_148_8_state_ASCII = "DISABLED";
        3'b001 : mod_148_8_state_ASCII = "WAIT_BEACON";
        3'b010 : mod_148_8_state_ASCII = "COORDINATOR";
        3'b011 : mod_148_8_state_ASCII = "REDUCE_NODE_COUNT";
        3'b100 : mod_148_8_state_ASCII = "LOOPBACK";
        3'b101 : mod_148_8_state_ASCII = "LEARNING";
        3'b110 : mod_148_8_state_ASCII = "INCREASE_NODE_COUNT";
        3'b111 : mod_148_8_state_ASCII = "FOLLOWER";
        default : mod_148_8_state_ASCII = "- X -";
    endcase
end

`endif

endmodule

