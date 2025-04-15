/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_5.v                                         */
/*        Date:   26/11/2024                                          */
/*                                                                    */
/**********************************************************************/

module           mod_148_5(

                 plca_reset,
                 plca_en,
                 plca_status,
                 CRS,
                 committed,
                 MCD,
                 plca_txen,
                 receiving,
                 tx_cmd,
                 plca_txer,
                 pending_timer_done,
                 commit_timer_done,
                 delay_line_length,
                 plca_txd,
                 plca_txdn_a,
                 COL,
                 rx_cmd,
                 tx_cmd_sync,

                 mod_148_5_state,
                 packetPending,
                 CARRIER_STATUS,
                 TXD,
                 TX_EN,
                 TX_ER,
                 SIGNAL_STATUS,
                 a,
                 b
                 );

input            plca_reset;
input            plca_en;
input            plca_status;
input            CRS;
input            committed;
input            MCD;
input            plca_txen;
input            receiving;
input[1:0]       tx_cmd;
input            plca_txer;
input            pending_timer_done;
input            commit_timer_done;
input[7:0]       delay_line_length;
input[3:0]       plca_txd;
input[3:0]       plca_txdn_a;
input            COL;
input[1:0]       rx_cmd;
input[1:0]       tx_cmd_sync;

output[3:0]      mod_148_5_state;
output           packetPending;
output           CARRIER_STATUS;
output[3:0]      TXD;
output           TX_EN;
output           TX_ER;
output           SIGNAL_STATUS;
output[6:0]      a;
output[6:0]      b;

reg[3:0]         mod_148_5_state;
reg[3:0]         next_mod_148_5_state;
reg              packetPending;
reg              CARRIER_STATUS;
reg[3:0]         TXD;
reg              TX_EN;
reg              TX_ER;
reg              SIGNAL_STATUS;
reg[6:0]         a;
reg[6:0]         b;

reg              fix; // Enter NORMAL state when localID = 255
initial          fix = false;

