/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_147_3_2_func.v                                  */
/*        Date:   16/06/2019                                          */
/*                                                                    */
/**********************************************************************/

/*                                                                    */
/* ENCODE                                                             */
/*                                                                    */
/* This function takes  a 4 bit input parameter Scn<3:0> and  returns */
/* a 5B symbol according to the following procedure:                  */
/* 1. Convert Scn<3:0> into Sdn<3:0> as specified in 147.3.2.8.       */
/* 2. Convert Sdn<3:0> (4B symbol) into  the corresponding 5B  symbol */
/*    defined in Table 147–1.                                         */
/*                                                                    */

function[4:0] ENCODE (input[3:0] Scn);
begin
    if(top.scramble_enable == TRUE)
    begin
        ENCODE = FIVEB(SCRAMBLE(Scn));
    end
    else
    begin
        ENCODE = FIVEB(Scn);
    end
end
endfunction


/*                                                                    */
/* Table 147–1—4B/5B Encoding                                         */
/*                                                                    */
/*                 4B            5B      Special function             */
/*                 --            --      ----------------             */
/*                                                                    */
/* 0              0000          11110           —                     */
/* 1              0001          01001           —                     */
/* 2              0010          10100           —                     */
/* 3              0011          10101           —                     */
/* 4              0100          01010           —                     */
/* 5              0101          01011           —                     */
/* 6              0110          01110           —                     */
/* 7              0111          01111           —                     */
/* 8              1000          10010           —                     */
/* 9              1001          10011           —                     */
/* A              1010          10110           —                     */
/* B              1011          10111           —                     */
/* C              1100          11010           —                     */
/* D              1101          11011           —                     */
/* E              1110          11100           —                     */
/* F              1111          11101           —                     */
/*                                                                    */

function[4:0] FIVEB (input[3:0] fourB);
begin
    case(fourB)
    5'b0000: FIVEB = 5'b11110;
    5'b0001: FIVEB = 5'b01001;
    5'b0010: FIVEB = 5'b10100;
    5'b0011: FIVEB = 5'b10101;
    5'b0100: FIVEB = 5'b01010;
    5'b0101: FIVEB = 5'b01011;
    5'b0110: FIVEB = 5'b01110;
    5'b0111: FIVEB = 5'b01111;
    5'b1000: FIVEB = 5'b10010;
    5'b1001: FIVEB = 5'b10011;
    5'b1010: FIVEB = 5'b10110;
    5'b1011: FIVEB = 5'b10111;
    5'b1100: FIVEB = 5'b11010;
    5'b1101: FIVEB = 5'b11011;
    5'b1110: FIVEB = 5'b11100;
    5'b1111: FIVEB = 5'b11101;
    endcase
end
endfunction


/*                                                                    */
/* 147.3.2.8 Self-synchronizing scrambler                             */
/*                                                                    */
/* The   PCS   Transmit   function  shall   implement  multiplicative */
/* scrambling using the following generator polynomial  g(x) =  x  17 */
/* + x^^14 + 1.                                                       */
/* An  implementation  of  a   self-synchronizing    scrambler  by  a */
/* linear-feedback  shift register is shown in Figure 147–6. The bits */
/* stored in  the shift register delay line at time n are denoted  by */
/* Scrn<16:0>.  The  '+'  symbol  denotes  the  exclusive-OR  logical */
/* operation.  When  Scn<3:0>  is  presented  at  the  input  of  the */
/* scrambler, Sdn<3:0>  is  produced  by  shifting  in  each  bit  of */
/* Scn<3:0> as Scn<i>, with i  ranging from 0 to 3 (i.e., LSB first). */
/* The scrambler  is reset upon  execution of the PCS Reset function. */
/* If the  PCS  Reset  is executed,  all  bits of  the 17-bit  vector */
/* representing   the  self-synchronizing     scrambler    state  are */
/* arbitrarily  set.  The  initialization of the  scrambler state  is */
/* left to the implementer. In  no case shall the scrambler state  be */
/* initialized to  all zeroes. At every STD, if no data is  presented */
/* at the scrambler input via Scn<3:0>, the scrambler may be fed with */
/* arbitrary inputs.                                                  */

reg[2:0] i;
reg[3:0] Sdn;
reg[16:0] Scrn;

reg[3:0] temp;

always @(pcs_reset)
begin
    if(pcs_reset == TRUE)
    begin
//        Scrn = $urandom_range(17'h1_FFFF, 17'h0_0000);
        Scrn = 17'h0_0000;
    end
end

function[3:0] SCRAMBLE (input[3:0] Scn);
begin
    for (i = 0; i < 4; i = i + 1)
    begin
        Sdn[i]     = (Scrn[16] ^ Scrn[13]) ^ Scn[i];
        Scrn[16:0] = {Scrn[15:0], Sdn[i]};

temp[i] = Scrn[16] ^ Scrn[13];

    end
    SCRAMBLE = Sdn;
end
endfunction

/*                                                                    */
/* TXCMD_ENCODE                                                       */
/*                                                                    */
/* In the PCS transmit process,  this function takes as its arguments */
/* the values of tx_cmd and hb_cmd variables and  returns a 5B symbol */
/* based on the following mapping:                                    */
/* 'N' when the tx_cmd variable is set to BEACON,                     */
/* 'J' when the tx_cmd variable is set to COMMIT,                     */
/* 'T' when  the hb_cmd variable  is set to  HEARTBEAT and the tx_cmd */
/*     variable is not set to BEACON or COMMIT,                       */
/* 'I' otherwise.                                                     */

function[4:0] TXCMD_ENCODE (input[4:0] tx_cmd, input hb_cmd);
begin
    case(tx_cmd)

    BEACON:
    begin
        TXCMD_ENCODE = 5'b01000;
    end

    COMMIT:
    begin
        TXCMD_ENCODE = 5'b11000;
    end

    default:
    begin
        if(hb_cmd == base_t1s.mod_inst_147_10.HEARTBEAT[0])
        begin
            TXCMD_ENCODE = 5'b01101;
        end
        else
        begin
            TXCMD_ENCODE = 5'b11111;
        end
    end

    endcase

end
endfunction