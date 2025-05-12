/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_4_4_timer.v                                 */
/*        Date:   21/11/2024                                          */
/*                                                                    */
/**********************************************************************/

module           mod_148_4_4_timer (
                 beacon_timer_done,
                 beacon_det_timer_done,
                 invalid_beacon_timer_done,
                 burst_timer_done,
                 to_timer_done,
                 beacon_timer_not_done,
                 beacon_det_timer_not_done,
                 invalid_beacon_timer_not_done,
                 burst_timer_not_done,
                 to_timer_not_done
                 );

output           beacon_timer_done;
output           beacon_det_timer_done;
output           invalid_beacon_timer_done;
output           burst_timer_done;
output           to_timer_done;
output           beacon_timer_not_done;
output           beacon_det_timer_not_done;
output           invalid_beacon_timer_not_done;
output           burst_timer_not_done;
output           to_timer_not_done;

`ifdef simulate

/*                                                                      */
/* beacon_timer                                                         */
/*                                                                      */

parameter       beacon_timer_duration_min = 1950;  // 1950 ns 
parameter       beacon_timer_duration_max = 2050;  // 2050 ns 

IEEE802_3_timer #(beacon_timer_duration_min, beacon_timer_duration_max)
beacon_timer(
               .timer_done(beacon_timer_done),
               .timer_not_done(beacon_timer_not_done));

/*                                                                      */
/* beacon_det_timer                                                     */
/*                                                                      */

parameter       beacon_det_timer_duration_min = 2150;  // 2150 ns 
parameter       beacon_det_timer_duration_max = 2250;  // 2250 ns 

IEEE802_3_timer #(beacon_det_timer_duration_min, beacon_det_timer_duration_max)
beacon_det_timer(
               .timer_done(beacon_det_timer_done),
               .timer_not_done(beacon_det_timer_not_done));

/*                                                                      */
/* invalid_beacon_timer                                                 */
/*                                                                      */

parameter       invalid_beacon_timer_duration_min = 3600;  // 3600 ns 
parameter       invalid_beacon_timer_duration_max = 4400;  // 4400 ns 

IEEE802_3_timer #(invalid_beacon_timer_duration_min, invalid_beacon_timer_duration_max)
invalid_beacon_timer(
               .timer_done(invalid_beacon_timer_done),
               .timer_not_done(invalid_beacon_timer_not_done));

/*                                                                      */
/* burst_timer                                                          */
/*                                                                      */

parameter       burst_timer_duration_min = 12750;  // 12750 ns 
parameter       burst_timer_duration_max = 12850;  // 12850 ns 

IEEE802_3_timer #(burst_timer_duration_min, burst_timer_duration_max)
burst_timer(
               .timer_done(burst_timer_done),
               .timer_not_done(burst_timer_not_done));

/*                                                                      */
/* to_timer                                                             */
/*                                                                      */

parameter       to_timer_duration_min = 3195;
parameter       to_timer_duration_max = 3205;

IEEE802_3_timer #(to_timer_duration_min, to_timer_duration_max)
to_timer(
               .timer_done(to_timer_done),
               .timer_not_done(to_timer_not_done));

`endif

endmodule

