/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_147_11.v                                        */
/*        Date:   21/06/2019                                          */
/*                                                                    */
/**********************************************************************/

module           mod_147_11(

                 pcs_reset,
                 mr_autoneg_enable,
                 an_link_good,
                 multidrop,
                 rx_cmd,
                 RX_DV,
                 CRS,
                 link_hold_timer_done,
                 INACTIVE_CNT,
                 ACTIVE_CNT,

                 mod_147_11_state,
                 pcs_status,
                 cnt_h,
                 cnt_l
                 );

input            pcs_reset;
input            mr_autoneg_enable;
input            an_link_good;
input            multidrop;
input[1:0]       rx_cmd;
input            RX_DV;
input            CRS;
input            link_hold_timer_done;
input[3:0]       INACTIVE_CNT;
input[3:0]       ACTIVE_CNT;

output[2:0]      mod_147_11_state;
output           pcs_status;
output[7:0]      cnt_h;
output[7:0]      cnt_l;

reg[2:0]         mod_147_11_state;
reg[2:0]         next_mod_147_11_state;
reg              pcs_status;
reg[7:0]         cnt_h;
reg[7:0]         cnt_l;

`ifdef simulate
`include "Clause_147/code/IEEE_P802_3cg_param.v"
`include "Clause_147/code/mod_147_3_7_2_param.v"

parameter        INACTIVE            =  3'b000;
parameter        COUNT_DOWN          =  3'b001;
parameter        COUNT_UP            =  3'b010;
parameter        HOLD_OFF            =  3'b011;
parameter        ACTIVE              =  3'b100;
parameter        HOLD_ON             =  3'b101;

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

always@(mod_147_11_state, pcs_reset, mr_autoneg_enable, an_link_good, multidrop, rx_cmd, RX_DV, CRS, link_hold_timer_done, INACTIVE_CNT, ACTIVE_CNT)

begin

    if(pcs_reset || (!mr_autoneg_enable) || (!an_link_good) || multidrop)
    begin
        next_mod_147_11_state <= !INACTIVE;
        next_mod_147_11_state <= INACTIVE;
    end

    else
    begin

    case(mod_147_11_state)

    INACTIVE:
    begin
        if((rx_cmd == HEARTBEAT) || RX_DV)
        begin
            next_mod_147_11_state <= COUNT_UP;
        end
    end

    COUNT_DOWN:
    begin
        if(cnt_l == INACTIVE_CNT)
        begin
            next_mod_147_11_state <= INACTIVE;
        end
        if(!(cnt_l == INACTIVE_CNT))
        begin
            next_mod_147_11_state <= ACTIVE;
        end
    end

    COUNT_UP:
    begin
        if((rx_cmd == NONE) && (!RX_DV) && (!CRS) && (cnt_h < ACTIVE_CNT))
        begin
            next_mod_147_11_state <= HOLD_OFF;
        end
        if(cnt_h == ACTIVE_CNT)
        begin
            next_mod_147_11_state <= ACTIVE;
        end
    end

    HOLD_OFF:
    begin
        if(link_hold_timer_done && (rx_cmd == NONE) && (!RX_DV))
        begin
            next_mod_147_11_state <= INACTIVE;
        end
        if((rx_cmd == HEARTBEAT) || RX_DV)
        begin
            next_mod_147_11_state <= COUNT_UP;
        end
    end

    ACTIVE:
    begin
        if(link_hold_timer_done && (rx_cmd != HEARTBEAT) && (!RX_DV))
        begin
            next_mod_147_11_state <= COUNT_DOWN;
        end
        if((rx_cmd == HEARTBEAT) || RX_DV)
        begin
            next_mod_147_11_state <= HOLD_ON;
        end
    end

    HOLD_ON:
    begin
        if((rx_cmd == NONE) && (!RX_DV))
        begin
            next_mod_147_11_state <= ACTIVE;
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

always@(next_mod_147_11_state)

begin

    case(next_mod_147_11_state)

    INACTIVE:
    begin
        pcs_status = NOT_OK;
        cnt_h = 0;
        cnt_l = 0;
    end

    COUNT_DOWN:
    begin
        cnt_l = cnt_l + 1;
    end

    COUNT_UP:
    begin
        -> base_t1s.mod_inst_147_3_7_2_timer.link_hold_timer.start;
        cnt_h = cnt_h + 1;
    end

    ACTIVE:
    begin
        -> base_t1s.mod_inst_147_3_7_2_timer.link_hold_timer.start;
        pcs_status = OK;
    end

    HOLD_ON:
    begin
        cnt_l = 0;
    end

    endcase

    mod_147_11_state = next_mod_147_11_state;

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


reg [79:0]       mod_147_11_state_ASCII;

always@(mod_147_11_state)
begin
    casex(mod_147_11_state)
        3'b000 : mod_147_11_state_ASCII = "INACTIVE";
        3'b001 : mod_147_11_state_ASCII = "COUNT_DOWN";
        3'b010 : mod_147_11_state_ASCII = "COUNT_UP";
        3'b011 : mod_147_11_state_ASCII = "HOLD_OFF";
        3'b100 : mod_147_11_state_ASCII = "ACTIVE";
        3'b101 : mod_147_11_state_ASCII = "HOLD_ON";
    endcase
end

`endif


endmodule

