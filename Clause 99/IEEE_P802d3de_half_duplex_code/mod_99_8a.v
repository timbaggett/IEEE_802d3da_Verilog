/**********************************************************************/
/*                           IEEE P802.3br                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_99_8a.v                                         */
/*        Date:   10/04/2022                                          */
/*                                                                    */
/**********************************************************************/

module           mod_99_8a(

                 reset_begin,
                 link_fail,
                 disableVerify,
                 pEnable,
                 send_v,
                 verify_timer_done,
                 rcv_r,

                 mod_99_8a_state,
                 verified,
                 verify_fail,
                 verifyCnt
                 );

input            reset_begin;
input            link_fail;
input            disableVerify;
input            pEnable;
input            send_v;
input            verify_timer_done;
input            rcv_r;

output[2:0]      mod_99_8a_state;
output           verified;
output           verify_fail;
output[1:0]      verifyCnt;

reg[2:0]         mod_99_8a_state;
reg[2:0]         next_mod_99_8a_state;
reg              verified;
reg              verify_fail;
reg[1:0]         verifyCnt;

`ifdef simulate
`include "Clause 99/IEEE_P802d3de_half_duplex_code/IEEE_P802_3br_param.v"
`include "Clause 99/IEEE_P802d3de_half_duplex_code/mod_99_4_7_param.v"

parameter        INIT_VERIFICATION   =  3'b000;
parameter        VERIFICATION_IDLE   =  3'b001;
parameter        SEND_VERIFY         =  3'b010;
parameter        WAIT_FOR_RESPONSE   =  3'b011;
parameter        VERIFIED            =  3'b100;
parameter        VERIFY_FAIL         =  3'b101;

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

always@(mod_99_8a_state, reset_begin, link_fail, disableVerify, pEnable, send_v, verify_timer_done, rcv_r)

begin

    next_mod_99_8a_state <= mod_99_8a_state;

    if(reset_begin || link_fail || disableVerify || !pEnable)
    begin
        next_mod_99_8a_state <= !INIT_VERIFICATION;
        next_mod_99_8a_state <= INIT_VERIFICATION;
    end

    else
    begin

    case(mod_99_8a_state)

    INIT_VERIFICATION:
    begin
        begin
            next_mod_99_8a_state <= VERIFICATION_IDLE;
        end
    end

    VERIFICATION_IDLE:
    begin
        if(pEnable && !disableVerify)
        begin
            next_mod_99_8a_state <= SEND_VERIFY;
        end
    end

    SEND_VERIFY:
    begin
        if(!send_v)
        begin
            next_mod_99_8a_state <= WAIT_FOR_RESPONSE;
        end
    end

    WAIT_FOR_RESPONSE:
    begin
        if(verify_timer_done && !rcv_r && verifyCnt < verifyLimit)
        begin
            next_mod_99_8a_state <= VERIFICATION_IDLE;
        end
        if(rcv_r)
        begin
            next_mod_99_8a_state <= VERIFIED;
        end
        if(verify_timer_done && !rcv_r && verifyCnt >= verifyLimit)
        begin
            next_mod_99_8a_state <= VERIFY_FAIL;
        end
    end

    VERIFIED:
    begin
    end

    VERIFY_FAIL:
    begin
    end

    endcase

    end

end

/*                                                                    */
/* State diagram actions                                              */
/* Blocking assignment of actions, once complete assign  the  current */
/* state to be the next state value.                                  */
/*                                                                    */

always@(next_mod_99_8a_state)

begin

    case(next_mod_99_8a_state)

    INIT_VERIFICATION:
    begin
        MMS.rcv_v = FALSE;
        MMS.rcv_r = FALSE;
        MMS.send_v = FALSE;
        MMS.send_r = FALSE;
        verified = FALSE;
        verify_fail = FALSE;
        verifyCnt = 0;
    end

    SEND_VERIFY:
    begin
        MMS.send_v = TRUE;
    end

    WAIT_FOR_RESPONSE:
    begin
        -> MMS.mod_inst_99_4_7_timer.verify_timer.start;
        verifyCnt = verifyCnt + 1;
    end

    VERIFIED:
    begin
        verified = TRUE;
    end

    VERIFY_FAIL:
    begin
        verify_fail = TRUE;
    end

    endcase

    mod_99_8a_state = next_mod_99_8a_state;

end



reg [135:0]       mod_99_8a_state_ASCII;

always@(mod_99_8a_state)
begin
    casex(mod_99_8a_state)
        3'b000 : mod_99_8a_state_ASCII = "INIT_VERIFICATION";
        3'b001 : mod_99_8a_state_ASCII = "VERIFICATION_IDLE";
        3'b010 : mod_99_8a_state_ASCII = "SEND_VERIFY";
        3'b011 : mod_99_8a_state_ASCII = "WAIT_FOR_RESPONSE";
        3'b100 : mod_99_8a_state_ASCII = "VERIFIED";
        3'b101 : mod_99_8a_state_ASCII = "VERIFY_FAIL";
    endcase
end

`endif


endmodule
