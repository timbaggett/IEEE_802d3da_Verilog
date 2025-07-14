/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_147_14.v                                        */
/*        Date:   22/06/2019                                          */
/*                                                                    */
/**********************************************************************/

module           mod_147_14(

                 pma_reset,
                 link_control,
                 pcs_status,
                 loc_rcv_status,

                 mod_147_14_state,
                 link_status
                 );

input            pma_reset;
input            link_control;
input            pcs_status;
input            loc_rcv_status;

output           mod_147_14_state;
output           link_status;

reg              mod_147_14_state;
reg              next_mod_147_14_state;
reg              link_status;

`ifdef simulate
`include "Clause_147/code/IEEE_P802_3cg_param.v"
`include "Clause_147/code/mod_147_4_4_param.v"

parameter        LINK_DOWN           =  1'b0;
parameter        LINK_UP             =  1'b1;

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

always@(mod_147_14_state, pma_reset, link_control, pcs_status, loc_rcv_status)

begin

    next_mod_147_14_state <= mod_147_14_state;

    if(pma_reset || (link_control == DISABLE))
    begin
        next_mod_147_14_state <= !LINK_DOWN;
        next_mod_147_14_state <= LINK_DOWN;
    end

    else
    begin

    case(mod_147_14_state)

    LINK_DOWN:
    begin
        if((pcs_status == OK) && loc_rcv_status)
        begin
            next_mod_147_14_state <= LINK_UP;
        end
    end

    LINK_UP:
    begin
        if((pcs_status == NOT_OK) || (!loc_rcv_status))
        begin
            next_mod_147_14_state <= LINK_DOWN;
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

always@(next_mod_147_14_state)

begin

    case(next_mod_147_14_state)

    LINK_DOWN:
    begin
        link_status = FAIL;
    end

    LINK_UP:
    begin
        link_status = OK;
    end

    endcase

    mod_147_14_state = next_mod_147_14_state;

end


reg [55:0]       link_control_ASCII;

always@(link_control)
begin
    casex(link_control)
    1'b0 : link_control_ASCII = "ENABLE";
    1'b1 : link_control_ASCII = "DISABLE";
    endcase
end

reg [47:0]       pcs_status_ASCII;

always@(pcs_status)
begin
    casex(pcs_status)
    1'b0 : pcs_status_ASCII = "OK";
    1'b1 : pcs_status_ASCII = "NOT_OK";
    endcase
end


reg [71:0]       mod_147_14_state_ASCII;

always@(mod_147_14_state)
begin
    casex(mod_147_14_state)
        1'b0 : mod_147_14_state_ASCII = "LINK_DOWN";
        1'b1 : mod_147_14_state_ASCII = "LINK_UP";
    endcase
end

`endif


endmodule

