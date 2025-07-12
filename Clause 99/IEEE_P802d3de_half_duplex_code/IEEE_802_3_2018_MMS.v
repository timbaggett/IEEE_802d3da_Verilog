/**********************************************************************/
/*                          IEEE_802_3_2018                           */
/**********************************************************************/
/*                                                                    */
/*        Module: IEEE_802_3_2018_MMS.v                               */
/*        Date:   01/05/2021                                          */
/*                                                                    */
/**********************************************************************/

module MMS();

`include "Clause 6/code/IEEE_802_3_2018_PLS_param.v"
`include "Clause 99/IEEE_P802d3de_half_duplex_code/mod_99_4_7_param.v"

wire[3:0]        mod_99_5_state;
wire[1:0]        txFrame;
wire             resumeTx;
wire[10:0]       fragSize;
wire[1:0]        txFrag;
wire             pAllow;
wire[2:0]        preambleCnt;
wire             pActive;

wire             ipg_timer_done;
wire             verify_timer_done;
wire             ipg_timer_not_done;
wire             verify_timer_not_done;

wire[4:0]        mod_99_6_state;
wire[1:0]        nxtRxFrag;

wire[3:0]        mod_99_7_state;	

wire[2:0]        mod_99_8a_state;
wire             verified;
wire             verify_fail;
wire[1:0]        verifyCnt;

wire             mod_99_8b_state;

/*                                                                    */
/* Varibles driven by multiple state diagrams.                        */
/*                                                                    */

reg              rcv_v;
reg              rcv_r;
reg              send_v;
reg              send_r;


/*                                                                    */
/* pEnable                                                            */
/* Boolean  variable  that  is  set  TRUE to  enable  the  preemption */
/* capability and set FALSE to disable the preemption capability.     */
/*                                                                    */

reg pEnable;
initial pEnable = FALSE;


/*                                                                    */
/* disableVerify                                                      */
/* Boolean   variable  that  is   set    by  management  to   control */
/* verification of preemption operation  (see 99.4.3).  TRUE disables */
/* verification and FALSE enables verification.                       */
/*                                                                    */

reg disableVerify;
initial disableVerify = TRUE;


/*                                                                    */
/* link_fail                                                          */
/* Boolean  variable  that  is  TRUE  when  the  MAC  Merge  sublayer */
/* receives indication of link failure. FALSE otherwise.              */
/*                                                                    */

reg link_fail;
initial link_fail = TRUE;


/*                                                                    */
/* begin                                                              */
/* Boolean variable  that  is  set TRUE  by  implementation dependent */
/* means to initialize the state machines.                            */
/*                                                                    */

reg reset_begin;
initial reset_begin = TRUE;


/*                                                                    */
/* Carrier fixes for half duplex                                      */
/*                                                                    */

reg  enableMMSFix;

always @(mod_99_5_state)
begin
    if((mod_99_5_state == mod_inst_99_5.P_TX_COMPLETE) && preempt && enableMMSFix)
    begin
        RS.TX_ER <= #400 true;
    end
end

always @(mod_99_5_state)
begin
    if((mod_99_5_state == mod_inst_99_5.RESUME_WAIT)  && enableMMSFix)
    begin
        RS.TX_ER <= true;
    end
end

always @(mod_99_5_state)
begin
    if(((mod_99_5_state == mod_inst_99_5.RESUME_WAIT) ||
        (mod_99_5_state == mod_inst_99_5.IDLE_TX_PROC))  && enableMMSFix)
    begin
        ePLS.CARRIER_STATUS = CARRIER_OFF;
        -> ePLS.PLS_CARRIER_indication;
    end
end


always @(mod_99_5_state)
begin
    if((mod_99_5_state == mod_inst_99_5.mod_inst_99_5.EXPRESS_TX)  && enableMMSFix)
    begin
        ePLS.CARRIER_STATUS = CARRIER_ON;
        -> ePLS.PLS_CARRIER_indication;
    end
end

always @(mod_99_5_state)
begin
    if(((mod_99_5_state == mod_inst_99_5.RESUME_PREAMBLE) ||
        (mod_99_5_state == mod_inst_99_5.EXPRESS_TX))  && enableMMSFix)
    begin
        RS.TX_ER <= #400 false;
    end
end


/*                                                                    */
/* PLS_CARRIER_indication                                             */
/* If  a  PLS_CARRIER.indication      is   received   from  the  PLS, */
/* PLS_CARRIER.indications with the same CARRIER_STATUS shall be sent */
/* to the pMAC and the eMAC.                                          */
/*                                                                    */

