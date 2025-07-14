/**********************************************************************/
/*                           IEEE P802.3br                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_99_6.v                                          */
/*        Date:   30/01/2022                                          */
/*                                                                    */
/**********************************************************************/

module           mod_99_6(

                 reset_begin,
                 rRxDv,
                 Pream,
                 S,
                 C,
                 ERR,
                 E,
                 V,
                 R,
                 keepSafterD,
                 cFrameCnt,
                 rxFragCnt,
                 rxFrameCnt,

                 mod_99_6_state,
                 nxtRxFrag
                 );

input            reset_begin;
input            rRxDv;
input            Pream;
input            S;
input            C;
input            ERR;
input            E;
input            V;
input            R;
input            keepSafterD;
input[1:0]       cFrameCnt;
input[2:0]       rxFragCnt;
input[1:0]       rxFrameCnt;

output[4:0]      mod_99_6_state;
output[1:0]      nxtRxFrag;

reg[4:0]         mod_99_6_state;
reg[4:0]         mod_99_6_state_1;
reg[4:0]         mod_99_6_state_2;
reg[4:0]         mod_99_6_state_3;
reg[4:0]         next_mod_99_6_state;
reg[1:0]         nxtRxFrag;

`ifdef simulate
`include "Clause_99/IEEE_P802d3de_half_duplex_code/IEEE_P802_3br_param.v"
`include "Clause_99/IEEE_P802d3de_half_duplex_code/mod_99_4_7_param.v"
`include "Clause_99/IEEE_P802d3de_half_duplex_code/mod_99_6_func.v"


parameter        null                =  1'b0;

parameter        INIT_RX_PROC        =  5'b00000;
parameter        IDLE_RX_PROC        =  5'b00001;
parameter        pMAC_DATA_VALID     =  5'b00010;
parameter        CHECK_FOR_START     =  5'b00011;
parameter        RX_PREAMBLE         =  5'b00100;
parameter        REPLACE_SMD         =  5'b00101;
parameter        BAD_FRAG            =  5'b00110;
parameter        EXPRESS             =  5'b00111;
parameter        P_RECEIVE_DATA      =  5'b01000;
parameter        WAIT_FOR_DV_FALSE   =  5'b01001;
parameter        FRAME_COMPLETE      =  5'b01010;
parameter        WAIT_FOR_RESUME     =  5'b01011;
parameter        CHECK_FOR_RESUME    =  5'b01100;
parameter        DISCARD_KEEP_S      =  5'b01101;
parameter        CHECK_FRAG_CNT      =  5'b01110;
parameter        INCREMENT_FRAG_CNT  =  5'b01111;
parameter        ASSEMBLY_ERROR      =  5'b10000;

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

always@(mod_99_6_state, reset_begin, rRxDv, Pream, S, C, ERR, E, V, R, keepSafterD, cFrameCnt, rxFragCnt, rxFrameCnt, MMS.mod_inst_99_4_7_func.rByteReady, MMS.mod_inst_99_4_7_func.pRxByteSent)

begin

    next_mod_99_6_state <= mod_99_6_state;

    if(reset_begin)
    begin
        next_mod_99_6_state <= !INIT_RX_PROC;
        next_mod_99_6_state <= INIT_RX_PROC;
    end

    else
    begin

    case(mod_99_6_state)

    INIT_RX_PROC:
    begin
        if(!rRxDv)
        begin
            next_mod_99_6_state <= IDLE_RX_PROC;
        end
    end

    IDLE_RX_PROC:
    begin
        if(rRxDv)
        begin
            next_mod_99_6_state <= pMAC_DATA_VALID;
        end
    end

    pMAC_DATA_VALID:
    begin
        if(MMS.mod_inst_99_4_7_func.rByteReady)
        begin
            next_mod_99_6_state <= CHECK_FOR_START;
        end
    end

    CHECK_FOR_START:
    begin
        if(Pream)
        begin
            next_mod_99_6_state <= RX_PREAMBLE;
        end
        if(S)
        begin
            next_mod_99_6_state <= REPLACE_SMD;
        end
        if(C || ERR)
        begin
            next_mod_99_6_state <= BAD_FRAG;
        end
        if(E || V || R)
        begin
            next_mod_99_6_state <= EXPRESS;
        end
    end

    RX_PREAMBLE:
    begin
        if(MMS.mod_inst_99_4_7_func.rByteReady && MMS.mod_inst_99_4_7_func.pRxByteSent)
        begin
            next_mod_99_6_state <= CHECK_FOR_START;
        end
    end

    REPLACE_SMD:
    begin
        if(MMS.mod_inst_99_4_7_func.rByteReady && MMS.mod_inst_99_4_7_func.pRxByteSent)
        begin
            next_mod_99_6_state <= P_RECEIVE_DATA;
        end
    end

    BAD_FRAG:
    begin
        if(!rRxDv)
        begin
            next_mod_99_6_state <= IDLE_RX_PROC;
        end
    end

    EXPRESS:
    begin
        if(!rRxDv)
        begin
            next_mod_99_6_state <= IDLE_RX_PROC;
        end
    end

    P_RECEIVE_DATA:
    begin
        if(rRxDv && !RX_MCRC_CK(null) && MMS.mod_inst_99_4_7_func.rByteReady && MMS.mod_inst_99_4_7_func.pRxByteSent)
        begin
            next_mod_99_6_state <= !P_RECEIVE_DATA;
            next_mod_99_6_state <= P_RECEIVE_DATA;
        end
        if(RX_MCRC_CK(null))
        begin
            next_mod_99_6_state <= WAIT_FOR_DV_FALSE;
        end
        if(!rRxDv)
        begin
            next_mod_99_6_state <= FRAME_COMPLETE;
        end
    end

    WAIT_FOR_DV_FALSE:
    begin
        if(!rRxDv)
        begin
            next_mod_99_6_state <= WAIT_FOR_RESUME;
        end
    end

    FRAME_COMPLETE:
    begin
        begin
            next_mod_99_6_state <= IDLE_RX_PROC;
        end
    end

    WAIT_FOR_RESUME:
    begin
        if(rRxDv && MMS.mod_inst_99_4_7_func.rByteReady)
        begin
            next_mod_99_6_state <= CHECK_FOR_RESUME;
        end
    end

    CHECK_FOR_RESUME:
    begin
        if(E || ERR)
        begin
            next_mod_99_6_state <= WAIT_FOR_DV_FALSE;
        end
        if(Pream && MMS.mod_inst_99_4_7_func.rByteReady)
        begin
            next_mod_99_6_state <= !CHECK_FOR_RESUME;
            next_mod_99_6_state <= CHECK_FOR_RESUME;
        end
        if(S && keepSafterD)
        begin
            next_mod_99_6_state <= DISCARD_KEEP_S;
        end
        if(C && (cFrameCnt == rxFrameCnt) && MMS.mod_inst_99_4_7_func.rByteReady)
        begin
            next_mod_99_6_state <= CHECK_FRAG_CNT;
        end
        if((S && !keepSafterD)|| (C && cFrameCnt != rxFrameCnt))
        begin
            next_mod_99_6_state <= ASSEMBLY_ERROR;
        end
    end

    DISCARD_KEEP_S:
    begin
        begin
            next_mod_99_6_state <= REPLACE_SMD;
        end
    end

    CHECK_FRAG_CNT:
    begin
        if((rxFragCnt == nxtRxFrag) && MMS.mod_inst_99_4_7_func.rByteReady)
        begin
            next_mod_99_6_state <= INCREMENT_FRAG_CNT;
        end
        if(rxFragCnt != nxtRxFrag)
        begin
            next_mod_99_6_state <= ASSEMBLY_ERROR;
        end
    end

    INCREMENT_FRAG_CNT:
    begin
        begin
            next_mod_99_6_state <= P_RECEIVE_DATA;
        end
    end

    ASSEMBLY_ERROR:
    begin
        if(!rRxDv)
        begin
            next_mod_99_6_state <= IDLE_RX_PROC;
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

