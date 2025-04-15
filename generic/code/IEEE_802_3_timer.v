/**********************************************************************/
/*             IEEE P802.3bu Power over Data Lines (PoDL)             */
/**********************************************************************/
/*                                                                    */
/*        Module: IEEE802_3_timer.v                                   */
/*        Date:   21/09/2016                                          */
/*                                                                    */
/**********************************************************************/
/*                                                                    */
/* All timers operate in  the  manner  described in 14.2.3.2 with the */
/* following addition: a timer  is  reset  and  stops  counting  upon */
/* entering a state where “stop x_timer” is asserted.                 */
/*                                                                    */
/* 14.2.3.2 State diagram timers                                      */
/*                                                                    */
/* All timers operate in the same fashion. A timer resets and  starts */
/* counting upon entering a state where x_timer is asserted. Time "x" */
/* after the timer has  been  started, "x_timer_done" is asserted and */
/* remains asserted until the timer is  reset. At  all  other  times, */
/* "x_timer_not_done" is asserted.                                    */
/*                                                                    */
/* When entering a state where "start x_timer" is asserted, the timer */
/* is reset and  restarted  even  if the entered state is the same as */
/* the exited state; for example, when in the Link Test Pass state of */
/* the   Link   Integrity    Test   function   state   diagram,   the */
/* "link_loss_timer"   and   the  "link_test_min_timer"   are   reset */
/* each   time    the    term   "RD = active + ( link_test_rcv=true * */
/* link_test_min_timer_done)" is satisfied.                           */
/*                                                                    */
/**********************************************************************/

module IEEE802_3_timer(
            timer_done,
            timer_not_done
            );

parameter   timer_duration_min = 0;
parameter   timer_duration_max = 0;

output      timer_not_done;
output      timer_done;

reg         timer_not_done;
reg         timer_done;

parameter   TRUE  = 1,
            FALSE = 0;

`ifdef simulate

event       start;
event       stop;
event       start_timer;

real        timer_duration;

initial
begin
    timer_duration = $urandom_range(timer_duration_max, timer_duration_min) - 1;
end

always @(top.new_values)
begin
    timer_duration = $urandom_range(timer_duration_max, timer_duration_min) - 1;
end


initial
begin
    #0.001;
    disable timer_block;
    timer_done     = FALSE;
    timer_not_done = TRUE;
end

always @(stop)
begin
    disable timer_block;
    timer_done     = FALSE;
    timer_not_done = TRUE;
end

always @(start)
begin
    disable timer_block;
    timer_done     = FALSE;
    timer_not_done = TRUE;
    #1;
    -> start_timer;
end

always @(start_timer)
begin : timer_block
   #(timer_duration);
   timer_done     = TRUE;
   timer_not_done = FALSE;
end

`endif

endmodule



