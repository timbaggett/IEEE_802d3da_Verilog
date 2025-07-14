/**********************************************************************/
/*                           IEEE P802.3br                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_99_7.v                                          */
/*        Date:   30/01/2022                                          */
/*                                                                    */
/**********************************************************************/

module           mod_99_7(

                 reset_begin,
                 rRxDv,
                 Pream,
                 E,
                 V,
                 R,
                 S,
                 C,
                 ERR,

                 mod_99_7_state
                 );

input            reset_begin;
input            rRxDv;
input            Pream;
input            E;
input            V;
input            R;
input            S;
input            C;
input            ERR;

output[3:0]      mod_99_7_state;

reg[3:0]         mod_99_7_state;
reg[3:0]         next_mod_99_7_state;

`ifdef simulate
`include "Clause_99/IEEE_P802d3de_half_duplex_code/IEEE_P802_3br_param.v"
`include "Clause_99/IEEE_P802d3de_half_duplex_code/mod_99_4_7_param.v"
`include "Clause_99/IEEE_P802d3de_half_duplex_code/mod_99_7_func.v"

parameter        null                =  1'b0;


parameter        INIT_EXPRESS_FILTER =  4'b0000;
parameter        EXPRESS_FILTER_IDLE =  4'b0001;
parameter        eMAC_RECEIVE_DATA_VALID =  4'b0010;
parameter        CHECK_FOR_EXPRESS   =  4'b0011;
parameter        EXPRESS_PREAMBLE    =  4'b0100;
parameter        SFD_STATE           =  4'b0101;
parameter        RCV_V               =  4'b0110;
parameter        RCV_R               =  4'b0111;
parameter        V_MCRC_OK           =  4'b1000;
parameter        R_MCRC_OK           =  4'b1001;
parameter        E_RECEIVE_DATA      =  4'b1010;
parameter        NOT_EXPRESS         =  4'b1011;

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

always@(mod_99_7_state, reset_begin, rRxDv, Pream, E, V, R, S, C, ERR, MMS.mod_inst_99_4_7_func.rByteReady, MMS.mod_inst_99_4_7_func.pRxByteSent, RX_MCRC_CK_change)

begin

    next_mod_99_7_state <= mod_99_7_state;

    if(reset_begin)
    begin
        next_mod_99_7_state <= !INIT_EXPRESS_FILTER;
        next_mod_99_7_state <= INIT_EXPRESS_FILTER;
    end

    else
    begin

    case(mod_99_7_state)

    INIT_EXPRESS_FILTER:
    begin
        if(!rRxDv)
        begin
            next_mod_99_7_state <= EXPRESS_FILTER_IDLE;
        end
    end

    EXPRESS_FILTER_IDLE:
    begin
        if(rRxDv)
        begin
            next_mod_99_7_state <= eMAC_RECEIVE_DATA_VALID;
        end
    end

    eMAC_RECEIVE_DATA_VALID:
    begin
        if(MMS.mod_inst_99_4_7_func.rByteReady)
        begin
            next_mod_99_7_state <= CHECK_FOR_EXPRESS;
        end
    end

    CHECK_FOR_EXPRESS:
    begin
        if(Pream)
        begin
            next_mod_99_7_state <= EXPRESS_PREAMBLE;
        end
        if(E)
        begin
            next_mod_99_7_state <= SFD_STATE;
        end
        if(V)
        begin
            next_mod_99_7_state <= RCV_V;
        end
        if(R)
        begin
            next_mod_99_7_state <= RCV_R;
        end
        if(S || C || ERR)
        begin
            next_mod_99_7_state <= NOT_EXPRESS;
        end
    end

    EXPRESS_PREAMBLE:
    begin
        if(MMS.mod_inst_99_4_7_func.rByteReady && MMS.mod_inst_99_4_7_func.eRxByteSent)
        begin
            next_mod_99_7_state <= CHECK_FOR_EXPRESS;
        end
    end

    SFD_STATE:
    begin
        if(MMS.mod_inst_99_4_7_func.eRxByteSent)
        begin 
            next_mod_99_7_state <= E_RECEIVE_DATA;
        end
    end

    RCV_V:
    begin
        if(!rRxDv)
        begin
            next_mod_99_7_state <= INIT_EXPRESS_FILTER;
        end
        if(RX_MCRC_CK(null))
        begin
            next_mod_99_7_state <= V_MCRC_OK;
        end
    end

    RCV_R:
    begin
        if(!rRxDv)
        begin
            next_mod_99_7_state <= INIT_EXPRESS_FILTER;
        end
        if(RX_MCRC_CK(null))
        begin
            next_mod_99_7_state <= R_MCRC_OK;
        end
    end

    V_MCRC_OK:
    begin
        if(!rRxDv)
        begin
            next_mod_99_7_state <= INIT_EXPRESS_FILTER;
        end
    end

    R_MCRC_OK:
    begin
        if(!rRxDv)
        begin
            next_mod_99_7_state <= INIT_EXPRESS_FILTER;
        end
    end

    E_RECEIVE_DATA:
    begin
        if(!rRxDv)
        begin
            next_mod_99_7_state <= EXPRESS_FILTER_IDLE;
        end
        if(rRxDv && MMS.mod_inst_99_4_7_func.rByteReady && MMS.mod_inst_99_4_7_func.eRxByteSent)
        begin
            next_mod_99_7_state <= !E_RECEIVE_DATA;
            next_mod_99_7_state <= E_RECEIVE_DATA;
        end
    end

    NOT_EXPRESS:
    begin
        if(!rRxDv)
        begin
            next_mod_99_7_state <= INIT_EXPRESS_FILTER;
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

