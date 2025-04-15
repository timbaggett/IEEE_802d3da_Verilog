/**********************************************************************/
/*                           IEEE P802.3cg                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_147_3_2_timer.v                                  */
/*        Date:   19/06/2019                                          */
/*                                                                    */
/**********************************************************************/

module           mod_147_3_2_timer (
                 symb_timer_done,
                 unjab_timer_done,
                 xmit_max_timer_done,
                 symb_timer_not_done,
                 unjab_timer_not_done,
                 xmit_max_timer_not_done
                 );

output           symb_timer_done;
output           unjab_timer_done;
output           xmit_max_timer_done;
output           symb_timer_not_done;
output           unjab_timer_not_done;
output           xmit_max_timer_not_done;

`ifdef simulate

/*                                                                      */
/* symb_timer                                                           */
/*                                                                      */

parameter       symb_timer_duration_min = 400;  // 399.96 ns 
parameter       symb_timer_duration_max = 400;  // 400.04 ns 

//parameter       symb_timer_duration_min = 399.96;  // 399.96 ns 
//parameter       symb_timer_duration_max = 400.04;  // 400.04 ns 

IEEE802_3_timer #(symb_timer_duration_min, symb_timer_duration_max)
symb_timer(
               .timer_done(symb_timer_done),
               .timer_not_done(symb_timer_not_done));

/*                                                                      */
/* unjab_timer                                                          */
/*                                                                      */

parameter       unjab_timer_duration_min = 15900000;  // 15.9 ms 
parameter       unjab_timer_duration_max = 16100000;  // 16.1 ms 

IEEE802_3_timer #(unjab_timer_duration_min, unjab_timer_duration_max)
unjab_timer(
               .timer_done(unjab_timer_done),
               .timer_not_done(unjab_timer_not_done));

/*                                                                      */
/* xmit_max_timer                                                       */
/*                                                                      */

parameter       xmit_max_timer_duration_min = 1800000;  // 1.8 ms 
parameter       xmit_max_timer_duration_max = 2200000;  // 2.2 ms 

IEEE802_3_timer #(xmit_max_timer_duration_min, xmit_max_timer_duration_max)
xmit_max_timer(
               .timer_done(xmit_max_timer_done),
               .timer_not_done(xmit_max_timer_not_done));

`endif

endmodule

