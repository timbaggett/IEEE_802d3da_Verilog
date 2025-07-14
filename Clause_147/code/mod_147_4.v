/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_147_4.v                                         */
/*        Date:   19/06/2019                                          */
/*                                                                    */
/**********************************************************************/

module           mod_147_4(

                 pcs_reset,
                 link_control,
                 TX_EN,
                 tx_cmd,
                 STD,
                 xmit_max_timer_not_done,
                 xmit_max_timer_done,
                 unjab_timer_done,
                 hb_cmd,
                 TXDn,
                 TX_ER,

                 mod_147_4_state,
                 transmitting,
                 err,
                 tx_sym
                 );

input            pcs_reset;
input            link_control;
input            TX_EN;
input[4:0]       tx_cmd;
input            STD;
input            xmit_max_timer_not_done;
input            xmit_max_timer_done;
input            unjab_timer_done;
input            hb_cmd;
input[3:0]       TXDn;
input            TX_ER;

output[3:0]      mod_147_4_state;
output           transmitting;
output           err;
output[4:0]      tx_sym;

reg[3:0]         mod_147_4_state;
reg[3:0]         next_mod_147_4_state;
reg              transmitting;
reg              err;
reg[4:0]         tx_sym;

`ifdef simulate
`include "Clause_147/code/IEEE_P802_3cg_param.v"
`include "Clause_147/code/mod_147_3_2_param.v"
`include "Clause_147/code/mod_147_3_2_func.v"

parameter        SILENT              =  4'b0000;
parameter        COMMIT_STATE        =  4'b0001;
parameter        SYNC1               =  4'b0010;
parameter        SYNC2               =  4'b0011;
parameter        SSD1                =  4'b0100;
parameter        SSD2                =  4'b0101;
parameter        DATA                =  4'b0110;
parameter        ESD_STATE           =  4'b0111;
parameter        BAD_ESD             =  4'b1000;
parameter        GOOD_ESD            =  4'b1001;
parameter        UNJAB_WAIT          =  4'b1010;

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

always@(mod_147_4_state, pcs_reset, link_control, TX_EN, tx_cmd, base_t1s.STD, xmit_max_timer_not_done, xmit_max_timer_done, unjab_timer_done, hb_cmd, TXDn, TX_ER)

begin

    if(pcs_reset || (link_control == DISABLE))
    begin
        next_mod_147_4_state <= !SILENT;
        next_mod_147_4_state <= SILENT;
    end

    else
    begin

    case(mod_147_4_state)

    SILENT:
    begin
        if((!TX_EN) && (tx_cmd != COMMIT))
        begin
            next_mod_147_4_state <= !SILENT;
            next_mod_147_4_state <= SILENT;
        end
        if(STD && (!TX_EN) && (tx_cmd == COMMIT))
        begin
            next_mod_147_4_state <= COMMIT_STATE;
        end
        if(STD && TX_EN)
        begin
            next_mod_147_4_state <= SYNC1;
        end
    end

    COMMIT_STATE:
    begin
        if(STD && TX_EN)
        begin
            next_mod_147_4_state <= SYNC1;
        end
        if(STD && (!TX_EN) && (tx_cmd == SILENCE))
        begin
            next_mod_147_4_state <= ESD_STATE;
        end
    end

    SYNC1:
    begin
        if(STD)
        begin
            next_mod_147_4_state <= SYNC2;
        end
    end

    SYNC2:
    begin
        if(STD)
        begin
            next_mod_147_4_state <= SSD1;
        end
    end

    SSD1:
    begin
        if(STD)
        begin
            next_mod_147_4_state <= SSD2;
        end
    end

    SSD2:
    begin
        if(STD)
        begin
            next_mod_147_4_state <= DATA;
        end
    end

    DATA:
    begin
        if(STD && TX_EN && xmit_max_timer_not_done)
        begin
            next_mod_147_4_state <= !DATA;
            next_mod_147_4_state <= DATA;
        end
        if(STD && ((!TX_EN) || xmit_max_timer_done))
        begin
            next_mod_147_4_state <= ESD_STATE;
        end
    end

    ESD_STATE:
    begin
        if(STD && (err || xmit_max_timer_done))
        begin
            next_mod_147_4_state <= BAD_ESD;
        end
        if(STD && (!err) && xmit_max_timer_not_done)
        begin
            next_mod_147_4_state <= GOOD_ESD;
        end
    end

    BAD_ESD:
    begin
        if(STD && err)
        begin
            next_mod_147_4_state <= SILENT;
        end
        if(STD && (!err) && xmit_max_timer_done)
        begin
            next_mod_147_4_state <= UNJAB_WAIT;
        end
    end

    GOOD_ESD:
    begin
        if(STD)
        begin
            next_mod_147_4_state <= SILENT;
        end
    end

    UNJAB_WAIT:
    begin
        if(STD && (!TX_EN) && unjab_timer_done)
        begin
            next_mod_147_4_state <= SILENT;
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