`ifdef simulate
`include "IEEE_P802_3da_param.v"
`include "mod_148_4_5_param.v"

parameter        NORMAL              =  4'b0000;
parameter        WAIT_IDLE           =  4'b0001;
parameter        IDLE                =  4'b0010;
parameter        RECEIVE             =  4'b0011;
parameter        HOLD                =  4'b0100;
parameter        ABORT               =  4'b0101;
parameter        COLLIDE             =  4'b0110;
parameter        DELAY_PENDING       =  4'b0111;
parameter        PENDING             =  4'b1000;
parameter        WAIT_MAC            =  4'b1001;
parameter        TRANSMIT            =  4'b1010;
parameter        FLUSH               =  4'b1011;

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

always@(plca.local_nodeID, mod_148_5_state, plca_reset, plca_en, plca_status, CRS, committed, MCD, plca_txen, receiving, tx_cmd, plca_txer, pending_timer_done, commit_timer_done, delay_line_length, plca_txd, plca_txdn_a, COL, rx_cmd, tx_cmd_sync)

begin

    next_mod_148_5_state <= mod_148_5_state;

    if(plca_reset || (!plca_en) || (plca_status != OK) || (fix && plca.local_nodeID == 8'd255))
    begin
        next_mod_148_5_state <= !NORMAL;
        next_mod_148_5_state <= NORMAL;
    end

    else
    begin

    case(mod_148_5_state)

    NORMAL:
    begin
        if(!(plca_en && (!plca_reset) && (!CRS) && (plca_status == OK)))
        begin
            next_mod_148_5_state <= !NORMAL;
            next_mod_148_5_state <= NORMAL;
        end
        if(plca_en && (!plca_reset) && (!CRS) && (plca_status == OK))
        begin
            next_mod_148_5_state <= IDLE;
        end
    end

    WAIT_IDLE:
    begin
        if(!((!CRS) && (!committed)) && !(MCD && CRS && plca_txen && committed))
        begin
            next_mod_148_5_state <= !WAIT_IDLE;
            next_mod_148_5_state <= WAIT_IDLE;
        end
        if((!CRS) && (!committed))
        begin
            next_mod_148_5_state <= IDLE;
        end
        if(MCD && CRS && plca_txen && committed)
        begin
            next_mod_148_5_state <= TRANSMIT;
        end
    end

    IDLE:
    begin
        if(!(receiving && (!plca_txen) && (tx_cmd == NONE)) && !plca_txen)
        begin
            next_mod_148_5_state <= !IDLE;
            next_mod_148_5_state <= IDLE;
        end
        if(receiving && (!plca_txen) && (tx_cmd == NONE))
        begin
            next_mod_148_5_state <= RECEIVE;
        end
        if(plca_txen)
        begin
            next_mod_148_5_state <= HOLD;
        end
    end

    RECEIVE:
    begin
        if((!receiving) && (!plca_txen))
        begin
            next_mod_148_5_state <= IDLE;
        end
        if(!((!receiving) && (!plca_txen)) && !plca_txen)
        begin
            next_mod_148_5_state <= !RECEIVE;
            next_mod_148_5_state <= RECEIVE;
        end
        if(plca_txen)
        begin
            next_mod_148_5_state <= COLLIDE;
        end
    end

    HOLD:
    begin
        if(MCD && (!committed) && (!plca_txer) && (!receiving) && (a < delay_line_length))
        begin
            next_mod_148_5_state <= !HOLD;
            next_mod_148_5_state <= HOLD;
        end
        if(MCD && plca_txer)
        begin
            next_mod_148_5_state <= ABORT;
        end
        if((!plca_txer) && (receiving || (a >= delay_line_length)))
        begin
            next_mod_148_5_state <= COLLIDE;
        end
        if(MCD && committed && (!receiving) && (!plca_txer) && (a < delay_line_length))
        begin
            next_mod_148_5_state <= TRANSMIT;
        end
    end

    ABORT:
    begin
        if(!plca_txen)
        begin
            next_mod_148_5_state <= IDLE;
        end
        if(plca_txen)
        begin
            next_mod_148_5_state <= !ABORT;
            next_mod_148_5_state <= ABORT;
        end
    end

    COLLIDE:
    begin
        if(plca_txen && plca_txer)
        begin
            next_mod_148_5_state <= ABORT;
        end
        if(plca_txen && !(plca_txen && plca_txer))
        begin
            next_mod_148_5_state <= !COLLIDE;
            next_mod_148_5_state <= COLLIDE;
        end
        if(!plca_txen)
        begin
            next_mod_148_5_state <= DELAY_PENDING;
        end
    end

    DELAY_PENDING:
    begin
        if(!pending_timer_done)
        begin
            next_mod_148_5_state <= !DELAY_PENDING;
            next_mod_148_5_state <= DELAY_PENDING;
        end
        if(pending_timer_done)
        begin
            next_mod_148_5_state <= PENDING;
        end
    end

    PENDING:
    begin
        if(!committed)
        begin
            next_mod_148_5_state <= !PENDING;
            next_mod_148_5_state <= PENDING;
        end
        if(committed)
        begin
            next_mod_148_5_state <= WAIT_MAC;
        end
    end

    WAIT_MAC:
    begin
        if((!plca_txen) && commit_timer_done)
        begin
            next_mod_148_5_state <= WAIT_IDLE;
        end
        if(!((!plca_txen) && commit_timer_done) && !(MCD && plca_txen))
        begin
            next_mod_148_5_state <= !WAIT_MAC;
            next_mod_148_5_state <= WAIT_MAC;
        end
        if(MCD && plca_txen)
        begin
            next_mod_148_5_state <= TRANSMIT;
        end
    end

    TRANSMIT:
    begin
        if(MCD && (!plca_txen) && (a == 0))
        begin
            next_mod_148_5_state <= WAIT_IDLE;
        end
        if(MCD && plca_txen)
        begin
            next_mod_148_5_state <= !TRANSMIT;
            next_mod_148_5_state <= TRANSMIT;
        end
        if(MCD && (!plca_txen) && (a > 0))
        begin
            next_mod_148_5_state <= FLUSH;
        end
    end

    FLUSH:
    begin
        if(MCD && (b == a))
        begin
            next_mod_148_5_state <= WAIT_IDLE;
        end
        if(MCD && (a != b))
        begin
            next_mod_148_5_state <= !FLUSH;
            next_mod_148_5_state <= FLUSH;
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

always@(next_mod_148_5_state)

begin

    case(next_mod_148_5_state)

    NORMAL:
    begin
        packetPending = FALSE;
        if( CRS)
        begin
            CARRIER_STATUS = CARRIER_ON;
            end
        else
        begin
                CARRIER_STATUS = CARRIER_OFF;
            end
            TXD = plca_txd;
            TX_EN = plca_txen;
            TX_ER = plca_txer;
            if( COL)
            begin
                SIGNAL_STATUS = SIGNAL_ERROR;
                end
            else
            begin
                    SIGNAL_STATUS = NO_SIGNAL_ERROR;
                end
    end

    WAIT_IDLE:
    begin
        packetPending = FALSE;
        CARRIER_STATUS = CARRIER_OFF;
        SIGNAL_STATUS = NO_SIGNAL_ERROR;
        TXD = plca.mod_inst_148_4_5_func.ENCODE_TXD(tx_cmd_sync);
        TX_EN = FALSE;
        TX_ER = plca.mod_inst_148_4_5_func.ENCODE_TXER(tx_cmd_sync);
        a = 0;
        b = 0;
    end

    IDLE:
    begin
        packetPending = FALSE;
        CARRIER_STATUS = CARRIER_OFF;
        SIGNAL_STATUS = NO_SIGNAL_ERROR;
        TXD = plca.mod_inst_148_4_5_func.ENCODE_TXD(tx_cmd_sync);
        TX_EN = FALSE;
        TX_ER = plca.mod_inst_148_4_5_func.ENCODE_TXER(tx_cmd_sync);
        a = 0;
        b = 0;
    end

    RECEIVE:
    begin
        if( CRS && (rx_cmd != COMMIT))
        begin
            CARRIER_STATUS = CARRIER_ON;
            end
        else
        begin
                CARRIER_STATUS = CARRIER_OFF;
            end
            TXD = plca.mod_inst_148_4_5_func.ENCODE_TXD(tx_cmd_sync);
            TX_ER = plca.mod_inst_148_4_5_func.ENCODE_TXER(tx_cmd_sync);
    end

    HOLD:
    begin
        packetPending = TRUE;
        CARRIER_STATUS = CARRIER_ON;
        a = a + 1;
        TX_ER = plca.mod_inst_148_4_5_func.ENCODE_TXER(tx_cmd_sync);
        TXD = plca.mod_inst_148_4_5_func.ENCODE_TXD(tx_cmd_sync);
    end

    ABORT:
    begin
        packetPending = FALSE;
        TX_ER = plca.mod_inst_148_4_5_func.ENCODE_TXER(tx_cmd_sync);
        TXD = plca.mod_inst_148_4_5_func.ENCODE_TXD(tx_cmd_sync);
    end

    COLLIDE:
    begin
        packetPending = FALSE;
        CARRIER_STATUS = CARRIER_ON;
        SIGNAL_STATUS = SIGNAL_ERROR;
        a = 0;
        b = 0;
        TXD = plca.mod_inst_148_4_5_func.ENCODE_TXD(tx_cmd_sync);
        TX_ER = plca.mod_inst_148_4_5_func.ENCODE_TXER(tx_cmd_sync);
        -> plca.mod_inst_148_4_5_timer.pending_timer.start;
    end

    DELAY_PENDING:
    begin
        SIGNAL_STATUS = NO_SIGNAL_ERROR;
        TXD = plca.mod_inst_148_4_5_func.ENCODE_TXD(tx_cmd_sync);
        TX_ER = plca.mod_inst_148_4_5_func.ENCODE_TXER(tx_cmd_sync);
    end

    PENDING:
    begin
        packetPending = TRUE;
        -> plca.mod_inst_148_4_5_timer.commit_timer.start;
        TXD = plca.mod_inst_148_4_5_func.ENCODE_TXD(tx_cmd_sync);
        TX_ER = plca.mod_inst_148_4_5_func.ENCODE_TXER(tx_cmd_sync);
    end

    WAIT_MAC:
    begin
        CARRIER_STATUS = CARRIER_OFF;
        TXD = plca.mod_inst_148_4_5_func.ENCODE_TXD(tx_cmd_sync);
        TX_ER = plca.mod_inst_148_4_5_func.ENCODE_TXER(tx_cmd_sync);
    end

    TRANSMIT:
    begin
        packetPending = FALSE;
        CARRIER_STATUS = CARRIER_ON;
        TXD = plca_txdn_a;
        TX_EN = TRUE;
        TX_ER = plca_txer;
        if( COL)
        begin
            SIGNAL_STATUS = SIGNAL_ERROR;
            a = 0;
            end
        else
        begin
                SIGNAL_STATUS = NO_SIGNAL_ERROR;
            end
    end

    FLUSH:
    begin
        CARRIER_STATUS = CARRIER_ON;
        TXD = plca_txdn_a;
        TX_EN = TRUE;
        TX_ER = plca_txer;
        b = b + 1;
        if( COL)
        begin
            SIGNAL_STATUS = SIGNAL_ERROR;
            end
        else
        begin
                SIGNAL_STATUS = NO_SIGNAL_ERROR;
            end
    end

    endcase

    mod_148_5_state = next_mod_148_5_state;

end


reg [47:0]       tx_cmd_sync_ASCII;
initial          tx_cmd_sync_ASCII = "- X -";

always@(tx_cmd_sync)
begin
    case(tx_cmd_sync)
        2'b00 : tx_cmd_sync_ASCII = "BEACON";
        2'b01 : tx_cmd_sync_ASCII = "COMMIT";
        2'b10 : tx_cmd_sync_ASCII = "NONE";
        default : tx_cmd_sync_ASCII = "- X -";
    endcase
end

reg [47:0]       tx_cmd_ASCII;
initial          tx_cmd_ASCII = "- X -";

always@(tx_cmd)
begin
    case(tx_cmd)
        2'b00 : tx_cmd_ASCII = "BEACON";
        2'b01 : tx_cmd_ASCII = "COMMIT";
        2'b10 : tx_cmd_ASCII = "NONE";
        default : tx_cmd_ASCII = "- X -";
    endcase
end

reg [47:0]       rx_cmd_ASCII;
initial          rx_cmd_ASCII = "- X -";

always@(rx_cmd)
begin
    case(rx_cmd)
        2'b00 : rx_cmd_ASCII = "BEACON";
        2'b01 : rx_cmd_ASCII = "COMMIT";
        2'b10 : rx_cmd_ASCII = "NONE";
        default : rx_cmd_ASCII = "- X -";
    endcase
end

reg [31:0]       plca_status_ASCII;
initial          plca_status_ASCII = "- X -";

always@(plca_status)
begin
    case(plca_status)
        1'b0 : plca_status_ASCII = "FAIL";
        1'b1 : plca_status_ASCII = "OK";
        default : plca_status_ASCII = "- X -";
    endcase
end


reg [103:0]       mod_148_5_state_ASCII;
initial           mod_148_5_state_ASCII = "- X -";

always@(mod_148_5_state)
begin
    case(mod_148_5_state)
        4'b0000 : mod_148_5_state_ASCII = "NORMAL";
        4'b0001 : mod_148_5_state_ASCII = "WAIT_IDLE";
        4'b0010 : mod_148_5_state_ASCII = "IDLE";
        4'b0011 : mod_148_5_state_ASCII = "RECEIVE";
        4'b0100 : mod_148_5_state_ASCII = "HOLD";
        4'b0101 : mod_148_5_state_ASCII = "ABORT";
        4'b0110 : mod_148_5_state_ASCII = "COLLIDE";
        4'b0111 : mod_148_5_state_ASCII = "DELAY_PENDING";
        4'b1000 : mod_148_5_state_ASCII = "PENDING";
        4'b1001 : mod_148_5_state_ASCII = "WAIT_MAC";
        4'b1010 : mod_148_5_state_ASCII = "TRANSMIT";
        4'b1011 : mod_148_5_state_ASCII = "FLUSH";
        default : mod_148_5_state_ASCII = "- X -";
    endcase
end

`endif


endmodule

