/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_147_3_7_2_timer.v                                 */
/*        Date:   21/06/2019                                          */
/*                                                                    */
/**********************************************************************/

module           mod_147_3_7_2_timer (
                 link_hold_timer_done,
                 link_hold_timer_not_done
                 );

output           link_hold_timer_done;
output           link_hold_timer_not_done;

`ifdef simulate

/*                                                                      */
/* link_hold_timer                                                      */
/*                                                                      */

parameter       link_hold_timer_duration_min = 49900000;  // 49.9 ms 
parameter       link_hold_timer_duration_max = 50100000;  // 50.1 ms 

IEEE802_3_timer #(link_hold_timer_duration_min, link_hold_timer_duration_max)
link_hold_timer(
               .timer_done(link_hold_timer_done),
               .timer_not_done(link_hold_timer_not_done));

`endif

endmodule

