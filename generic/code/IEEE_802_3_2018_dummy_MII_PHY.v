module           dummy_PHY(
                 TX_CLK,
                 TX_EN,
                 TX_ER,
                 TXD,

                 TX,
                 TXC,
                 TXE,
                 TXF,

                 RX,
                 RXC,
                 RXE,
                 RXF,

                 RX_CLK,
                 RXD,
                 RX_DV,
                 RX_ER,

                 CRS,
                 COL,

                 collision
                 );

output           TX_CLK;
input            TX_EN;
input            TX_ER;
input[3:0]       TXD;
input            collision;

output[3:0]      TX;
output           TXC;
output           TXE;
output           TXF;
input[3:0]       RX;
input            RXC;
input            RXE;
input            RXF;

output           RX_CLK;
output[3:0]      RXD;
output           RX_DV;
output           RX_ER;

output           CRS;
output           COL;

reg[3:0]         TX;
reg              TXC;
reg              TXE;
reg              TXF;
reg              CRS;

wire             RX_CLK;
reg[3:0]         RXD;
reg              RX_DV;
reg              RX_ER;

`ifdef simulate
`include "Clause 99/IEEE_P802d3de_half_duplex_code/IEEE_P802_3br_param.v"

assign           COL = collision;

/*                                                                    */
/* The TX_CLK frequency  shall  be 25% of  the  nominal transmit data */
/* rate +/- 100 ppm. For  example, a PHY  operating  at 100 Mb/s must */
/* provide  a TX_CLK frequency  of 25 MHz, and  a  PHY  operating  at */
/* 10 Mb/s must provide a TX_CLK frequency of 2.5 MHz. The duty cycle */
/* of the TX_CLK signal shall be between 35% and 65% inclusive.       */
/*                                                                    */

reg            BIT_CLK;
reg            TX_CLK;

real           txclk_duty_cycle;
real           bit_time;

always @(top.new_values)
begin
    txclk_duty_cycle = $urandom_range(65, 35);
    bit_time  = 100;
end

initial
begin
    #100;
    BIT_CLK = FALSE;
    forever #(bit_time/2) BIT_CLK = ~BIT_CLK;
end

always @(posedge BIT_CLK)
begin
    TX_CLK = TRUE;
    #((txclk_duty_cycle/100) * 4 * bit_time);
    TX_CLK = FALSE;
    #(((100 - txclk_duty_cycle - 1)/100) * 4 * bit_time);
end



/* +--------+-------------------------------------+---------+---------+------+ */
/* | Symbol | Event                               | Minimum | Maximum | Unit | */
/* +--------+-------------------------------------+---------+---------+------+ */
/* |   t1   | TX_EN/TX_ER sampled to MDI output   |   120   |    440  |  ns  | */
/* |   t2   | MDI input to CRS asserted           |   400   |   1040  |  ns  | */
/* |   t3   | MDI input to CRS deasserted         |   640   |   1120  |  ns  | */
/* |   t4   | MDI input to COL asserted           |     0   |      5  |  us  | */
/* |   t5   | MDI input to COL deasserted         |     0   |    3.2  |  us  | */
/* |   t6   | MDI input to RX_DV/RX_ER asserted   |   2.4   |      4  |  us  | */
/* |   t7   | MDI input to RX_DV/RX_ER deasserted |   640   |   1900  |  ns  | */
/* +--------+-------------------------------------+---------+---------+------+ */

real t1, t2, t3, t4, t5, t6, t7;

always @(top.new_values)
begin
    t1 = $urandom_range( 440,  120);
    t2 = $urandom_range(1040,  400);
    t3 = $urandom_range(1120,  640);
    t4 = $urandom_range(5000,    0);
    t5 = $urandom_range(3200,    0);
    t6 = $urandom_range(4000, 2400);
    t7 = $urandom_range(1900, 1000); // 640);
end


reg TX_EN1;
reg TX_ER1;

always @(TX_CLK)
begin
    TX_EN1 <= #(4 * bit_time) TX_EN;
    TX_ER1 <= #(4 * bit_time) TX_ER;
    TX  <= #t1 (TX_EN || TX_ER) ? TXD : 4'hZ;
    TXC <= #t1 (TX_EN || TX_EN1 || TX_ER || TX_ER1) ? TX_CLK : 1'bz;
    TXE <= #t1 TX_ER;
    TXF <= #t1 (TX_EN || TX_ER);
end


reg RXC_del;
reg RXE_del;
reg RXF_del;

always @(RXC)
begin
    RXC_del  <= #t7 RXC;
    RXE_del  <= #t7 RXE;
    RXF_del  <= #t7 RXF;
    RXD      <= #t7 RX;
end

event RX_ER_sample;
always @(posedge RXE) #t6 -> RX_ER_sample;
always @(RX_ER_sample) RX_ER = RXE_del;
always @(negedge RXE) #t7 RX_ER = FALSE;

event RX_DV_sample;
always @(posedge RXF) #t6 -> RX_DV_sample;
always @(RX_DV_sample) RX_DV = RXF_del;
always @(negedge RXF) #t7 RX_DV = FALSE;

always @(posedge RXF) #t2 CRS   = TRUE;
always @(negedge RXF) #t2 CRS   = FALSE;

reg local_clock;
initial local_clock = TRUE;

always @(RXC_del)
begin
    if (RXC_del === 1'bz && local_clock == FALSE)
    begin
        if(RX_CLK == 1'b1)
        begin
            force RX_CLK = 1'b1;
            #(2 * bit_time);
            @(negedge TX_CLK);
            release RX_CLK;
        end
        else
        begin
            force RX_CLK = 1'b0;
            #(2 * bit_time);
            @(posedge TX_CLK);
            release RX_CLK;
        end
        local_clock = TRUE;
    end
    else if (RXC_del !== 1'bz && local_clock == TRUE)
    begin
        if(RX_CLK == 1'b1)
        begin
            force RX_CLK = 1'b1;
            #(2 * bit_time);
            @(negedge RXC_del);
            release RX_CLK;
        end
        else
        begin
            force RX_CLK = 1'b0;
            #(2 * bit_time);
            @(posedge RXC_del);
            release RX_CLK;
        end
        local_clock = FALSE;
    end
end

assign RX_CLK = (local_clock == TRUE) ? TX_CLK : RXC_del;

`endif


endmodule
