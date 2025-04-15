/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_4_5_timer.v                                  */
/*        Date:   23/11/2024                                          */
/*                                                                    */
/**********************************************************************/

module           mod_148_4_5_timer (
                 commit_timer_done,
                 mii_clock_timer_done,
                 pending_timer_done,
                 commit_timer_not_done,
                 mii_clock_timer_not_done,
                 pending_timer_not_done
                 );

output           commit_timer_done;
output           mii_clock_timer_done;
output           pending_timer_done;
output           commit_timer_not_done;
output           mii_clock_timer_not_done;
output           pending_timer_not_done;

`ifdef simulate

/*                                                                      */
/* commit_timer                                                         */
/*                                                                      */

parameter       commit_timer_duration_min = 28750;  // 28750 ns 
parameter       commit_timer_duration_max = 28850;  // 28850 ns 

IEEE802_3_timer #(commit_timer_duration_min, commit_timer_duration_max)
commit_timer(
               .timer_done(commit_timer_done),
               .timer_not_done(commit_timer_not_done));

/*                                                                      */
/* mii_clock_timer                                                      */
/*                                                                      */

parameter       mii_clock_timer_duration_min = 0;  // 0 ns 
parameter       mii_clock_timer_duration_max = 0;  // 0 ns 

IEEE802_3_timer #(mii_clock_timer_duration_min, mii_clock_timer_duration_max)
mii_clock_timer(
               .timer_done(mii_clock_timer_done),
               .timer_not_done(mii_clock_timer_not_done));

/*                                                                      */
/* pending_timer                                                        */
/*                                                                      */

parameter       pending_timer_duration_min = 51150;  // 51150 ns 
parameter       pending_timer_duration_max = 51250;  // 51250 ns 

IEEE802_3_timer #(pending_timer_duration_min, pending_timer_duration_max)
pending_timer(
               .timer_done(pending_timer_done),
               .timer_not_done(pending_timer_not_done));

`endif

endmodule

