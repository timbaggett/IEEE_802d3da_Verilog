/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_147_7.v                                         */
/*        Date:   25/08/2019                                          */
/*                                                                    */
/**********************************************************************/

module           mod_147_7(

                 pcs_reset,
                 transmitting,
                 duplex_mode,
                 link_control,
                 RSCD,
                 RXn,
                 multidrop,
                 fc_supported,
                 RXn_2,
                 RXn_1,
                 RXn_3,

                 mod_147_7_state,
                 RX_DV,
                 RX_ER,
                 RXD,
                 rx_cmd,
                 precnt,
                 null_value
                 );

input            pcs_reset;
input            transmitting;
input            duplex_mode;
input            link_control;
input            RSCD;
input[4:0]       RXn;
input            multidrop;
input            fc_supported;
input[4:0]       RXn_2;
input[4:0]       RXn_1;
input[4:0]       RXn_3;

output[3:0]      mod_147_7_state;
output           RX_DV;
output           RX_ER;
output[3:0]      RXD;
output[1:0]      rx_cmd;
output[7:0]      precnt;
output[3:0]      null_value;

reg[3:0]         mod_147_7_state;
reg[3:0]         next_mod_147_7_state;
reg              RX_DV;
reg              RX_ER;
reg[3:0]         RXD;
reg[1:0]         rx_cmd;
reg[7:0]         precnt;
reg[3:0]         null_value;

`ifdef simulate
`include "Clause_147/code/IEEE_P802_3cg_param.v"
`include "Clause_147/code/mod_147_3_3_param.v"
`include "Clause_147/code/mod_147_3_3_func.v"

parameter        WAIT_SYNC           =  4'b0000;
parameter        SYNCING             =  4'b0001;
parameter        COMMIT_STATE        =  4'b0010;
parameter        WAIT_SSD            =  4'b0011;
parameter        PRE                 =  4'b0100;
parameter        BAD_SSD             =  4'b0101;
parameter        DATA                =  4'b0110;
parameter        BAD_ESD             =  4'b0111;
parameter        GOOD_ESD            =  4'b1000;
parameter        HEARTBEAT1          =  4'b1001;
parameter        BEACON1             =  4'b1010;
parameter        HEARTBEAT2          =  4'b1011;
parameter        BEACON2             =  4'b1100;

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

always@(mod_147_7_state, pcs_reset, transmitting, duplex_mode, link_control, RSCD, RXn, multidrop, fc_supported, RXn_2, RXn_1, RXn_3)

