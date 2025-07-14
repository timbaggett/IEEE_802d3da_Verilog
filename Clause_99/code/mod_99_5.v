/**********************************************************************/
/*                           IEEE P802.3br                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_99_5.v                                          */
/*        Date:   17/01/2022                                          */
/*                                                                    */
/**********************************************************************/

module           mod_99_5(

                 reset_begin,
                 ipg_timer_done,
                 eTx,
                 pTX,
                 hold,
                 pTxCplt,
                 preempt,
                 pActive,
                 send_v,
                 send_r,

                 mod_99_5_state,
                 txFrame,
                 resumeTx,
                 fragSize,
                 txFrag,
                 eTxCplt,
                 pAllow,
                 preambleCnt
                 );

input            reset_begin;
input            ipg_timer_done;
input            eTx;
input            pTX;
input            hold;
input            pTxCplt;
input            preempt;
input            pActive;
input            send_v;
input            send_r;

output[3:0]      mod_99_5_state;
output[1:0]      txFrame;
output           resumeTx;
output[10:0]     fragSize;
output[1:0]      txFrag;
output           eTxCplt;
output           pAllow;
output[2:0]      preambleCnt;

reg[3:0]         mod_99_5_state;
reg[3:0]         next_mod_99_5_state;
reg[1:0]         txFrame;
reg              resumeTx;
reg[10:0]        fragSize;
reg[1:0]         txFrag;
reg              eTxCplt;
reg              pAllow;
reg[2:0]         preambleCnt;

`ifdef simulate
`include "Clause_99/code/IEEE_P802_3br_param.v"
`include "Clause_99/code/mod_99_4_7_param.v"
`include "Clause_99/code/mod_99_5_func.v"

parameter        null                =  1'b0;

parameter        INIT_TX_PROC        =  4'b0000;
parameter        IDLE_TX_PROC        =  4'b0001;
parameter        TX_VERIFY           =  4'b0010;
parameter        TX_RESPOND          =  4'b0011;
parameter        EXPRESS_TX          =  4'b0100;
parameter        START_PREAMBLE      =  4'b0101;
parameter        E_TX_COMPLETE       =  4'b0110;
parameter        SEND_SMD_S          =  4'b0111;
parameter        RESUME_WAIT         =  4'b1000;
parameter        PREEMPTABLE_TX      =  4'b1001;
parameter        TX_MCRC_STATE       =  4'b1010;
parameter        RESUME_PREAMBLE     =  4'b1011;
parameter        P_TX_COMPLETE       =  4'b1100;
parameter        SEND_SMD_C          =  4'b1101;
parameter        SEND_FRAG_COUNT     =  4'b1110;

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

always@(mod_99_5_state, reset_begin, send_r, send_v, ipg_timer_done, eTx, pTX, hold, eTxCplt, pTxCplt, preempt, pActive, MMS.mod_inst_99_4_7_func.pByteReady, MMS.mod_inst_99_4_7_func.eByteReady, MMS.mod_inst_99_4_7_func.rTXByteSent, MMS.mod_inst_99_4_7_func.mCRC_sent, MMS.mod_inst_99_4_7_func.data_complete_sent, TX_V_done, TX_R_done)

