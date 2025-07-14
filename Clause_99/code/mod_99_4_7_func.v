/**********************************************************************/
/*                           IEEE P802.3br                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_99_4_7_func.v                                   */
/*        Date:   14/01/2022                                          */
/*                                                                    */
/**********************************************************************/

module           mod_99_4_7_func(
                 reset_begin
                 );

input            reset_begin;

`include "Clause_99/IEEE_P802d3de_half_duplex_code/IEEE_P802_3br_param.v"
`include "Clause_99/IEEE_P802d3de_half_duplex_code/mod_99_4_7_param.v"

/**********************************************************************/
/*                                                                    */
/* rTX_CPLT_task task                                                 */
/*                                                                    */
/* Produces  an      rPLS_DATA.request   primitive  with   the  value */
/* DATA_COMPLETE.                                                     */
/*                                                                    */
/**********************************************************************/

event         rTX_CPLT_task_call;
reg           data_complete_sent;

reg[247:0]    rPLS_DATA_request_ASCII;

task          rTX_CPLT_task;
begin
    data_complete_sent = false;
    -> rTX_CPLT_task_call;
end
endtask


always @(rTX_CPLT_task_call)
begin

    #2.5;

    MMS.OUTPUT_UNIT = MMS.DATA_COMPLETE;
    rPLS_DATA_request_ASCII = "rPLS_DATA.request(DATA_COMPLETE)";

    -> MMS.PLS_DATA_request;

    @(MMS.PLS_DATA_request_serviced);

    data_complete_sent = true;

end


/**********************************************************************/
/*                                                                    */
/* rTX_DATA_task task                                                 */
/*                                                                    */
/* Produces eight rPLS_DATA.request  primitives  based  on the  8-bit */
/* vector data<7:0>.                                                  */
/*                                                                    */
/**********************************************************************/

event            rTX_DATA_task_call;

task             rTX_DATA_task;
input[7:0]       data;
begin
    rtx_data = data;
    -> rTX_DATA_task_call;
end
endtask

reg[3:0]         rtx_bit_count;
reg[7:0]         rtx_data;
reg              rTXByteSent;

always @(reset_begin)
begin
    if(reset_begin)
    begin
        force rtx_bit_count =  4'h0;
        force rTXByteSent   = false;
    end
    else
    begin
        release rtx_bit_count;
        release rTXByteSent;
    end
end

