/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_7.v                                         */
/*        Date:   26/11/2024                                          */
/*                                                                    */
/**********************************************************************/

module           mod_148_7(

                 plca_reset,
                 plca_en,
                 plca_active,
                 plca_status_timer_done,

                 mod_148_7_state,
                 plca_status
                 );

input            plca_reset;
input            plca_en;
input            plca_active;
input            plca_status_timer_done;

output[1:0]      mod_148_7_state;
output           plca_status;

reg[1:0]         mod_148_7_state;
reg[1:0]         next_mod_148_7_state;
reg              plca_status;

`ifdef simulate
`include "IEEE_P802_3da_param.v"
`include "mod_148_4_6_param.v"

parameter        INACTIVE            =  2'b00;
parameter        ACTIVE              =  2'b01;
parameter        HYSTERESIS          =  2'b10;

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

always@(mod_148_7_state, plca_reset, plca_en, plca_active, plca_status_timer_done)

begin

    next_mod_148_7_state <= mod_148_7_state;

    if(plca_reset || (!plca_en))
    begin
        next_mod_148_7_state <= !INACTIVE;
        next_mod_148_7_state <= INACTIVE;
    end

    else
    begin

    case(mod_148_7_state)

    INACTIVE:
    begin
        if(plca_active)
        begin
            next_mod_148_7_state <= ACTIVE;
        end
    end

    ACTIVE:
    begin
        if(!plca_active)
        begin
            next_mod_148_7_state <= HYSTERESIS;
        end
    end

    HYSTERESIS:
    begin
        if(plca_status_timer_done && (!plca_active))
        begin
            next_mod_148_7_state <= INACTIVE;
        end
        if(plca_active)
        begin
            next_mod_148_7_state <= ACTIVE;
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

always@(next_mod_148_7_state)

begin

    case(next_mod_148_7_state)

    INACTIVE:
    begin
        plca_status = FAIL;
    end

    ACTIVE:
    begin
        plca_status = OK;
    end

    HYSTERESIS:
    begin
        -> plca.mod_inst_148_4_6_timer.plca_status_timer.start;
    end

    endcase

    mod_148_7_state = next_mod_148_7_state;

end



reg [79:0]       mod_148_7_state_ASCII;
initial          mod_148_7_state_ASCII = "- X -";

always@(mod_148_7_state)
begin
    case(mod_148_7_state)
        2'b00 : mod_148_7_state_ASCII = "INACTIVE";
        2'b01 : mod_148_7_state_ASCII = "ACTIVE";
        2'b10 : mod_148_7_state_ASCII = "HYSTERESIS";
        default : mod_148_7_state_ASCII = "- X -";
    endcase
end

`endif


endmodule

