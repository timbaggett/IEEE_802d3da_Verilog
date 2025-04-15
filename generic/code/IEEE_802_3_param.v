/**********************************************************************/
/*                           IEEE 802.3                               */
/**********************************************************************/
/*                                                                    */
/*        Module: IEEE_802_3_param.v                                  */
/*        Date:   03/02/2023                                          */
/*                                                                    */
/**********************************************************************/

parameter        FALSE               =  1'b0;
parameter        TRUE                =  1'b1;
parameter        false               =  1'b0;
parameter        true                =  1'b1;
parameter        UNKNOWN             =  1'bx;

parameter        zero                = 2'b00;
parameter        one                 = 2'b01;

parameter        no_delay            = 3'b000;
parameter        minimum_delay       = 3'b001;
parameter        typical_delay       = 3'b010;
parameter        maximum_delay       = 3'b011;
parameter        random_delay        = 3'b100;

/*                                                                    */
/* Define arathmetic functions                                        */
/* ===========================                                        */
/*                                                                    */

function [31:0] sum;
input[31:0] a;
input[31:0] b;
begin
    sum = a + b;
end
endfunction


function [31:0] min;
input signed [31:0] a;
input signed [31:0] b;

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


function [31:0] max;
input signed [31:0] a;
input signed [31:0] b;

begin
if (a > b)
    begin
        max = a;
    end
    else
    begin
        max = b;
    end
end
endfunction