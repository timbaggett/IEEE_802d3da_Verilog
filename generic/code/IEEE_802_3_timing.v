/**********************************************************************/
/*                                                                    */
/*        Module: IEEE_802_3_timing.v                                 */
/*        Date:   27/01/2025                                          */
/*                                                                    */
/**********************************************************************/

/*                                                                    */
/* Define parameterised rise fall delay elements                      */
/* =============================================                      */
/*                                                                    */

module delay_element(
             delay_element_input,
             delay_element_output,
             delay_type
             );

input        delay_element_input;
output       delay_element_output;
input[2:0]   delay_type;

`include "generic/code/IEEE_802_3_param.v"

parameter    delay_value_max = 0;
parameter    delay_value_min = 0;

real         delay_value;

always @(delay_type)
begin
    if(delay_type == no_delay)
    begin
        delay_value = 0;
    end
    else if(delay_type == minimum_delay)
    begin
        delay_value = delay_value_min;
    end
    else if(delay_type == typical_delay)
    begin
        delay_value = delay_value_min + (delay_value_max - delay_value_min)/2;
    end
    else if(delay_type == maximum_delay)
    begin
        delay_value = delay_value_max;
    end
    else if(delay_type == random_delay)
    begin
        delay_value = $urandom_range(delay_value_max, delay_value_min);
    end
    else
    begin
        delay_value = 0;
    end
end

always @(top.new_values)
begin
    if(delay_type == random_delay)
    begin
        delay_value = $urandom_range(delay_value_max, delay_value_min);
    end
end

reg delay_element_output;

always @(delay_element_input)
begin
    delay_element_output <= #delay_value delay_element_input;
end

endmodule


module diff_delay_element(
             delay_element_input_P,
             delay_element_input_N,
             delay_element_output_P,
             delay_element_output_N,
             delay_type
             );

input        delay_element_input_P;
input        delay_element_input_N;
output       delay_element_output_P;
output       delay_element_output_N;
input[2:0]   delay_type;

`include "generic/code/IEEE_802_3_param.v"

parameter    delay_value_max = 0;
parameter    delay_value_min = 0;

real         delay_value;

always @(delay_type)
begin
    if(delay_type == no_delay)
    begin
        delay_value = 0;
    end
    else if(delay_type == minimum_delay)
    begin
        delay_value = delay_value_min;
    end
    else if(delay_type == typical_delay)
    begin
        delay_value = delay_value_min + (delay_value_max - delay_value_min)/2;
    end
    else if(delay_type == maximum_delay)
    begin
        delay_value = delay_value_max;
    end
    else if(delay_type == random_delay)
    begin
        delay_value = $urandom_range(delay_value_max, delay_value_min);
    end
    else
    begin
        delay_value = 0;
    end
end

always @(top.new_values)
begin
    if(delay_type == random_delay)
    begin
       delay_value = $urandom_range(delay_value_max, delay_value_min);
    end
end

reg delay_element_output_N;
reg delay_element_output_P;

always @(delay_element_input_N)
begin
    delay_element_output_N <= #delay_value delay_element_input_N;
end

always @(delay_element_input_P)
begin
    delay_element_output_P <= #delay_value delay_element_input_P;
end

endmodule

/*                                                                    */
/* Define timing check elements                                       */
/* ============================                                       */
/*                                                                    */


module posedge_setup(
             clock,
             data
             );

parameter    setup_time = 0;

input        clock;
input        data;

real         clock_time;
real         data_time;

`ifdef simulate

always @(data)
begin
    data_time =  $time;
end

always @(posedge clock)
begin
    if (($time - data_time) < setup_time)
    begin
        $display($time, " %m Setup time error. Required: %f", setup_time, ", actual: ", $time - data_time, );
    end
end

`endif

endmodule



module posedge_posedge_max_delay(
             event1,
             event2
             );

parameter    delay_time = 0;

parameter    false = 1'b0;
parameter    true  = 1'b1;

input        event1;
input        event2;

real         event1_time;
real         event2_time;

reg          enabled;

`ifdef simulate

initial enabled = false;

always @(posedge event1)
begin
    event1_time = $time;
    enabled     = true;
end

always @(posedge event2)
begin
    if (enabled == true)
    begin
        if (($time - event1_time) > delay_time)
        begin
            $display($time, " %m Max delay time error. Required: %f", delay_time, ", actual: ", $time - event1_time);
        end
        enabled = false;
    end
end

`endif

endmodule
