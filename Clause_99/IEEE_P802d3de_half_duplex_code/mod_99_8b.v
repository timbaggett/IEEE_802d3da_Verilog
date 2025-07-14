/**********************************************************************/
/*                           IEEE P802.3br                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_99_8b.v                                         */
/*        Date:   21/04/2022                                          */
/*                                                                    */
/**********************************************************************/

module           mod_99_8b(

                 reset_begin,
                 rcv_v,
                 send_r,

                 mod_99_8b_state
                 );

input            reset_begin;
input            rcv_v;
input            send_r;

output           mod_99_8b_state;

reg              mod_99_8b_state;
reg              next_mod_99_8b_state;

`ifdef simulate
`include "Clause_99/IEEE_P802d3de_half_duplex_code/IEEE_P802_3br_param.v"
`include "Clause_99/IEEE_P802d3de_half_duplex_code/mod_99_4_7_param.v"

parameter        RESPOND_IDLE        =  1'b0;
parameter        SEND_RESPOND        =  1'b1;

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

always@(mod_99_8b_state, reset_begin, rcv_v, send_r)

begin

    next_mod_99_8b_state <= mod_99_8b_state;

    if(reset_begin)
    begin
        next_mod_99_8b_state <= !RESPOND_IDLE;
        next_mod_99_8b_state <= RESPOND_IDLE;
    end

    else
    begin

    case(mod_99_8b_state)

    RESPOND_IDLE:
    begin
        if(rcv_v)
        begin
            next_mod_99_8b_state <= SEND_RESPOND;
        end
    end

    SEND_RESPOND:
    begin
        if(!send_r)
        begin
            next_mod_99_8b_state <= RESPOND_IDLE;
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

always@(next_mod_99_8b_state)

begin

    case(next_mod_99_8b_state)

    SEND_RESPOND:
    begin
        MMS.rcv_v = FALSE;
        MMS.send_r = TRUE;
    end

    endcase

    mod_99_8b_state = next_mod_99_8b_state;

end



reg [95:0]       mod_99_8b_state_ASCII;

always@(mod_99_8b_state)
begin
    casex(mod_99_8b_state)
        1'b0 : mod_99_8b_state_ASCII = "RESPOND_IDLE";
        1'b1 : mod_99_8b_state_ASCII = "SEND_RESPOND";
    endcase
end

`endif


endmodule

