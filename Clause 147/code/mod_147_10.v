/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_147_10.v                                        */
/*        Date:   21/06/2019                                          */
/*                                                                    */
/**********************************************************************/

module           mod_147_10(

                 pcs_reset,
                 mr_autoneg_enable,
                 an_link_good,
                 multidrop,
                 rx_cmd,
                 tx_cmd,
                 master,
                 hb_timer_done,
                 CRS,
                 hb_send_timer_done,
                 COL,
                 RX_DV,

                 mod_147_10_state,
                 hb_cmd
                 );

input            pcs_reset;
input            mr_autoneg_enable;
input            an_link_good;
input            multidrop;
input[1:0]       rx_cmd;
input[4:0]       tx_cmd;  // Fix
input            master;
input            hb_timer_done;
input            CRS;
input            hb_send_timer_done;
input            COL;
input            RX_DV;

output[3:0]      mod_147_10_state;
output           hb_cmd;

reg[3:0]         mod_147_10_state;
reg[3:0]         next_mod_147_10_state;
reg              hb_cmd;

`ifdef simulate
`include "Clause 147/code/IEEE_P802_3cg_param.v"
`include "Clause 147/code/mod_147_3_7_1_param.v"

parameter        INIT                =  4'b0000;
parameter        WAIT_TMR            =  4'b0001;
parameter        DISABLE_HB          =  4'b0010;
parameter        TX_HB               =  4'b0011;
parameter        COLLIDE             =  4'b0100;
parameter        COOLDOWN            =  4'b0101;
parameter        WAIT_HB             =  4'b0110;
parameter        WAIT_TX             =  4'b0111;
parameter        WAIT_RX             =  4'b1000;
parameter        REPLY_HB            =  4'b1001;

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

always@(mod_147_10_state, pcs_reset, mr_autoneg_enable, an_link_good, multidrop, rx_cmd, tx_cmd, master, hb_timer_done, CRS, hb_send_timer_done, COL, RX_DV)

begin

    next_mod_147_10_state <= mod_147_10_state;

    if(pcs_reset || (!mr_autoneg_enable) || (!an_link_good) || multidrop)
    begin
        next_mod_147_10_state <= !INIT;
        next_mod_147_10_state <= INIT;
    end
    else if((!pcs_reset) && mr_autoneg_enable && an_link_good && (!multidrop) && ((rx_cmd == BEACON) || (tx_cmd == BEACON)))
    begin
        next_mod_147_10_state <= !DISABLE_HB;
        next_mod_147_10_state <= DISABLE_HB;
    end

    else
    begin

    case(mod_147_10_state)

    INIT:
    begin
        if(master)
        begin
            next_mod_147_10_state <= WAIT_TMR;
        end
        if(!master)
        begin
            next_mod_147_10_state <= WAIT_HB;
        end
    end

    WAIT_TMR:
    begin
        if(hb_timer_done && (!CRS))
        begin
            next_mod_147_10_state <= TX_HB;
        end
    end

    DISABLE_HB:
    begin
    end

    TX_HB:
    begin
        if(hb_send_timer_done && (!COL))
        begin
            next_mod_147_10_state <= WAIT_TMR;
        end
        if(COL)
        begin
            next_mod_147_10_state <= COLLIDE;
        end
    end

    COLLIDE:
    begin
        if(!CRS)
        begin
            next_mod_147_10_state <= COOLDOWN;
        end
    end

    COOLDOWN:
    begin
        if(hb_send_timer_done)
        begin
            next_mod_147_10_state <= TX_HB;
        end
    end

    WAIT_HB:
    begin
        if((rx_cmd == HEARTBEAT) || RX_DV)
        begin
            next_mod_147_10_state <= WAIT_RX;
        end
    end

    WAIT_TX:
    begin
        if(hb_send_timer_done)
        begin
            next_mod_147_10_state <= REPLY_HB;
        end
    end

    WAIT_RX:
    begin
        if(!CRS)
        begin
            next_mod_147_10_state <= WAIT_TX;
        end
    end

    REPLY_HB:
    begin
        if(hb_send_timer_done)
        begin
            next_mod_147_10_state <= WAIT_HB;
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

always@(next_mod_147_10_state)

begin

    case(next_mod_147_10_state)

    WAIT_TMR:
    begin
        -> base_t1s.mod_inst_147_3_7_1_timer.hb_timer.start;
        hb_cmd = NONE;
    end

    TX_HB:
    begin
        -> base_t1s.mod_inst_147_3_7_1_timer.hb_send_timer.start;
        hb_cmd = HEARTBEAT;
    end

    COLLIDE:
    begin
        hb_cmd = NONE;
    end

    COOLDOWN:
    begin
        -> base_t1s.mod_inst_147_3_7_1_timer.hb_send_timer.start;
    end

    WAIT_HB:
    begin
        hb_cmd = NONE;
    end

    WAIT_TX:
    begin
        -> base_t1s.mod_inst_147_3_7_1_timer.hb_send_timer.start;
    end

    REPLY_HB:
    begin
        -> base_t1s.mod_inst_147_3_7_1_timer.hb_send_timer.start;
        hb_cmd = HEARTBEAT;
    end

    endcase

    mod_147_10_state = next_mod_147_10_state;

end


reg [71:0]       rx_cmd_ASCII;

always@(rx_cmd)
begin
    casex(rx_cmd)
    2'b00 : rx_cmd_ASCII = "BEACON";
    2'b01 : rx_cmd_ASCII = "COMMIT";
    2'b10 : rx_cmd_ASCII = "HEARTBEAT";
    2'b11 : rx_cmd_ASCII = "NONE";
    endcase
end


reg [79:0]       mod_147_10_state_ASCII;

always@(mod_147_10_state)
begin
    casex(mod_147_10_state)
        4'b0000 : mod_147_10_state_ASCII = "INIT";
        4'b0001 : mod_147_10_state_ASCII = "WAIT_TMR";
        4'b0010 : mod_147_10_state_ASCII = "DISABLE_HB";
        4'b0011 : mod_147_10_state_ASCII = "TX_HB";
        4'b0100 : mod_147_10_state_ASCII = "COLLIDE";
        4'b0101 : mod_147_10_state_ASCII = "COOLDOWN";
        4'b0110 : mod_147_10_state_ASCII = "WAIT_HB";
        4'b0111 : mod_147_10_state_ASCII = "WAIT_TX";
        4'b1000 : mod_147_10_state_ASCII = "WAIT_RX";
        4'b1001 : mod_147_10_state_ASCII = "REPLY_HB";
    endcase
end

`endif


endmodule