always @(rTX_DATA_task_call)
begin

    rTXByteSent   = false;
    rtx_bit_count = 4'h0;

    while(rtx_bit_count < 4'h8)

    begin

        #2.5;

        if(rtx_data[rtx_bit_count] == 1'b0)
        begin
            MMS.OUTPUT_UNIT = MMS.ZERO;
            rPLS_DATA_request_ASCII = "rPLS_DATA.request(ZERO)";
        end
        else if(rtx_data[rtx_bit_count] == 1'b1)
        begin
            MMS.OUTPUT_UNIT = MMS.ONE;
            rPLS_DATA_request_ASCII = "rPLS_DATA.request(ONE)";
        end
        else 
        begin
            MMS.OUTPUT_UNIT = MMS.UNKNOWN;
            rPLS_DATA_request_ASCII = "rPLS_DATA.request(UNKNOWN)";
        end

        -> MMS.PLS_DATA_request;

        @(MMS.PLS_DATA_request_serviced);

        if(rtx_bit_count == 4'h7)
        begin
            rtx_data     = 8'hXX;
            rTXByteSent  = true;
        end

        rtx_bit_count = rtx_bit_count + 1'b1;

    end

    -> MMS.mod_inst_99_5.rTX_DATA_task_done;
end


/**********************************************************************/
/*                                                                    */
/* pTX_DATA_function function                                         */
/*                                                                    */
/* Returns  an  8-bit  vector   based   on   eight  pPLS_DATA.request */
/* primitives.                                                        */
/*                                                                    */
/**********************************************************************/

event pTX_DATA_function_call;

function[7:0]   pTX_DATA_function;
input           null;
begin
    pTX_DATA_function = ptx_data;
    -> pTX_DATA_function_call;
end
endfunction

reg[2:0]         ptx_bit_count;
reg[7:0]         ptx_data;
reg              pTX_DATA_ready;
reg              pByteReady;

always @(reset_begin)
begin
    if(reset_begin)
    begin
        force ptx_data =      7'h00;
        force ptx_bit_count =  3'h0;
        force pByteReady    = false;
    end
    else
    begin
        release ptx_data;
        release ptx_bit_count;
        release pByteReady;
    end
end

always @(pPLS.PLS_DATA_request)
begin

    #2.5;

    if(pPLS.OUTPUT_UNIT != pPLS.DATA_COMPLETE)
    begin
        if(pPLS.OUTPUT_UNIT == MMS.ZERO)
        begin
            ptx_data[ptx_bit_count] = 1'b0;
        end

        else if(pPLS.OUTPUT_UNIT == MMS.ONE)
        begin
            ptx_data[ptx_bit_count] = 1'b1;
        end

        else
        begin
            ptx_data[ptx_bit_count] = 1'bx;
        end
    end

    if(ptx_bit_count != 3'h0)
    begin
        pTX_DATA_ready = TRUE;
    end

    if(ptx_bit_count == 3'h7)
    begin
        pByteReady = true;
        @(pTX_DATA_function_call);
        pByteReady = false;
        ptx_data   = 8'hXX;
    end

    -> pPLS.PLS_DATA_request_serviced;

    if(pPLS.OUTPUT_UNIT != pPLS.DATA_COMPLETE)
    begin
        ptx_bit_count = ptx_bit_count + 1'b1;
    end

end


/**********************************************************************/
/*                                                                    */
/* SFD_DET_function function                                          */
/*                                                                    */
/* Prescient function returning  a  Boolean value. The  value is TRUE */
/* if  an  8-bit vector producedfrom the next eight pPLS_DATA.request */
/* primitives contains an SFD.                                        */
/*                                                                    */
/**********************************************************************/

function      SFD_DET_function;
input         null;
begin
    if(ptx_data == SFD)
    begin
        SFD_DET_function = TRUE;
    end
    else
    begin
        SFD_DET_function = FALSE;
    end
end
endfunction


/**********************************************************************/
/*                                                                    */
/* SMDC_ENCODE_task task                                              */
/* Creates an 8-bit  vector with the  SMD encoding  for an SMD-C with */
/* frame  count  of   frame_cnt. Produces   eight   rPLS_DATA.request */
/* primitives based on the 8-bit vector.                              */
/*                                                                    */
/**********************************************************************/

task          SMDC_ENCODE_task;
input[1:0]    frame_cnt;
begin

    case(frame_cnt)

    8'h00:
    begin
        rTX_DATA_task(SMD_C0);
$display("->>>>>>> Should be rTX_DATA_task(SMD_C0)");
//        rTX_DATA_task(SMD_S0);
    end

    8'h01:
    begin
        rTX_DATA_task(SMD_C1);
$display("->>>>>>> Should be rTX_DATA_task(SMD_C1)");
//        rTX_DATA_task(SMD_S1);
    end

    8'h02:
    begin
        rTX_DATA_task(SMD_C2);
    end

    8'h03:
    begin
        rTX_DATA_task(SMD_C3);
    end

    default :
    begin
        rTX_DATA_task(8'hXX);
    end

    endcase

end
endtask


/**********************************************************************/
/*                                                                    */
/* SMDS_ENCODE_task task                                              */
/*                                                                    */
/* Returns an 8-bit vector with the SMD  encoding for an  SMD-S  with */
/* frame count of frame_cntif pAllow is TRUE. Otherwise it returns  a */
/* vector  containing  0xD5 (i.e., SFD). Consumes 8 pPLS_DATA.request */
/* primitives containing the SFD.                                     */
/*                                                                    */
/**********************************************************************/

function[7:0] SMDS_ENCODE_function;
input[1:0]    frame_cnt;
begin

    case(frame_cnt)

    8'h00:
    begin
        SMDS_ENCODE_function = SMD_S0;
    end

    8'h01:
    begin
        SMDS_ENCODE_function = SMD_S1;
    end

    8'h02:
    begin
        SMDS_ENCODE_function = SMD_S2;
    end

    8'h03:
    begin
        SMDS_ENCODE_function = SMD_S3;
    end

    default :
    begin
        SMDS_ENCODE_function = 8'hXX;
    end

    endcase

    -> pTX_DATA_function_call;

end
endfunction

/**********************************************************************/
/*                                                                    */
/* TX_MCRC_task task                                                  */
/*                                                                    */
/* Produces 32 rPLS_DATA.requests that  transmit the mCRC computation */
/* for the mPacket.                                                   */
/*                                                                    */
/**********************************************************************/

event         send_mCRC;
reg[31:0]     mCRC;
reg           mCRC_sent;

task          TX_MCRC_task;
begin
    mCRC      = tx_mCRC ^ 32'h0000_FFFF;
    mCRC_sent = false;
    -> send_mCRC;
end
endtask

always @(send_mCRC)
begin
    tx_mCRC_hold = true;

    #2.5 rTX_DATA_task(mCRC[31:24]);
    @(posedge rTXByteSent);

    #2.5 rTX_DATA_task(mCRC[23:16]);
    @(posedge rTXByteSent);

    #2.5 rTX_DATA_task(mCRC[15:8]);
    @(posedge rTXByteSent);

    #2.5 rTX_DATA_task(mCRC[7:0]);
    @(posedge rTXByteSent);

    mCRC_sent = true;
    tx_mCRC_init = true;
end

reg            tx_mCRC_bit;
reg            tx_mCRC_init;
reg            tx_mCRC_hold;
reg[31:0]      tx_mCRC;
reg[31:0]      tx_mCRC_next;

always @(MMS.mod_inst_99_5.mod_99_5_state)
begin
    if(MMS.mod_inst_99_5.mod_99_5_state == MMS.mod_inst_99_5.IDLE_TX_PROC)
    begin
       tx_mCRC_init = true;
       tx_mCRC_hold = true;
    end
    if((MMS.mod_inst_99_5.mod_99_5_state == MMS.mod_inst_99_5.PREEMPTABLE_TX) ||
       (MMS.mod_inst_99_5.mod_99_5_state == MMS.mod_inst_99_5.SEND_FRAG_COUNT))
    begin
       tx_mCRC_init = false;
    end
end

always @(MMS.PLS_DATA_request_serviced)
begin

    if(tx_mCRC_init)
    begin
        tx_mCRC = 32'hFFFF_FFFF; 
        tx_mCRC_hold = false;
    end

    if(!tx_mCRC_hold && !tx_mCRC_init)
    begin

        case(MMS.OUTPUT_UNIT)

        2'b00:
        begin
            tx_mCRC_bit = 1'b0;
        end

        2'b01:
        begin
            tx_mCRC_bit = 1'b1;
        end

        default:
        begin
            tx_mCRC_bit = 1'bx;
        end

        endcase

        tx_mCRC_next[0]     =  tx_mCRC[31] ^ tx_mCRC_bit;
        tx_mCRC_next[1]     =  tx_mCRC[0]  ^  tx_mCRC[31] ^ tx_mCRC_bit;
        tx_mCRC_next[2]     =  tx_mCRC[1]  ^  tx_mCRC[31] ^ tx_mCRC_bit;
        tx_mCRC_next[3]     =  tx_mCRC[2];
        tx_mCRC_next[4]     =  tx_mCRC[3]  ^  tx_mCRC[31] ^ tx_mCRC_bit;
        tx_mCRC_next[5]     =  tx_mCRC[4]  ^  tx_mCRC[31] ^ tx_mCRC_bit;
        tx_mCRC_next[6]     =  tx_mCRC[5];
        tx_mCRC_next[7]     =  tx_mCRC[6]  ^  tx_mCRC[31] ^ tx_mCRC_bit;
        tx_mCRC_next[8]     =  tx_mCRC[7]  ^  tx_mCRC[31] ^ tx_mCRC_bit;
        tx_mCRC_next[9]     =  tx_mCRC[8];
        tx_mCRC_next[10]    =  tx_mCRC[9]  ^  tx_mCRC[31] ^ tx_mCRC_bit;
        tx_mCRC_next[11]    =  tx_mCRC[10] ^  tx_mCRC[31] ^ tx_mCRC_bit;
        tx_mCRC_next[12]    =  tx_mCRC[11] ^  tx_mCRC[31] ^ tx_mCRC_bit;
        tx_mCRC_next[15:13] =  tx_mCRC[14:12];
        tx_mCRC_next[16]    =  tx_mCRC[15] ^  tx_mCRC[31] ^ tx_mCRC_bit;
        tx_mCRC_next[21:17] =  tx_mCRC[20:16];
        tx_mCRC_next[22]    =  tx_mCRC[21] ^  tx_mCRC[31] ^ tx_mCRC_bit;
        tx_mCRC_next[23]    =  tx_mCRC[22] ^  tx_mCRC[31] ^ tx_mCRC_bit;
        tx_mCRC_next[25:24] =  tx_mCRC[24:23];
        tx_mCRC_next[26]    =  tx_mCRC[25] ^  tx_mCRC[31] ^ tx_mCRC_bit;
        tx_mCRC_next[31:27] =  tx_mCRC[30:26];

        tx_mCRC =  tx_mCRC_next;

    end

end


/**********************************************************************/
/*                                                                    */
/* TX_R_task task                                                     */
/*                                                                    */
/**********************************************************************/

reg           TX_R_task_done;

event         send_tx;

task          TX_R_task;
begin
    TX_R_task_done = false;
    -> send_tx;
    tx_v_data[63:56]  = SMD_R;
end
endtask


/**********************************************************************/
/*                                                                    */
/* TX_V_task task                                                     */
/*                                                                    */
/**********************************************************************/

reg[9:0]      tx_v_bit_count;
reg[543:0]    tx_v_data;

task          TX_V_task;
begin
    -> send_tx;
    tx_v_data[63:56]  = SMD_V;
end
endtask


always @(send_tx)
begin

    tx_v_data[55:0]   = {7{8'h55}};
    tx_v_data[543:64] = {60{8'h00}};

    for (tx_v_bit_count = 0; tx_v_bit_count < 544; tx_v_bit_count = tx_v_bit_count + 1)
    begin

        if(tx_v_bit_count == 64)
        begin
            tx_mCRC_init = false;
        end

        if(tx_v_data[tx_v_bit_count] == 1'b0)
        begin
            MMS.OUTPUT_UNIT = MMS.ZERO;
            rPLS_DATA_request_ASCII = "rPLS_DATA.request(ZERO)";
        end
        else if(tx_v_data[tx_v_bit_count] == 1'b1)
        begin
            MMS.OUTPUT_UNIT = MMS.ONE;
            rPLS_DATA_request_ASCII = "rPLS_DATA.request(ONE)";
        end
        else 
        begin
            MMS.OUTPUT_UNIT = MMS.UNKNOWN;
            rPLS_DATA_request_ASCII = "rPLS_DATA.request(UNKNOWN)";
        end

        -> MMS.PLS_DATA_request;

        @(MMS.PLS_DATA_request_serviced);

        #2.5;

    end

    TX_MCRC_task;

    @(posedge mCRC_sent);

    MMS.OUTPUT_UNIT = MMS.DATA_COMPLETE;
    rPLS_DATA_request_ASCII = "rPLS_DATA.request(DATA_COMPLETE)";
    -> MMS.PLS_DATA_request;

    @(MMS.PLS_DATA_request_serviced);

    if(tx_v_data[63:56] == SMD_V)
    begin
        -> MMS.mod_inst_99_5.TX_V_task_done;
    end
    else
    begin
        -> MMS.mod_inst_99_5.TX_R_task_done;
    end

end


/**********************************************************************/
/*                                                                    */
/* FRAG_ENCODE_task task                                              */
/* Creates  an  8-bit vector  with  the  frag_count  encoding  for  a */
/* fragment  count  of    frag_cnt  (see Table99–2).  Produces  eight */
/* rPLS_DATA.request primitives based on the 8-bit vector.            */
/*                                                                    */
/**********************************************************************/

task          FRAG_ENCODE_task;
input[1:0]    frag_cnt;
begin

    case(frag_cnt)

    8'h00:
    begin
        rTX_DATA_task(8'hE6);
    end

    8'h01:
    begin
        rTX_DATA_task(8'h4C);
    end

    8'h02:
    begin
        rTX_DATA_task(8'h7F);
    end

    8'h03:
    begin
        rTX_DATA_task(8'hB3);
    end

    default :
    begin
        rTX_DATA_task(8'hXX);
    end

    endcase

end
endtask


/**********************************************************************/
/*                                                                    */
/* eTX_DATA_function function                                         */
/* Returns   an  8-bit  vector   based  on  eight   ePLS_DATA.request */
/* primitives.                                                        */
/*                                                                    */
/**********************************************************************/

event eTX_DATA_function_call;

function[7:0]   eTX_DATA_function;
input           null;
begin
    eTX_DATA_function = etx_data;
    -> eTX_DATA_function_call;
end
endfunction

reg[2:0]         etx_bit_count;
reg[7:0]         etx_data;
reg              eTX_DATA_ready;
reg              eByteReady;

always @(reset_begin)
begin
    if(reset_begin)
    begin
        force etx_data =      7'h00;
        force etx_bit_count =  3'h0;
        force eByteReady    = false;
    end
    else
    begin
        release etx_data;
        release etx_bit_count;
        release eByteReady;
    end
end

always @(ePLS.PLS_DATA_request)
begin

    #2.5;

    if(ePLS.OUTPUT_UNIT != ePLS.DATA_COMPLETE)
    begin
        if(ePLS.OUTPUT_UNIT == MMS.ZERO)
        begin
            etx_data[etx_bit_count] = 1'b0;
        end

        else if(ePLS.OUTPUT_UNIT == MMS.ONE)
        begin
            etx_data[etx_bit_count] = 1'b1;
        end

        else
        begin
            etx_data[etx_bit_count] = 1'bx;
        end
    end

    if(etx_bit_count != 3'h0)
    begin
        eTX_DATA_ready = TRUE;
    end

    if(etx_bit_count == 3'h7)
    begin
        eByteReady = true;
        @(eTX_DATA_function_call);
        eByteReady = false;
        etx_data   = 8'hXX;
    end

    -> ePLS.PLS_DATA_request_serviced;

    if(ePLS.OUTPUT_UNIT != ePLS.DATA_COMPLETE)
    begin
        etx_bit_count = etx_bit_count + 1'b1;
    end

end


/**********************************************************************/
/*                                                                    */
/* DISCARD_task task                                                  */
/*                                                                    */
/* Ensures that the MAC detects a FrameCheckError in  that frame (see */
/* 99.4.5)    and  then  invokes pRX_DV(FALSE).  Used   when  Receive */
/* processing  detects that the packet  cannot  be  continuedafter it */
/* was preempted                                                      */
/*                                                                    */
/**********************************************************************/

task          DISCARD_task;
begin

    pRX_DATA_task(8'h55);
    #40 pRX_DATA_task(8'h55);
    #40 pRX_DATA_task(8'h55);
    #40 pRX_DATA_task(8'h55);

    #40 pRX_DV_task(pPLS.DATA_NOT_VALID);

end
endtask


/**********************************************************************/
/*                                                                    */
/* rRX_DATA_function function                                         */
/* Returns  an  8-bit  vector  based  on  eight  rPLS_DATA.indication */
/* primitives.                                                        */
/*                                                                    */
/**********************************************************************/

reg           rByteReady;
reg[2:0]      rrx_bit_count;
reg[7:0]      rdata;

function[7:0] rRX_DATA_function;
input         null;
begin
    rRX_DATA_function = rdata;
    rByteReady = false;
end
endfunction

always @(MMS.PLS_DATA_indication_32bitTimes)
begin

    rdata[rrx_bit_count] = MMS.INPUT_UNIT_32bitTimes;

    if(rrx_bit_count == 3'b111)
    begin
        rByteReady    = true;
    end

    if(MMS.rRxDv)
    begin
        rrx_bit_count = rrx_bit_count + 1'b1;
    end
    else
    begin
        rByteReady    = false;
        rrx_bit_count = 3'h0;
    end

end


/**********************************************************************/
/*                                                                    */
/* pRX_DATA_task task                                                 */
/* Produces eight pPLS_DATA.indication primitives based on  the 8-bit */
/* vector data<7:0>.                                                  */
/*                                                                    */
/**********************************************************************/

event         pRX_DATA_task_call;
reg[4:0]      prx_bit_count;
reg[7:0]      prx_data;
reg           pRxByteSent;

task          pRX_DATA_task;
input[7:0]    data;
begin
    pRxByteSent = false;
    prx_data = data;
    -> pRX_DATA_task_call;
end
endtask

always @(pRX_DATA_task_call)
begin
    prx_bit_count = 4'b0000;

    while (prx_bit_count < 4'b1000)
    begin

        #2.5 pPLS.INPUT_UNIT = prx_data[prx_bit_count];
        -> pPLS.PLS_DATA_indication;

        prx_bit_count = prx_bit_count + 1'b1;

    end

    pRxByteSent = true;

end


/**********************************************************************/
/*                                                                    */
/* pRX_DV_task task                                                   */
/* Produces  a pPLS_DATA_VALID.indication. If the  Boolean  parameter */
/* data_valid  is  TRUE, the  primitive  value   is   DATA_VALID.  If */
/* data_valid is FALSE, the primitive value is DATA_NOT_VALID.        */
/*                                                                    */
/**********************************************************************/

task          pRX_DV_task;
input         data_valid;
begin
    if(data_valid)
    begin
        pPLS.DATA_VALID_STATUS = pPLS.DATA_VALID;
    end
    else
    begin
        pPLS.DATA_VALID_STATUS = pPLS.DATA_NOT_VALID;
    end

    -> pPLS.PLS_DATA_VALID_indication;

end
endtask

/**********************************************************************/
/*                                                                    */
/* RX_MCRC_CK_function function                                       */
/* Prescient  function returning a Boolean  value.  The value is TRUE */
/* if rPLS_DATA_VALID.indication with a value of  DATA_NOT_VALID will */
/* be received  after the next 32 rPLS_DATA.indication primitives and */
/* the  next 32 rPLS_DATA.indications equalthe computed  mCRC  result */
/* for the preemptable packet being received. It is FALSE otherwise.  */
/*                                                                    */
/**********************************************************************/

reg           rx_mCRC_check;

reg[7:0]      rdata_byte_fifo;
reg[7:0]      rdata_byte_fifo_0;
reg[7:0]      rdata_byte_fifo_1;
reg[7:0]      rdata_byte_fifo_2;
reg[7:0]      rdata_byte_fifo_3;

reg[2:0]      rrx_fifo_bit_count;

function      RX_MCRC_CK_function;
input         null;
begin
    RX_MCRC_CK_function = rx_mCRC_check;
end
endfunction

always @(MMS.PLS_DATA_VALID_indication)
begin
    if(MMS.DATA_VALID_STATUS == MMS.DATA_VALID)
    begin
        rrx_fifo_bit_count = 3'h0;
    end
end


always @(MMS.PLS_DATA_indication)
begin

    rdata_byte_fifo[rrx_fifo_bit_count] = MMS.INPUT_UNIT;

    if(rrx_fifo_bit_count == 3'b111)
    begin
        rdata_byte_fifo_3    = rdata_byte_fifo_2;
        rdata_byte_fifo_2    = rdata_byte_fifo_1;
        rdata_byte_fifo_1    = rdata_byte_fifo_0;
        rdata_byte_fifo_0    = rdata_byte_fifo;

    end

    rrx_fifo_bit_count = rrx_fifo_bit_count + 1'b1;

end

event RX_MCRC_CK_function_change;

always @(MMS.PLS_DATA_VALID_indication)
begin
    if(MMS.DATA_VALID_STATUS == MMS.DATA_VALID)
    begin
        rx_mCRC_init =  true;
        rx_mCRC_hold =  false;
        rx_mCRC_check = false;
    end

    if(MMS.DATA_VALID_STATUS == MMS.DATA_NOT_VALID)
    begin

        if({rdata_byte_fifo_3, rdata_byte_fifo_2, rdata_byte_fifo_1, rdata_byte_fifo_0} == (rx_mCRC_fifo_3 ^ 32'h0000_FFFF))
        begin
            rx_mCRC_check = true;
        end

        rx_mCRC_hold = true;
        -> RX_MCRC_CK_function_change;

    end

end

reg           rx_mCRC_bit;
reg[31:0]     rx_mCRC;
reg[31:0]     rx_mCRC_next;
reg[31:0]     rx_mCRC_fifo_0;
reg[31:0]     rx_mCRC_fifo_1;
reg[31:0]     rx_mCRC_fifo_2;
reg[31:0]     rx_mCRC_fifo_3;
reg           rx_mCRC_init;
reg           rx_mCRC_hold;
reg[2:0]      rx_mCRC_bit_count;

always @(MMS.PLS_DATA_indication)
begin

    if(rx_mCRC_init)
    begin
       rx_mCRC           = 32'hFFFF_FFFF; 
       rx_mCRC_bit_count = 3'b000;
       rx_mCRC_hold      = false;
    end

    if(!rx_mCRC_init && !rx_mCRC_hold)
    begin

        case(MMS.INPUT_UNIT)

        2'b00:
        begin
            rx_mCRC_bit = 1'b0;
        end

        2'b01:
        begin
            rx_mCRC_bit = 1'b1;
        end

        default:
        begin
            rx_mCRC_bit = 1'bx;
        end

        endcase

        rx_mCRC_next[0]     =  rx_mCRC[31] ^ rx_mCRC_bit;
        rx_mCRC_next[1]     =  rx_mCRC[0]  ^  rx_mCRC[31] ^ rx_mCRC_bit;
        rx_mCRC_next[2]     =  rx_mCRC[1]  ^  rx_mCRC[31] ^ rx_mCRC_bit;
        rx_mCRC_next[3]     =  rx_mCRC[2];
        rx_mCRC_next[4]     =  rx_mCRC[3]  ^  rx_mCRC[31] ^ rx_mCRC_bit;
        rx_mCRC_next[5]     =  rx_mCRC[4]  ^  rx_mCRC[31] ^ rx_mCRC_bit;
        rx_mCRC_next[6]     =  rx_mCRC[5];
        rx_mCRC_next[7]     =  rx_mCRC[6]  ^  rx_mCRC[31] ^ rx_mCRC_bit;
        rx_mCRC_next[8]     =  rx_mCRC[7]  ^  rx_mCRC[31] ^ rx_mCRC_bit;
        rx_mCRC_next[9]     =  rx_mCRC[8];
        rx_mCRC_next[10]    =  rx_mCRC[9]  ^  rx_mCRC[31] ^ rx_mCRC_bit;
        rx_mCRC_next[11]    =  rx_mCRC[10] ^  rx_mCRC[31] ^ rx_mCRC_bit;
        rx_mCRC_next[12]    =  rx_mCRC[11] ^  rx_mCRC[31] ^ rx_mCRC_bit;
        rx_mCRC_next[15:13] =  rx_mCRC[14:12];
        rx_mCRC_next[16]    =  rx_mCRC[15] ^  rx_mCRC[31] ^ rx_mCRC_bit;
        rx_mCRC_next[21:17] =  rx_mCRC[20:16];
        rx_mCRC_next[22]    =  rx_mCRC[21] ^  rx_mCRC[31] ^ rx_mCRC_bit;
        rx_mCRC_next[23]    =  rx_mCRC[22] ^  rx_mCRC[31] ^ rx_mCRC_bit;
        rx_mCRC_next[25:24] =  rx_mCRC[24:23];
        rx_mCRC_next[26]    =  rx_mCRC[25] ^  rx_mCRC[31] ^ rx_mCRC_bit;
        rx_mCRC_next[31:27] =  rx_mCRC[30:26];

        if(rx_mCRC_bit_count == 3'b000)
        begin
            rx_mCRC_fifo_3 = rx_mCRC_fifo_2;
            rx_mCRC_fifo_2 = rx_mCRC_fifo_1;
            rx_mCRC_fifo_1 = rx_mCRC_fifo_0;
            rx_mCRC_fifo_0 = rx_mCRC;
        end

        rx_mCRC =  rx_mCRC_next;

        rx_mCRC_bit_count = rx_mCRC_bit_count + 1'b1;

    end

    if(({rdata_byte_fifo_1, rdata_byte_fifo_2, rdata_byte_fifo_3} == 24'h55_55_55) && (rdata_byte_fifo_0 != 8'h55))
    begin
        rx_mCRC_init = false;
    end

end



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

task          SMD_DECODE_task;
input[7:0]    start_mPacket_delimiter;
begin

   MMS.Pream = false;
   MMS.E     = false;
   MMS.S     = false;
   MMS.C     = false;
   MMS.V     = false;
   MMS.R     = false;
   MMS.ERR   = false;

   case(start_mPacket_delimiter)

   8'h55:
   begin
       MMS.Pream = true;
   end

   SMD_V:
   begin
       MMS.V = true;
   end


   SMD_R:
   begin
       MMS.R = true;
   end

   SMD_E:
   begin
       MMS.E = true;
   end

   8'hE6:
   begin
       MMS.S = true;
       MMS.rxFrameCnt = 2'b00; 
   end

   8'h4C:
   begin
       MMS.S = true;
       MMS.rxFrameCnt = 2'b01; 
   end

   8'h7F:
   begin
       MMS.S = true;
       MMS.rxFrameCnt = 2'b10; 
   end

   8'hB3:
   begin
       MMS.S = true;
       MMS.rxFrameCnt = 2'b11; 
   end


   8'h61:
   begin
       MMS.C = true;
       MMS.cFrameCnt = 2'b00; 
   end

   8'h52:
   begin
       MMS.C = true;
       MMS.cFrameCnt = 2'b01;
   end

   8'h9E:
   begin
       MMS.C = true;
       MMS.cFrameCnt = 2'b10;
   end

   8'h2A:
   begin
       MMS.C = true;
       MMS.cFrameCnt = 2'b11;
   end


   default:
   begin
       MMS.ERR = true;
   end

   endcase

end
endtask


/**********************************************************************/
/*                                                                    */
/* FRAG_DECODE_task task                                              */
/* Decodes eight  rPLS_DATA.indication  primitives  by  producing  an */
/* 8-bit vector and  comparing it to encoded  frag_count  values (see */
/* Table 99–2). If  frag_count  contains  a  valid  value,  placesthe */
/* fragment count  decoded in rxFragCnt. Otherwise, it sets rxFragCnt */
/* to 4.                                                              */
/*                                                                    */
/**********************************************************************/

task          FRAG_DECODE_task;
input[7:0]    data;
begin

   case(data)

   8'hE6:
   begin
       MMS.rxFragCnt = 3'b000;
   end

   8'h4C:
   begin
       MMS.rxFragCnt = 3'b001;
   end

   8'h7F:
   begin
       MMS.rxFragCnt = 3'b010;
   end

   8'hB3:
   begin
       MMS.rxFragCnt = 3'b011;
   end

   default:
   begin
       MMS.rxFragCnt = 3'b100;
   end

   endcase

end
endtask


/**********************************************************************/
/*                                                                    */
/* eRX_DATA_task task                                                 */
/*                                                                    */
/**********************************************************************/

event         eRX_DATA_task_call;
reg[4:0]      erx_bit_count;
reg[7:0]      erx_data;
reg           eRxByteSent;

task          eRX_DATA_task;
input[7:0]    data;
begin
    eRxByteSent = false;
    erx_data = data;
    -> eRX_DATA_task_call;
end
endtask

always @(eRX_DATA_task_call)
begin
    erx_bit_count = 4'b0000;

    while (erx_bit_count < 4'b1000)
    begin

        #2.5 ePLS.INPUT_UNIT = erx_data[erx_bit_count];
        -> ePLS.PLS_DATA_indication;

        erx_bit_count = erx_bit_count + 1'b1;

    end

    eRxByteSent = true;

end


/**********************************************************************/
/*                                                                    */
/* eRX_DV_task task                                                   */
/* Produces an ePLS_DATA_VALID.indication. If the  Boolean  parameter */
/* data_valid  is  TRUE,  the  primitive  value   is   DATA_VALID. If */
/* data_valid is FALSE, the primitive value is DATA_NOT_VALID.        */
/*                                                                    */
/**********************************************************************/

task          eRX_DV_task;
input         data_valid;
begin
    if(data_valid)
    begin
        ePLS.DATA_VALID_STATUS = ePLS.DATA_VALID;
    end
    else
    begin
        ePLS.DATA_VALID_STATUS = ePLS.DATA_NOT_VALID;
    end

    -> ePLS.PLS_DATA_VALID_indication;

end
endtask

/**********************************************************************/
/*                                                                    */
/* MIN_REMAIN_function function                                       */
/*                                                                    */
/**********************************************************************/
/*                                                                    */
/* REMAIN                                                             */
/* Prescient  function to check if  enough octets of the current pMAC */
/* packet  remain  meet    theminimum  fragment   requirement   after */
/* preemption. Produces a Boolean value as follows:                   */
/* TRUE >= minFrag octets are left to transmit                        */
/* FALSE Otherwise                                                    */
/*                                                                    */
/**********************************************************************/

reg[15:0]     rtx_to_sent_count;

function      MIN_REMAIN_function;
input         null;
begin
    if(rtx_to_sent_count >= minFrag)
    begin
        MIN_REMAIN_function = true;
    end
    else
    begin
        MIN_REMAIN_function = false;
    end
end
endfunction

always @(rTX_DATA_task_call)
begin
    rtx_to_sent_count = rtx_to_sent_count - 1'b1;
end
    
endmodule