event            PLS_CARRIER_indication;
reg              CARRIER_STATUS;

always @(PLS_CARRIER_indication)
begin

    if(!enableMMSFix)
    begin
        ePLS.CARRIER_STATUS = CARRIER_STATUS;   // See above
        -> ePLS.PLS_CARRIER_indication;         // See above
    end

    pPLS.CARRIER_STATUS = CARRIER_STATUS;
    -> pPLS.PLS_CARRIER_indication;

end

event            PLS_DATA_request;
reg[1:0]         OUTPUT_UNIT;
event            PLS_DATA_request_serviced;

event            PLS_SIGNAL_indication;
reg              SIGNAL_STATUS;

always @(PLS_SIGNAL_indication)
begin
    ePLS.SIGNAL_STATUS = SIGNAL_STATUS;
    -> ePLS.PLS_SIGNAL_indication;

    pPLS.SIGNAL_STATUS = SIGNAL_STATUS;
    -> pPLS.PLS_SIGNAL_indication;

end


/*                                                                    */
/* rRxDv                                                              */
/* Boolean variable that  is set TRUE when rPLS_DATA_VALID.indication */
/* is  received   with  the value DATA_VALID  and   set  FALSE   when */
/* rPLS_DATA_VALID.indication    is       received  with the    value */
/* DATA_NOT_VALID.                                                    */
/*                                                                    */
/* rRxDv derived after 32-bit delay due  to  the RX_MCRC_CK prescient */
/* function.                                                          */
/*                                                                    */

event            PLS_DATA_VALID_indication;
reg              DATA_VALID_STATUS;

event            PLS_DATA_VALID_indication_32bitTimes;
reg              PLS_DATA_VALID_indication_toggle;
reg              PLS_DATA_VALID_indication_toggle_32bitTimes;
reg              DATA_VALID_STATUS_32bitTimes;
reg              rRxDv;

initial PLS_DATA_VALID_indication_toggle = 1'b0;
always @(PLS_DATA_VALID_indication) PLS_DATA_VALID_indication_toggle = !PLS_DATA_VALID_indication_toggle;

always @(PLS_DATA_VALID_indication_toggle) PLS_DATA_VALID_indication_toggle_32bitTimes <= #(32 * top.bitTime) PLS_DATA_VALID_indication_toggle;
always @(DATA_VALID_STATUS) DATA_VALID_STATUS_32bitTimes <= #(32 * top.bitTime) DATA_VALID_STATUS;

always @(PLS_DATA_VALID_indication_toggle_32bitTimes) -> PLS_DATA_VALID_indication_32bitTimes;

always @(PLS_DATA_VALID_indication_32bitTimes)
begin
    if(DATA_VALID_STATUS_32bitTimes == DATA_VALID)
    begin
        rRxDv = true;
    end
    else if(DATA_VALID_STATUS_32bitTimes == DATA_NOT_VALID)
    begin
        rRxDv = false;
    end
    else
    begin
        rRxDv = 1'bx;
    end
end

/*                                                                    */
/* Provide a delay of PLS_DATA_indication and INPUT_UNIT due  to  the */
/* RX_MCRC_CK prescient function.                                     */

event            PLS_DATA_indication;
reg              INPUT_UNIT;

event            PLS_DATA_indication_32bitTimes;
reg              PLS_DATA_indication_toggle;
reg              PLS_DATA_indication_toggle_32bitTimes;
reg              INPUT_UNIT_32bitTimes;

initial PLS_DATA_indication_toggle = 1'b0;
always @(PLS_DATA_indication) PLS_DATA_indication_toggle = !PLS_DATA_indication_toggle;

always @(PLS_DATA_indication_toggle) PLS_DATA_indication_toggle_32bitTimes <= #(32 * top.bitTime) PLS_DATA_indication_toggle;
always @(INPUT_UNIT) INPUT_UNIT_32bitTimes <= #(32 * top.bitTime) INPUT_UNIT;

always @(PLS_DATA_indication_toggle_32bitTimes) -> PLS_DATA_indication_32bitTimes;


/*                                                                    */
/* eTx                                                                */
/* Boolean variable that is  TRUE when an  ePLS_DATA.request has been */
/* received  and acorresponding rPLS_DATA.request has  not  yet  been */
/* generated. FALSE otherwise.                                        */
/*                                                                    */
/*                                                                    */

reg              eTx;

always @(reset_begin)
begin
    if(reset_begin)
    begin
        force eTx        = false;
    end
    else
    begin
        release eTx;
    end
end

