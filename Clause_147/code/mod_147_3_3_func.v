/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_147_3_3_func.v                                  */
/*        Date:   16/06/2019                                          */
/*                                                                    */
/**********************************************************************/

function[3:0] DECODE;
input[4:0] symbol;
begin
    if(top.scramble_enable == TRUE)
    begin
        DECODE = DESCRAMBLE(FOURB(symbol));
    end
    else
    begin
        DECODE = FOURB(symbol);
    end
end
endfunction


/*                                                                    */
/* 147.3.3.7 Self-synchronizing descrambler                           */
/*                                                                    */
/* The  PCS  Receive function  descrambles  the  5B/4B  decoded  data */
/* stream  and  returns  the  value  of  RXD<3:0> to  the   MII.  The */
/* descrambler shall employ the polynomial  defined in 147.3.2.8. The */
/* implementation  of   the  self-synchronizing   descrambler g(x) by */
/* linear-feedback shift register  is shown in Figure 147–9. The bits */
/* stored in the shift register delay line at time  n  are denoted by */
/* Dcrn<16:0>.  The  '+'  symbol  denotes  the  exclusive-OR  logical */
/* operation.                                                         */
/* When  Drn<3:0>  is presented  at  the  input  of the  descrambler, */
/* Dcn<3:0>  is produced by  shifting  in  each  bit  of Drn<3:0>  as */
/* Drn<i>, with  i  ranging  from 0  to  3  (i.e.,  LSB  first).  The */
/* descrambler is reset upon execution of  the PCS Reset function. If */
/* PCS  Reset  is  executed,  all  the  bits  of  the  17-bit  vector */
/* representing  the  self-synchronizing   descrambler  state     are */
/* arbitrarily  set. The  initialization of the descrambler  state is */
/* left to the implementer. At every  RSCD, if  no data  is presented */
/* at  the descrambler input via Drn<3:0>, the descrambler may be fed */
/* with arbitrary inputs.                                             */
/*                                                                    */

reg[2:0] i;
reg[3:0] Dcn;
reg[16:0] Dcrn;

always @(pcs_reset)
begin
    if(pcs_reset == TRUE)
    begin
        Dcrn = $urandom_range(17'h1_FFFF, 17'h0_0000);
//        Dcrn = 17'h0_0000;
    end
end

function[3:0] DESCRAMBLE (input[3:0] Drn);
begin
    for (i = 0; i < 4; i = i + 1)
    begin
        Dcn[i]     = (Dcrn[16] ^ Dcrn[13]) ^ Drn[i];
        Dcrn[16:0] = {Dcrn[15:0], Drn[i]};
    end
    DESCRAMBLE = Dcn;
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

function[3:0] FOURB (input[4:0] fiveB);
begin
    case(fiveB)
    5'b11110: FOURB = 4'b0000;
    5'b01001: FOURB = 4'b0001;
    5'b10100: FOURB = 4'b0010;
    5'b10101: FOURB = 4'b0011;
    5'b01010: FOURB = 4'b0100;
    5'b01011: FOURB = 4'b0101;
    5'b01110: FOURB = 4'b0110;
    5'b01111: FOURB = 4'b0111;
    5'b10010: FOURB = 4'b1000;
    5'b10011: FOURB = 4'b1001;
    5'b10110: FOURB = 4'b1010;
    5'b10111: FOURB = 4'b1011;
    5'b11010: FOURB = 4'b1100;
    5'b11011: FOURB = 4'b1101;
    5'b11100: FOURB = 4'b1110;
    5'b11101: FOURB = 4'b1111;
    endcase
end
endfunction