begin

    next_mod_147_7_state <= mod_147_7_state;

    if(pcs_reset || (RXn == SILENCE) || (transmitting && (duplex_mode == DUPLEX_HALF)) || (link_control == DISABLE))
    begin
        next_mod_147_7_state <= !WAIT_SYNC;
        next_mod_147_7_state <= WAIT_SYNC;
    end

    else
    begin

    case(mod_147_7_state)

    WAIT_SYNC:
    begin
        if(RSCD && (RXn == SYNC))
        begin
            next_mod_147_7_state <= SYNCING;
        end
        if(RSCD && (RXn == HB) && (!multidrop))
        begin
            next_mod_147_7_state <= WAIT_SSD;
        end
        if(RSCD && (RXn == HB) && (!multidrop))
        begin
            next_mod_147_7_state <= HEARTBEAT1;
        end
        if(RSCD && (RXn == BEACON))
        begin
            next_mod_147_7_state <= BEACON1;
        end
    end

    SYNCING:
    begin
        if(RSCD && ((RXn == ESD) || ((RXn != SSD) && (RXn != SYNC) && (!fc_supported))))
        begin
            next_mod_147_7_state <= WAIT_SYNC;
        end
        if(RSCD && (RXn == SYNC))
        begin
            next_mod_147_7_state <= COMMIT_STATE;
        end
        if(RSCD && (RXn == SSD))
        begin
            next_mod_147_7_state <= WAIT_SSD;
        end
        if(RSCD && (RXn != SYNC) && (RXn != SSD) && (RXn != ESD) && fc_supported)
        begin
            next_mod_147_7_state <= BAD_SSD;
        end
    end

    COMMIT_STATE:
    begin
        if(RSCD && ((RXn == ESD) || ((RXn != SSD) && (RXn != SYNC) && (!fc_supported))))
        begin
            next_mod_147_7_state <= WAIT_SYNC;
        end
        if(RSCD && (RXn == SSD))
        begin
            next_mod_147_7_state <= WAIT_SSD;
        end
        if(RSCD && (RXn != SYNC) && (RXn != SSD) && (RXn != ESD) && fc_supported)
        begin
            next_mod_147_7_state <= BAD_SSD;
        end
    end

    WAIT_SSD:
    begin
        if(RSCD && (RXn != SSD) && (!fc_supported))
        begin
            next_mod_147_7_state <= WAIT_SYNC;
        end
        if(RSCD && (RXn == SSD))
        begin
            next_mod_147_7_state <= PRE;
        end
        if(RSCD && (RXn != SSD) && fc_supported)
        begin
            next_mod_147_7_state <= BAD_SSD;
        end
    end

    PRE:
    begin
        if(RSCD && (precnt != 9))
        begin
            next_mod_147_7_state <= !PRE;
            next_mod_147_7_state <= PRE;
        end
        if(RSCD && (precnt == 9))
        begin
            next_mod_147_7_state <= DATA;
        end
    end

    BAD_SSD:
    begin
        if(RSCD && ((RXn == SILENCE) || (RXn == ESD)))
        begin
            next_mod_147_7_state <= WAIT_SYNC;
        end
    end

    DATA:
    begin
        if(RSCD && ((((RXn_2 == ESD) || (RXn_2 == ESDBRS)) && (RXn_1 != ESDOK) && (RXn_3 != ESD) && (RXn_3 != ESDBRS)) || (RXn_3 == SILENCE)))
        begin
            next_mod_147_7_state <= BAD_SSD;
        end
        if(RSCD && (!((((RXn_2 == ESD) || (RXn_2 == ESDBRS)) && (RXn_1 != ESDOK) && (RXn_3 != ESD) && (RXn_3 != ESDBRS)) || (RXn_3 == SILENCE))) && (!(((RXn_3 == ESD) || (RXn_3 == ESDBRS)) && (RXn_2 == ESDOK))))
        begin
            next_mod_147_7_state <= !DATA;
            next_mod_147_7_state <= DATA;
        end
        if(RSCD && ((RXn_3 == ESD) || (RXn_3 == ESDBRS)) && (RXn_2 == ESDOK))
        begin
            next_mod_147_7_state <= GOOD_ESD;
        end
    end

    BAD_ESD:
    begin
        if(RSCD)
        begin
            next_mod_147_7_state <= WAIT_SYNC;
        end
    end

    GOOD_ESD:
    begin
        if(RSCD)
        begin
            next_mod_147_7_state <= WAIT_SYNC;
        end
    end

    HEARTBEAT1:
    begin
        if(RSCD && RXn != HB)
        begin
            next_mod_147_7_state <= WAIT_SYNC;
        end
        if(RSCD && RXn == HB)
        begin
            next_mod_147_7_state <= HEARTBEAT2;
        end
    end

    BEACON1:
    begin
        if(RSCD && RXn != BEACON)
        begin
            next_mod_147_7_state <= WAIT_SYNC;
        end
        if(RSCD && RXn == BEACON)
        begin
            next_mod_147_7_state <= BEACON2;
        end
    end

    HEARTBEAT2:
    begin
        if(RSCD && RXn != HB)
        begin
            next_mod_147_7_state <= WAIT_SYNC;
        end
    end

    BEACON2:
    begin
        if(RSCD && RXn != BEACON)
        begin
            next_mod_147_7_state <= WAIT_SYNC;
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

