parameter        FALSE               =  1'b0;
parameter        TRUE                =  1'b1;
parameter        false               =  1'b0;
parameter        true                =  1'b1;
parameter        UNKNOWN             =  1'bx;

parameter        no_delay            = 3'b000;
parameter        minimum_delay       = 3'b001;
parameter        typical_delay       = 3'b010;
parameter        maximum_delay       = 3'b011;
parameter        random_delay        = 3'b100;

/*                                                                    */
/* Define arathmetic functions                                        */
/* ===========================                                        */
/*                                                                    */

function[3:0] sum;
input[2:0]    a;
input[2:0]    b;

begin
    sum = a + b;
end
endfunction


function[3:0] min;
input[3:0]    a;
input[3:0]    b;

begin
if (a < b)
    begin
        min = a;
    end
    else
    begin
        min = b;
    end
end
endfunction

function[23:0] FIVEB_ASCII;
input[4:0] symbol;
begin
    case(symbol)
    5'b11110 : FIVEB_ASCII = "/0/";
    5'b01001 : FIVEB_ASCII = "/1/";
    5'b10100 : FIVEB_ASCII = "/2/";
    5'b10101 : FIVEB_ASCII = "/3/";
    5'b01010 : FIVEB_ASCII = "/4/";
    5'b01011 : FIVEB_ASCII = "/5/";
    5'b01110 : FIVEB_ASCII = "/6/";
    5'b01111 : FIVEB_ASCII = "/7/";
    5'b10010 : FIVEB_ASCII = "/8/";
    5'b10011 : FIVEB_ASCII = "/9/";
    5'b10110 : FIVEB_ASCII = "/A/";
    5'b10111 : FIVEB_ASCII = "/B/";
    5'b11010 : FIVEB_ASCII = "/C/";
    5'b11011 : FIVEB_ASCII = "/D/";
    5'b11100 : FIVEB_ASCII = "/E/";
    5'b11101 : FIVEB_ASCII = "/F/";
    5'b11111 : FIVEB_ASCII = "/I/";
    5'b11000 : FIVEB_ASCII = "/J/";
    5'b10001 : FIVEB_ASCII = "/K/";
    5'b01101 : FIVEB_ASCII = "/T/";
    5'b00111 : FIVEB_ASCII = "/R/";
    5'b00100 : FIVEB_ASCII = "/H/";
    5'b01000 : FIVEB_ASCII = "/N/";
    5'b11001 : FIVEB_ASCII = "/S/";
    default  : FIVEB_ASCII = "ERR";
    endcase
end
endfunction


function [95:0] RX_ASCII;
input[4:0] symbol;
begin
    case(symbol)
    5'h04 : RX_ASCII = "SSD";
    5'h0D : RX_ASCII = "ESD";
    5'h07 : RX_ASCII = "ESDOK/ESDBRS";
    5'h11 : RX_ASCII = "ESDERR";
    5'h18 : RX_ASCII = "SYNC/COMMIT";
    5'h19 : RX_ASCII = "ESDJAB";
    5'h1F : RX_ASCII = "SILENCE";
    default : RX_ASCII = "OTHER";
    endcase
end
endfunction