always@(next_mod_147_4_state)

begin

    case(next_mod_147_4_state)

    SILENT:
    begin
        transmitting = FALSE;
        err = FALSE;
        tx_sym = TXCMD_ENCODE(tx_cmd, hb_cmd);
        top.null_value = hb_cmd;
    end

    SYNC1:
    begin
        transmitting = TRUE;
        tx_sym = SYNC;
        err = err + TX_ER;
    end

    SYNC2:
    begin
        err = err + TX_ER;
    end

    SSD1:
    begin
        tx_sym = SSD;
        err = err + TX_ER;
    end

    SSD2:
    begin
        err = err + TX_ER;
        -> base_t1s.mod_inst_147_3_2_timer.xmit_max_timer.start;
    end

    DATA:
    begin
        tx_sym = ENCODE(TXDn);
        err = err + TX_ER;
    end

    ESD_STATE:
    begin
        if(tx_cmd != COMMIT)
        begin
            tx_sym = ESD;
        end
        else
        begin
            tx_sym = ESDBRS;
        end
    end

    BAD_ESD:
    begin
        if(err)
        begin
            tx_sym = ESDERR;
        end
        else
        begin
            tx_sym = ESDJAB;
        end
    end

    GOOD_ESD:
    begin
        tx_sym = ESDOK;
    end

    UNJAB_WAIT:
    begin
        tx_sym = SILENCE;
        -> base_t1s.mod_inst_147_3_2_timer.unjab_timer.start;
    end

    endcase

    mod_147_4_state = next_mod_147_4_state;

    base_t1s.STD = FALSE;

end


reg [55:0]       link_control_ASCII;

always@(link_control)
begin
    casex(link_control)
    1'b0 : link_control_ASCII = "ENABLE";
    1'b1 : link_control_ASCII = "DISABLE";
    endcase
end


reg [95:0]       mod_147_4_state_ASCII;

always@(mod_147_4_state)
begin
    casex(mod_147_4_state)
        4'b0000 : mod_147_4_state_ASCII = "SILENT";
        4'b0001 : mod_147_4_state_ASCII = "COMMIT_STATE";
        4'b0010 : mod_147_4_state_ASCII = "SYNC1";
        4'b0011 : mod_147_4_state_ASCII = "SYNC2";
        4'b0100 : mod_147_4_state_ASCII = "SSD1";
        4'b0101 : mod_147_4_state_ASCII = "SSD2";
        4'b0110 : mod_147_4_state_ASCII = "DATA";
        4'b0111 : mod_147_4_state_ASCII = "ESD_STATE";
        4'b1000 : mod_147_4_state_ASCII = "BAD_ESD";
        4'b1001 : mod_147_4_state_ASCII = "GOOD_ESD";
        4'b1010 : mod_147_4_state_ASCII = "UNJAB_WAIT";
    endcase
end

`endif


endmodule

