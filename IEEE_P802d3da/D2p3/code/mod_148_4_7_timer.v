/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_4_7_timer.v                                 */
/*        Date:   22/11/2024                                          */
/*                                                                    */
/**********************************************************************/

module           mod_148_4_7_timer (
                 wait_beacon_timer_done,
                 wait_beacon_timer_not_done
                 );

output           wait_beacon_timer_done;
output           wait_beacon_timer_not_done;

`ifdef simulate

/*                                                                      */
/* wait_beacon_timer                                                    */
/*                                                                      */

parameter       wait_beacon_timer_duration_min = 3900;  // 3900 ns 
parameter       wait_beacon_timer_duration_max = 4100;  // 4100 ns 

IEEE802_3_timer #(wait_beacon_timer_duration_min, wait_beacon_timer_duration_max)
wait_beacon_timer(
               .timer_done(wait_beacon_timer_done),
               .timer_not_done(wait_beacon_timer_not_done));

`endif

endmodule