begin

    next_mod_99_5_state <= mod_99_5_state;

    if(reset_begin)
    begin
        next_mod_99_5_state <= !INIT_TX_PROC;
        next_mod_99_5_state <= INIT_TX_PROC;
    end

    else
    begin

    case(mod_99_5_state)

    INIT_TX_PROC:
    begin
        begin
            next_mod_99_5_state <= IDLE_TX_PROC;
        end
    end

    IDLE_TX_PROC:
    begin
        if(!send_r && send_v && ipg_timer_done && !eTx)
        begin
            next_mod_99_5_state <= TX_VERIFY;
        end
        if(send_r && ipg_timer_done && !eTx)
        begin
            next_mod_99_5_state <= TX_RESPOND;
        end
        if(MMS.mod_inst_99_4_7_func.eByteReady && eTx && ipg_timer_done)
        begin
            next_mod_99_5_state <= EXPRESS_TX;
        end
        if(MMS.mod_inst_99_4_7_func.pByteReady && pTX && !eTx && ipg_timer_done && !hold && !send_v && !send_r)
        begin
            next_mod_99_5_state <= START_PREAMBLE;
        end
    end

    TX_VERIFY:
    begin
        if(TX_V_done == true)
        begin
            next_mod_99_5_state <= IDLE_TX_PROC;
        end
    end

    TX_RESPOND:
    begin
        begin
            next_mod_99_5_state <= IDLE_TX_PROC;
        end
    end

    EXPRESS_TX:
    begin
        if(MMS.mod_inst_99_4_7_func.eByteReady && MMS.mod_inst_99_4_7_func.rTXByteSent && !eTxCplt)
        begin
            next_mod_99_5_state <= !EXPRESS_TX;
            next_mod_99_5_state <= EXPRESS_TX;
        end
        if(MMS.mod_inst_99_4_7_func.rTXByteSent && eTxCplt)
        begin
            next_mod_99_5_state <= E_TX_COMPLETE;
        end
    end

    START_PREAMBLE:
    begin
        if(MMS.mod_inst_99_4_7_func.pByteReady && MMS.mod_inst_99_4_7_func.rTXByteSent && !SFD_DET(null))
        begin
            next_mod_99_5_state <= !START_PREAMBLE;
            next_mod_99_5_state <= START_PREAMBLE;
        end
        if(MMS.mod_inst_99_4_7_func.pByteReady && MMS.mod_inst_99_4_7_func.rTXByteSent && SFD_DET(null))
        begin
            next_mod_99_5_state <= SEND_SMD_S;
        end
    end

    E_TX_COMPLETE:
    begin
        if(!resumeTx)
        begin
            next_mod_99_5_state <= IDLE_TX_PROC;
        end
        if(resumeTx)
        begin
            next_mod_99_5_state <= RESUME_WAIT;
        end
    end

    SEND_SMD_S:
    begin
        if(MMS.mod_inst_99_4_7_func.pByteReady && MMS.mod_inst_99_4_7_func.rTXByteSent)
        begin
            next_mod_99_5_state <= PREEMPTABLE_TX;
        end
    end

    RESUME_WAIT:
    begin
        if(eTx && ipg_timer_done)
        begin
            next_mod_99_5_state <= EXPRESS_TX;
        end
        if(ipg_timer_done && !hold && !eTx)
        begin
            next_mod_99_5_state <= RESUME_PREAMBLE;
        end
    end

    PREEMPTABLE_TX:
    begin
        if(MMS.mod_inst_99_4_7_func.pByteReady && MMS.mod_inst_99_4_7_func.rTXByteSent && !pTxCplt && !preempt)
        begin
            next_mod_99_5_state <= !PREEMPTABLE_TX;
            next_mod_99_5_state <= PREEMPTABLE_TX;
        end
        if(MMS.mod_inst_99_4_7_func.pByteReady && MMS.mod_inst_99_4_7_func.rTXByteSent && preempt)
        begin
            next_mod_99_5_state <= TX_MCRC_STATE;
        end
        if(MMS.mod_inst_99_4_7_func.rTXByteSent && pTxCplt)
        begin
            next_mod_99_5_state <= P_TX_COMPLETE;
        end
    end

    TX_MCRC_STATE:
    begin
        if(MMS.mod_inst_99_4_7_func.mCRC_sent)
        begin 
            next_mod_99_5_state <= P_TX_COMPLETE;
        end
    end

    RESUME_PREAMBLE:
    begin
        if(MMS.mod_inst_99_4_7_func.rTXByteSent && preambleCnt < 6)
        begin
            next_mod_99_5_state <= !RESUME_PREAMBLE;
            next_mod_99_5_state <= RESUME_PREAMBLE;
        end
        if(MMS.mod_inst_99_4_7_func.rTXByteSent && preambleCnt == 6)
        begin
            next_mod_99_5_state <= SEND_SMD_C;
        end
    end

    P_TX_COMPLETE:
    begin
        if(MMS.mod_inst_99_4_7_func.data_complete_sent && pTxCplt)
        begin
            next_mod_99_5_state <= IDLE_TX_PROC;
        end
        if(MMS.mod_inst_99_4_7_func.data_complete_sent && !pTxCplt)
        begin
            next_mod_99_5_state <= RESUME_WAIT;
        end
    end

    SEND_SMD_C:
    begin
        if(MMS.mod_inst_99_4_7_func.rTXByteSent)
        begin
            next_mod_99_5_state <= SEND_FRAG_COUNT;
        end
    end

    SEND_FRAG_COUNT:
    begin
        if(MMS.mod_inst_99_4_7_func.rTXByteSent)
        begin
            next_mod_99_5_state <= PREEMPTABLE_TX;
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

