/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_147_3_7_1_timer.v                               */
/*        Date:   21/06/2019                                          */
/*                                                                    */
/**********************************************************************/

module           mod_147_3_7_1_timer (
                 hb_send_timer_done,
                 hb_timer_done,
                 hb_send_timer_not_done,
                 hb_timer_not_done
                 );

output           hb_send_timer_done;
output           hb_timer_done;
output           hb_send_timer_not_done;
output           hb_timer_not_done;

`ifdef simulate

/*                                                                      */
/* hb_send_timer                                                        */
/*                                                                      */

parameter       hb_send_timer_duration_min = 1950;  // 1950 ns 
parameter       hb_send_timer_duration_max = 2050;  // 2050 ns 

IEEE802_3_timer #(hb_send_timer_duration_min, hb_send_timer_duration_max)
hb_send_timer(
               .timer_done(hb_send_timer_done),
               .timer_not_done(hb_send_timer_not_done));

/*                                                                      */
/* hb_timer                                                             */
/*                                                                      */

parameter       hb_timer_duration_min = 49900000;  // 49900 us 
parameter       hb_timer_duration_max = 49900000; //50100000;  // 50100 us 

IEEE802_3_timer #(hb_timer_duration_min, hb_timer_duration_max)
hb_timer(
               .timer_done(hb_timer_done),
               .timer_not_done(hb_timer_not_done));

`endif

endmodule