always@(next_mod_99_7_state)

begin

    case(next_mod_99_7_state)

    EXPRESS_FILTER_IDLE:
    begin
        eRX_DV(FALSE);
    end

    eMAC_RECEIVE_DATA_VALID:
    begin
        eRX_DV(TRUE);
    end

    CHECK_FOR_EXPRESS:
    begin
        SMD_DECODE(rRX_DATA(null));
    end

    EXPRESS_PREAMBLE:
    begin
        eRX_DATA(PREAMBLE);
    end

    SFD_STATE:
    begin
        eRX_DATA(SFD);
    end

    RCV_V:
    begin
        eRX_DV(FALSE);
    end

    RCV_R:
    begin
        eRX_DV(FALSE);
    end

    V_MCRC_OK:
    begin
        MMS.rcv_v = TRUE;
    end

    R_MCRC_OK:
    begin
        MMS.rcv_r = TRUE;
    end

    E_RECEIVE_DATA:
    begin
        eRX_DATA(rRX_DATA(null));
    end

    endcase

    mod_99_7_state = next_mod_99_7_state;

end



reg [183:0]       mod_99_7_state_ASCII;

always@(mod_99_7_state)
begin
    casex(mod_99_7_state)
        4'b0000 : mod_99_7_state_ASCII = "INIT_EXPRESS_FILTER";
        4'b0001 : mod_99_7_state_ASCII = "EXPRESS_FILTER_IDLE";
        4'b0010 : mod_99_7_state_ASCII = "eMAC_RECEIVE_DATA_VALID";
        4'b0011 : mod_99_7_state_ASCII = "CHECK_FOR_EXPRESS";
        4'b0100 : mod_99_7_state_ASCII = "EXPRESS_PREAMBLE";
        4'b0101 : mod_99_7_state_ASCII = "SFD_STATE";
        4'b0110 : mod_99_7_state_ASCII = "RCV_V";
        4'b0111 : mod_99_7_state_ASCII = "RCV_R";
        4'b1000 : mod_99_7_state_ASCII = "V_MCRC_OK";
        4'b1001 : mod_99_7_state_ASCII = "R_MCRC_OK";
        4'b1010 : mod_99_7_state_ASCII = "E_RECEIVE_DATA";
        4'b1011 : mod_99_7_state_ASCII = "NOT_EXPRESS";
    endcase
end

`endif


endmodule

