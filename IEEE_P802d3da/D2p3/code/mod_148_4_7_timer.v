/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_4_7_timer.v                                  */
/*        Date:   22/11/2024                                          */
/*                                                                    */
/**********************************************************************/

module           mod_148_4_7_timer (
                 wait_beacon_timer_done,
                 wait_beacon_timer_not_done,
                 loopback_timer_done,
                 loopback_timer_not_done
                 );

output           wait_beacon_timer_done;
output           wait_beacon_timer_not_done;
output           loopback_timer_done;
output           loopback_timer_not_done;

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

//IEEE802_3_timer #(4_500, 4_500) // 4.5 us
IEEE802_3_timer #(1, 1) // 4.5 us
loopback_timer(
               .timer_done(loopback_timer_done),
               .timer_not_done(loopback_timer_not_done));



`endif

endmodule

