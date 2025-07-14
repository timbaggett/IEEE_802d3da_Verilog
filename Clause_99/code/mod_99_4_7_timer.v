/**********************************************************************/
/*                           IEEE P802.3br                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_99_4_7_timer.v                                   */
/*        Date:   14/01/2022                                          */
/*                                                                    */
/**********************************************************************/

module           mod_99_4_7_timer (
                 ipg_timer_done,
                 verify_timer_done,
                 ipg_timer_not_done,
                 verify_timer_not_done
                 );

output           ipg_timer_done;
output           verify_timer_done;
output           ipg_timer_not_done;
output           verify_timer_not_done;

`ifdef simulate

/*                                                                      */
/* ipg_timer                                                            */
/*                                                                      */

parameter       ipg_timer_duration_min = 9600;  // 9600 ns 
parameter       ipg_timer_duration_max = 9600;  // 9600 ns 

IEEE802_3_timer #(ipg_timer_duration_min, ipg_timer_duration_max)
ipg_timer(
               .timer_done(ipg_timer_done),
               .timer_not_done(ipg_timer_not_done));

/*                                                                      */
/* verify_timer                                                         */
/*                                                                      */

parameter       verify_timer_duration_min = 8000000;   // 8 ms 
parameter       verify_timer_duration_max = 12000000;  // 12 ms 

IEEE802_3_timer #(verify_timer_duration_min, verify_timer_duration_max)
verify_timer(
               .timer_done(verify_timer_done),
               .timer_not_done(verify_timer_not_done));

`endif

endmodule