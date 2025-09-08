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
                 beacon_timeout_timer_done,
                 wait_beacon_timer_not_done,
                 beacon_timeout_timer_not_done
                 );

output           wait_beacon_timer_done;
output           beacon_timeout_timer_done;
output           wait_beacon_timer_not_done;
output           beacon_timeout_timer_not_done;

`ifdef simulate

/*                                                                      */
/* wait_beacon_timer                                                    */
/*                                                                      */

parameter       wait_beacon_timer_duration_min  = 40;    // 40 BT
parameter       wait_beacon_timer_duration_max  = 295;   // 295 BT
parameter       wait_beacon_timer_duration_mult = 400;   // 400 ns

IEEE802_3_timer_rand #(wait_beacon_timer_duration_min, wait_beacon_timer_duration_max, wait_beacon_timer_duration_mult)
wait_beacon_timer(
               .timer_done(wait_beacon_timer_done),
               .timer_not_done(wait_beacon_timer_not_done));

`endif

/*                                                                      */
/* beacon_timeout_timer                                                 */
/*                                                                      */

parameter       beacon_timeout_timer_duration_min = 6800;  // 6800 ns
parameter       beacon_timeout_timer_duration_max = 7000;  // 7000 ns

IEEE802_3_timer #(beacon_timeout_timer_duration_min, beacon_timeout_timer_duration_max)
beacon_timeout_timer(
               .timer_done(beacon_timeout_timer_done),
               .timer_not_done(beacon_timeout_timer_not_done));

endmodule