always@(next_mod_147_7_state)

begin

    case(next_mod_147_7_state)

    WAIT_SYNC:
    begin
        RX_DV = FALSE;
        RX_ER = FALSE;
        RXD = 4'b0000;
        rx_cmd = NONE;
    end

    COMMIT_STATE:
    begin
        RX_ER = TRUE;
        RXD = 4'b0011;
        rx_cmd = COMMIT;
    end

    WAIT_SSD:
    begin
        RXD =4'b0000;
        precnt = 0;
        RX_ER = FALSE;
        rx_cmd = NONE;
    end

    PRE:
    begin
        RX_DV = TRUE;
        RXD = 4'b0101;
        precnt = precnt + 1;
        if(precnt > 3)
        begin
            null_value = DECODE(RXn_3);
        end
    end

    BAD_SSD:
    begin
        RX_ER = TRUE;
        RXD = 4'b1110;
        rx_cmd = NONE;
    end

    DATA:
    begin
        RXD = DECODE(RXn_3);
    end

    BAD_ESD:
    begin
        RX_ER = TRUE;
        RXD = 4'b0000;
    end

    GOOD_ESD:
    begin
        RX_DV = FALSE;
        RXD = 4'b0000;
    end

    HEARTBEAT2:
    begin
        rx_cmd = HEARTBEAT;
    end

    BEACON2:
    begin
        RX_ER = TRUE;
        RXD = 4'b0010;
        rx_cmd = BEACON;
    end

    endcase

    mod_147_7_state = next_mod_147_7_state;

    base_t1s.RSCD_147_7 = FALSE;

end


reg [87:0]       duplex_mode_ASCII;

always@(duplex_mode)
begin
    casex(duplex_mode)
    1'b0 : duplex_mode_ASCII = "DUPLEX_FULL";
    1'b1 : duplex_mode_ASCII = "DUPLEX_HALF";
    endcase
end

reg [55:0]       link_control_ASCII;

always@(link_control)
begin
    casex(link_control)
    1'b0 : link_control_ASCII = "ENABLE";
    1'b1 : link_control_ASCII = "DISABLE";
    endcase
end


reg [95:0]       mod_147_7_state_ASCII;

always@(mod_147_7_state)
begin
    casex(mod_147_7_state)
        4'b0000 : mod_147_7_state_ASCII = "WAIT_SYNC";
        4'b0001 : mod_147_7_state_ASCII = "SYNCING";
        4'b0010 : mod_147_7_state_ASCII = "COMMIT_STATE";
        4'b0011 : mod_147_7_state_ASCII = "WAIT_SSD";
        4'b0100 : mod_147_7_state_ASCII = "PRE";
        4'b0101 : mod_147_7_state_ASCII = "BAD_SSD";
        4'b0110 : mod_147_7_state_ASCII = "DATA";
        4'b0111 : mod_147_7_state_ASCII = "BAD_ESD";
        4'b1000 : mod_147_7_state_ASCII = "GOOD_ESD";
        4'b1001 : mod_147_7_state_ASCII = "HEARTBEAT1";
        4'b1010 : mod_147_7_state_ASCII = "BEACON1";
        4'b1011 : mod_147_7_state_ASCII = "HEARTBEAT2";
        4'b1100 : mod_147_7_state_ASCII = "BEACON2";
    endcase
end

reg[95:0] RXn_ASCII;
reg[95:0] RXn_1_ASCII;
reg[95:0] RXn_2_ASCII;
reg[95:0] RXn_3_ASCII;

always @(RXn) RXn_ASCII = RX_ASCII(RXn);
always @(RXn_1) RXn_1_ASCII = RX_ASCII(RXn_1);
always @(RXn_2) RXn_2_ASCII = RX_ASCII(RXn_2);
always @(RXn_3) RXn_3_ASCII = RX_ASCII(RXn_3);

`endif

endmodule