always @(MMS.mod_inst_99_4_7_func.etx_bit_count)
begin
    if (MMS.mod_inst_99_4_7_func.etx_bit_count > 3'b000)
    begin
        eTx = true;
    end
    else
    begin
        eTx = false;
    end
end

/*                                                                    */
/* pTX                                                                */
/*                                                                    */
/* Boolean  variable that  is  TRUE when a pPLS_DATA.request has been */
/* received and acorresponding  rPLS_DATA.request  has not  yet  been */
/* generated. FALSE otherwise.                                        */
/*                                                                    */

reg              pTX;

always @(reset_begin)
begin
    if(reset_begin)
    begin
        force pTX        = false;
    end
    else
    begin
        release pTX;
    end
end

always @(MMS.mod_inst_99_4_7_func.ptx_bit_count)
begin
    if (MMS.mod_inst_99_4_7_func.ptx_bit_count > 3'b000)
    begin
        pTX = true;
    end
    else
    begin
        pTX = false;
    end
end


/*                                                                    */
/* pTxCplt                                                            */
/* Boolean variable that is set TRUE when pPLS_DATA.request with  the */
/* value DATA_COMPLETE is  received  and set  FALSE  when the  end of */
/* packet has been processed.                                         */
/*                                                                    */

reg              pTxCplt;

always @(pPLS.PLS_DATA_request)
begin
    if(pPLS.OUTPUT_UNIT == MMS.DATA_COMPLETE)
    begin
        pTxCplt = true;
    end
    else
    begin
        pTxCplt = false;
    end
end

/*                                                                    */
/* eTxCplt                                                            */
/* Boolean variable that is set TRUE when ePLS_DATA.request with  the */
/* value DATA_COMPLETE is  received  and set  FALSE  when the  end of */
/* packet has been processed.                                         */
/*                                                                    */

always @(ePLS.PLS_DATA_request)
begin
    if(ePLS.OUTPUT_UNIT == MMS.DATA_COMPLETE)
    begin
        mod_inst_99_5.eTxCplt = true;
    end
    else
    begin
        mod_inst_99_5.eTxCplt = false;
    end
end

/*                                                                    */
/* addFragSize                                                        */
/* An integer in the  range 0:3 that  controls  the minimum non-final */
/* mPacket length,  as  specified in99.4.4. Set to the  value of  the */
/* addFragSize field in the received  Additional EthernetCapabilities */
/* TLV (see 79.3.7).                                                  */
/*                                                                    */

reg[1:0]         addFragSize;

initial
begin
    addFragSize = 2'b00;
end


/*                                                                    */
/* preemptableFragSize                                                */
/* Boolean  variable that is TRUE  when a enough  bits of the current */
/* preemptable  packet  have been transmitted  to  allow  it  to   be */
/* preempted.  The  value  of  preemptableFragSize  is:  fragSize  >= */
/* (minFrag x (1 + addFragSize) – 4).                                 */
/*                                                                    */

reg              preemptableFragSize;

always @(fragSize)
begin
    if(fragSize >= (minFrag * (1 + addFragSize) - 4))
    begin
        preemptableFragSize = true;
    end
    else
    begin
        preemptableFragSize = false;
    end
end


/*                                                                    */
/* preempt                                                            */
/* Boolean  that  is  TRUE  when  a   preemptable  packet  is  to  be */
/* preempted.  The  value  of  preempt  is: pAllow * (eTx  =  hold) * */
/* preemptableFragSize * MIN_REMAIN.                                  */
/*                                                                    */

assign  preempt = pAllow && (eTx || hold) && preemptableFragSize && MIN_REMAIN;

/////////////
/// PATCH ///
/////////////

initial
begin
    force mod_inst_99_5.hold = false;
end


/*                                                                    */
/* MIN_REMAIN                                                         */
/* Prescient  function to check if enough  octets of the current pMAC */
/* packet  remain  meet  the minimum  fragment     requirement  after */
/* preemption. Produces a Boolean value as follows:                   */
/* TRUE  minFrag octets are left to transmit                          */
/* FALSE Otherwise                                                    */
/*                                                                    */

reg MIN_REMAIN;

always @(pMAC.currentTransmitBit)
begin
    if(((pMAC.lastTransmitBit - pMAC.currentTransmitBit)/8) > minFrag)
    begin
        MIN_REMAIN = true;
    end
    else
    begin
        MIN_REMAIN = false;
    end
end

/*                                                                    */
/* pActive                                                            */
/* Boolean variable that  is TRUE  when  the preemption capability is */
/* active  and FALSE  otherwise.  The value of  pActive is  pEnable * */
/* (verified + disableVerify).                                        */
/*                                                                    */

assign pActive = pEnable && (verified || disableVerify);



/**********************************************************************/
/*                                                                    */
/* SMD_DECODE_task task                                               */
/* Decodes  the   value  of  8  rPLS_DATA.indication   primitives  by */
/* producing  an  8-bit  vector  andreturning  one  of  the following */
/* values based on the value of the vector (see Table 99–1):          */
/*                                                                    */
/* Preamble 0x55                                                      */
/* E        SMD-E encoding                                            */
/* S        SMD-S encoding                                            */
/* C        SMD-C encoding                                            */
/* V        SMD-V encoding                                            */
/* R        SMD-R encoding                                            */
/* ERR      Any other value - error                                   */
/*                                                                    */
/* If S is returned, the  function sets rxFrameCnt equal to the frame */
/* count indicated by the SMD-S. If C  is returned, the function sets */
/* cFrameCnt equal to the frame count indicated by the SMD-C.         */
/*                                                                    */
/**********************************************************************/

reg           Pream;
reg           E;
reg           S;
reg           C;
reg           V;
reg           R;
reg           ERR;

reg[1:0]      rxFrameCnt;
reg[1:0]      cFrameCnt;
reg[2:0]      rxFragCnt;


/*                                                                    */
/* keepSafterD                                                        */
/* Boolean variable that indicates  whether an implementation is able */
/* to  process  the  start of  apacket  while discarding  an  errored */
/* packet.  When  an  SMD-S  is received  while Receiveprocessing  is */
/* waiting for the next mPacket of a preempted  packet, the preempted */
/* packet   isdiscarded.     The  value  TRUE  indicates    that   an */
/* implementation is able to process the new packetwhen this occurs.  */
/*                                                                    */

reg           keepSafterD;

initial       keepSafterD = false;

mod_99_5 mod_inst_99_5(
                 .reset_begin(reset_begin),
                 .send_r(send_r),
                 .send_v(send_v),
                 .ipg_timer_done(ipg_timer_done),
                 .eTx(eTx),
                 .pTX(pTX),
                 .hold(hold),
                 .pTxCplt(pTxCplt),
                 .preempt(preempt),
                 .pActive(pActive),

                 .mod_99_5_state(mod_99_5_state),
                 .txFrame(txFrame),
                 .resumeTx(resumeTx),
                 .fragSize(fragSize),
                 .txFrag(txFrag),
                 .eTxCplt(eTxCplt),
                 .pAllow(pAllow),
                 .preambleCnt(preambleCnt)
                 );

mod_99_6 mod_inst_99_6(
                 .reset_begin(reset_begin),
                 .rRxDv(rRxDv),
                 .Pream(Pream),
                 .S(S),
                 .C(C),
                 .ERR(ERR),
                 .E(E),
                 .V(V),
                 .R(R),
                 .cFrameCnt(cFrameCnt),
                 .keepSafterD(keepSafterD),
                 .rxFragCnt(rxFragCnt),
                 .rxFrameCnt(rxFrameCnt),

                 .mod_99_6_state(mod_99_6_state),
                 .nxtRxFrag(nxtRxFrag)
                 );

mod_99_7 mod_inst_99_7(
                 .reset_begin(reset_begin),
                 .rRxDv(rRxDv),
                 .Pream(Pream),
                 .E(E),
                 .V(V),
                 .R(R),
                 .S(S),
                 .C(C),
                 .ERR(ERR),

                 .mod_99_7_state(mod_99_7_state)
                 );
	
mod_99_4_7_timer mod_inst_99_4_7_timer(
                .ipg_timer_done(ipg_timer_done),
                .verify_timer_done(verify_timer_done),
                .ipg_timer_not_done(ipg_timer_not_done),
                .verify_timer_not_done(verify_timer_not_done)
                 );

mod_99_8a mod_inst_99_8a(
                 .reset_begin(reset_begin),
                 .link_fail(link_fail),
                 .disableVerify(disableVerify),
                 .pEnable(pEnable),
                 .send_v(send_v),
                 .verify_timer_done(verify_timer_done),
                 .rcv_r(rcv_r),

                 .mod_99_8a_state(mod_99_8a_state),
                 .verified(verified),
                 .verify_fail(verify_fail),
                 .verifyCnt(verifyCnt)
                 );

mod_99_8b mod_inst_99_8b(
                 .reset_begin(reset_begin),
                 .rcv_v(rcv_v),
                 .send_r(send_r),

                 .mod_99_8b_state(mod_99_8b_state)
                 );

mod_99_4_7_func mod_inst_99_4_7_func(
                 .reset_begin(reset_begin)
                 );

endmodule