always@(next_mod_99_6_state)

begin

    case(next_mod_99_6_state)

    IDLE_RX_PROC:
    begin
        nxtRxFrag = 0;
    end

    pMAC_DATA_VALID:
    begin
        pRX_DV(TRUE);
    end

    CHECK_FOR_START:
    begin
        SMD_DECODE(rRX_DATA(null));
    end

    RX_PREAMBLE:
    begin
        pRX_DATA(PREAMBLE);
    end

    REPLACE_SMD:
    begin
        pRX_DATA(SFD);
    end

    BAD_FRAG:
    begin
        pRX_DV(FALSE);
    end

    EXPRESS:
    begin
        pRX_DV(FALSE);
    end

    P_RECEIVE_DATA:
    begin
        pRX_DATA(rRX_DATA(null));
    end

    FRAME_COMPLETE:
    begin
        pRX_DV(FALSE);
    end

    CHECK_FOR_RESUME:
    begin
        SMD_DECODE(rRX_DATA(null));
    end

    DISCARD_KEEP_S:
    begin
        DISCARD();
    end

    CHECK_FRAG_CNT:
    begin
        FRAG_DECODE(rRX_DATA(null));
    end

    INCREMENT_FRAG_CNT:
    begin
        nxtRxFrag = nxtRxFrag + 1;
    end

    ASSEMBLY_ERROR:
    begin
        DISCARD();
    end

    endcase

    mod_99_6_state_3 = mod_99_6_state_2;
    mod_99_6_state_2 = mod_99_6_state_1;
    mod_99_6_state_1 = mod_99_6_state;
    mod_99_6_state = next_mod_99_6_state;
end



reg [143:0]       mod_99_6_state_ASCII;

always@(mod_99_6_state)
begin
    casex(mod_99_6_state)
        5'b00000 : mod_99_6_state_ASCII = "INIT_RX_PROC";
        5'b00001 : mod_99_6_state_ASCII = "IDLE_RX_PROC";
        5'b00010 : mod_99_6_state_ASCII = "pMAC_DATA_VALID";
        5'b00011 : mod_99_6_state_ASCII = "CHECK_FOR_START";
        5'b00100 : mod_99_6_state_ASCII = "RX_PREAMBLE";
        5'b00101 : mod_99_6_state_ASCII = "REPLACE_SMD";
        5'b00110 : mod_99_6_state_ASCII = "BAD_FRAG";
        5'b00111 : mod_99_6_state_ASCII = "EXPRESS";
        5'b01000 : mod_99_6_state_ASCII = "P_RECEIVE_DATA";
        5'b01001 : mod_99_6_state_ASCII = "WAIT_FOR_DV_FALSE";
        5'b01010 : mod_99_6_state_ASCII = "FRAME_COMPLETE";
        5'b01011 : mod_99_6_state_ASCII = "WAIT_FOR_RESUME";
        5'b01100 : mod_99_6_state_ASCII = "CHECK_FOR_RESUME";
        5'b01101 : mod_99_6_state_ASCII = "DISCARD_KEEP_S";
        5'b01110 : mod_99_6_state_ASCII = "CHECK_FRAG_CNT";
        5'b01111 : mod_99_6_state_ASCII = "INCREMENT_FRAG_CNT";
        5'b10000 : mod_99_6_state_ASCII = "ASSEMBLY_ERROR";
    endcase
end

`endif


endmodule

