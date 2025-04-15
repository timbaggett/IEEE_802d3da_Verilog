/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_4_6_timer.v                                  */
/*        Date:   23/11/2024                                          */
/*                                                                    */
/**********************************************************************/

module           mod_148_4_6_timer (
                 plca_status_timer_done,
                 plca_status_timer_not_done
                 );

output           plca_status_timer_done;
output           plca_status_timer_not_done;

`ifdef simulate

/*                                                                      */
/* plca_status_timer                                                    */
/*                                                                      */

parameter       plca_status_timer_duration_min = 130090;  // 130090 ns 
parameter       plca_status_timer_duration_max = 140090;  // 140090 ns 

// parameter       plca_status_timer_duration_min = 13009000; // 130 090 bit times
// parameter       plca_status_timer_duration_max = 14009000; // 130 090 + 10 000 bit times

IEEE802_3_timer #(plca_status_timer_duration_min, plca_status_timer_duration_max)
plca_status_timer(
               .timer_done(plca_status_timer_done),
               .timer_not_done(plca_status_timer_not_done));

`endif

endmodule

