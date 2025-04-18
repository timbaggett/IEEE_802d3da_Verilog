/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_9.v                                         */
/*        Date:   09/04/2025                                          */
/*                                                                    */
/**********************************************************************/

module           mod_148_9(

                 dplca_aging,
                 dplca_txop_end,
                 dplca_txop_claim,
                 dplca_txop_id,
                 txop_claim_table_unpacked,
                 txop_claim_table_new_unpacked,
                 soft_aging_cycles,
                 hard_aging_cycles,

                 mod_148_9_state,
                 short_cnt,
                 long_cnt,
                 dplca_new_age,
                 dplca_txop_table_upd
                 );

input            dplca_aging;
input            dplca_txop_end;
input[1:0]       dplca_txop_claim;
input[7:0]       dplca_txop_id;
input[511:0]     txop_claim_table_unpacked;
input[511:0]     txop_claim_table_new_unpacked;
input[15:0]      soft_aging_cycles;
input[15:0]      hard_aging_cycles;

output[2:0]      mod_148_9_state;
output[15:0]     short_cnt;
output[15:0]     long_cnt;
output           dplca_new_age;
output           dplca_txop_table_upd;

reg[2:0]         mod_148_9_state;
reg[2:0]         next_mod_148_9_state;
reg[15:0]        short_cnt;
reg[15:0]        long_cnt;
reg              dplca_new_age;
reg              dplca_txop_table_upd;

`ifdef simulate
`include "IEEE_P802_3da_param.v"
`include "mod_148_4_7_param.v"

parameter        DISABLED            =  3'b000;
parameter        WAIT_TXOP_END       =  3'b001;
parameter        TXOP_END            =  3'b010;
parameter        UPDATE_SOFT         =  3'b011;
parameter        UPDATE_HARD         =  3'b100;
parameter        NOTIFY              =  3'b101;

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
/* Pack txop_claim_table_new                                          */
/*                                                                    */

wire [1:0] txop_claim_table_new [255:0];

genvar txop_claim_table_new_index;
generate for (txop_claim_table_new_index = 0; txop_claim_table_new_index < 256; txop_claim_table_new_index = txop_claim_table_new_index + 1)
begin : txop_claim_table_new_pack
    assign txop_claim_table_new[txop_claim_table_new_index] = txop_claim_table_new_unpacked[((txop_claim_table_new_index + 1) * 2) - 1 : (txop_claim_table_new_index * 2)];
    wire[1:0] txop_claim_table_new_location;
    assign txop_claim_table_new_location = txop_claim_table_new[txop_claim_table_new_index];
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

always@(mod_148_9_state, dplca_aging, dplca_txop_end, dplca_txop_claim, dplca_txop_id, txop_claim_table_unpacked, txop_claim_table_new_unpacked, soft_aging_cycles, hard_aging_cycles)

begin

    next_mod_148_9_state <= mod_148_9_state;

    if(dplca_aging == OFF)
    begin
        next_mod_148_9_state <= !DISABLED;
        next_mod_148_9_state <= DISABLED;
    end

    else
    begin

    case(mod_148_9_state)

    DISABLED:
    begin
        begin
            next_mod_148_9_state <= WAIT_TXOP_END;
        end
    end

    WAIT_TXOP_END:
    begin
        if(dplca_txop_end)
        begin
            next_mod_148_9_state <= TXOP_END;
        end
    end

    TXOP_END:
    begin
        if(dplca_txop_claim == SOFT)
        begin
            next_mod_148_9_state <= UPDATE_SOFT;
        end
        if(dplca_txop_claim == HARD)
        begin
            next_mod_148_9_state <= UPDATE_HARD;
        end
        if(dplca_txop_claim == NONE)
        begin
            next_mod_148_9_state <= NOTIFY;
        end
    end

    UPDATE_SOFT:
    begin
        begin
            next_mod_148_9_state <= NOTIFY;
        end
    end

    UPDATE_HARD:
    begin
        begin
            next_mod_148_9_state <= NOTIFY;
        end
    end

    NOTIFY:
    begin
        if(!dplca_txop_end)
        begin
            next_mod_148_9_state <= WAIT_TXOP_END;
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

always@(next_mod_148_9_state)

begin

    case(next_mod_148_9_state)

    DISABLED:
    begin
        plca.mod_inst_148_4_7_func.CLEAR_TXOP_TABLE(CLAIM_TABLE);
        plca.mod_inst_148_4_7_func.CLEAR_TXOP_TABLE(CLAIM_TABLE_NEW);
        short_cnt = 0;
        long_cnt = 0;
        dplca_new_age = FALSE;
        dplca_txop_table_upd = FALSE;
    end

    WAIT_TXOP_END:
    begin
        dplca_new_age = FALSE;
        dplca_txop_table_upd = FALSE;
    end

    TXOP_END:
    begin
        if( dplca_txop_id == 0)
        begin
            if( short_cnt == soft_aging_cycles)
            begin
                plca.mod_inst_148_4_7_func.CLEAR_SOFT_CLAIMS(CLAIM_TABLE);
                plca.mod_inst_148_4_7_func.CLEAR_SOFT_CLAIMS(CLAIM_TABLE_NEW);
                short_cnt = 0;
            end
            else
            begin
                short_cnt = short_cnt + 1;
            end

            if( long_cnt == hard_aging_cycles)
            begin
                plca.mod_inst_148_4_7_func.mod_148_9_ARRAY_ASSIGN_$D$11();
                plca.mod_inst_148_4_7_func.CLEAR_TXOP_TABLE(CLAIM_TABLE_NEW);
                dplca_new_age = TRUE;
                long_cnt = 0;
            end
            else
            begin
                long_cnt = long_cnt + 1;
            end
        end
    end

    UPDATE_SOFT:
    begin
        if( txop_claim_table[dplca_txop_id] == NONE)
        begin
            plca.txop_claim_table[dplca_txop_id] = SOFT;
        end
        if( txop_claim_table_new[dplca_txop_id] == NONE)
        begin
            plca.txop_claim_table_new[dplca_txop_id] = SOFT;
        end
    end

    UPDATE_HARD:
    begin
        plca.txop_claim_table[dplca_txop_id] = HARD;
        plca.txop_claim_table_new[dplca_txop_id] = HARD;
    end

    NOTIFY:
    begin
        dplca_txop_table_upd = TRUE;
    end

    endcase

    mod_148_9_state = next_mod_148_9_state;

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

reg [31:0]       dplca_txop_claim_ASCII;
initial          dplca_txop_claim_ASCII = "- X -";

always@(dplca_txop_claim)
begin
    case(dplca_txop_claim)
        2'b00 : dplca_txop_claim_ASCII = "SOFT";
        2'b01 : dplca_txop_claim_ASCII = "HARD";
        2'b10 : dplca_txop_claim_ASCII = "NONE";
        default : dplca_txop_claim_ASCII = "- X -";
    endcase
end

reg [103:0]       mod_148_9_state_ASCII;
initial           mod_148_9_state_ASCII = "- X -";

always@(mod_148_9_state)
begin
    case(mod_148_9_state)
        3'b000 : mod_148_9_state_ASCII = "DISABLED";
        3'b001 : mod_148_9_state_ASCII = "WAIT_TXOP_END";
        3'b010 : mod_148_9_state_ASCII = "TXOP_END";
        3'b011 : mod_148_9_state_ASCII = "UPDATE_SOFT";
        3'b100 : mod_148_9_state_ASCII = "UPDATE_HARD";
        3'b101 : mod_148_9_state_ASCII = "NOTIFY";
        default : mod_148_9_state_ASCII = "- X -";
    endcase
end

`endif

endmodule