always@(next_mod_99_5_state)

begin

    case(next_mod_99_5_state)

    INIT_TX_PROC:
    begin
        txFrame = 0;
        resumeTx = FALSE;
    end

    IDLE_TX_PROC:
    begin
        fragSize = 0;
        txFrag = 0;
        resumeTx = FALSE;
        -> MMS.mod_inst_99_4_7_timer.ipg_timer.start;
        eTxCplt = FALSE;
    end

    TX_VERIFY:
    begin
        TX_V();
        MMS.send_v = FALSE;
    end

    TX_RESPOND:
    begin
        TX_R();
        MMS.send_r = FALSE;
    end

    EXPRESS_TX:
    begin
        rTX_DATA(eTX_DATA(null));
    end

    START_PREAMBLE:
    begin
        rTX_DATA(pTX_DATA(null));
    end

    E_TX_COMPLETE:
    begin
        rTX_CPLT();
        eTxCplt = FALSE;
    end

    SEND_SMD_S:
    begin
        pAllow = pActive;
        rTX_DATA(SMDS_ENCODE(txFrame));
    end

    RESUME_WAIT:
    begin
        -> MMS.mod_inst_99_4_7_timer.ipg_timer.start;
        preambleCnt = 0;
        resumeTx = TRUE;
    end

    PREEMPTABLE_TX:
    begin
        rTX_DATA(pTX_DATA(null));
        fragSize = fragSize + 1;
    end

    TX_MCRC_STATE:
    begin
        TX_MCRC();
    end

    RESUME_PREAMBLE:
    begin
        rTX_DATA(PREAMBLE);
        preambleCnt = preambleCnt + 1;
    end

    P_TX_COMPLETE:
    begin
        rTX_CPLT();
        if(pTxCplt)
        begin
            txFrame = txFrame + 1;
        end
    end

    SEND_SMD_C:
    begin
        SMDC_ENCODE(txFrame);
        fragSize = 0;
    end

    SEND_FRAG_COUNT:
    begin
        FRAG_ENCODE(txFrag);
        txFrag = txFrag + 1;
    end

    endcase

    mod_99_5_state = next_mod_99_5_state;

end



reg [119:0]       mod_99_5_state_ASCII;

always@(mod_99_5_state)
begin
    casex(mod_99_5_state)
        4'b0000 : mod_99_5_state_ASCII = "INIT_TX_PROC";
        4'b0001 : mod_99_5_state_ASCII = "IDLE_TX_PROC";
        4'b0010 : mod_99_5_state_ASCII = "TX_VERIFY";
        4'b0011 : mod_99_5_state_ASCII = "TX_RESPOND";
        4'b0100 : mod_99_5_state_ASCII = "EXPRESS_TX";
        4'b0101 : mod_99_5_state_ASCII = "START_PREAMBLE";
        4'b0110 : mod_99_5_state_ASCII = "E_TX_COMPLETE";
        4'b0111 : mod_99_5_state_ASCII = "SEND_SMD_S";
        4'b1000 : mod_99_5_state_ASCII = "RESUME_WAIT";
        4'b1001 : mod_99_5_state_ASCII = "PREEMPTABLE_TX";
        4'b1010 : mod_99_5_state_ASCII = "TX_MCRC_STATE";
        4'b1011 : mod_99_5_state_ASCII = "RESUME_PREAMBLE";
        4'b1100 : mod_99_5_state_ASCII = "P_TX_COMPLETE";
        4'b1101 : mod_99_5_state_ASCII = "SEND_SMD_C";
        4'b1110 : mod_99_5_state_ASCII = "SEND_FRAG_COUNT";
    endcase
end

`endif


endmodule

