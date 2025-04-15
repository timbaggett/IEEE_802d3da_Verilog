/**********************************************************************/
/*                           IEEE P802.3br                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_99_7_func.v                                     */
/*        Date:   17/01/2022                                          */
/*                                                                    */
/**********************************************************************/


/**********************************************************************/
/*                                                                    */
/* rRX_DATA function                                                  */
/*                                                                    */
/**********************************************************************/

function[7:0] rRX_DATA;
input         null;
begin
    rRX_DATA = MMS.mod_inst_99_4_7_func.rRX_DATA_function(null);
end
endfunction


/**********************************************************************/
/*                                                                    */
/* RX_MCRC_CK function                                                */
/*                                                                    */
/**********************************************************************/

function      RX_MCRC_CK;
input         null;
begin
    RX_MCRC_CK = MMS.mod_inst_99_4_7_func.RX_MCRC_CK_function(null);
end
endfunction

event RX_MCRC_CK_change;

always @(MMS.mod_inst_99_4_7_func.RX_MCRC_CK_function_change)
begin
    -> RX_MCRC_CK_change;
end


/**********************************************************************/
/*                                                                    */
/* SMD_DECODE task                                                    */
/*                                                                    */
/**********************************************************************/

task          SMD_DECODE;
input[7:0]    start_mPacket_delimiter;

begin
    MMS.mod_inst_99_4_7_func.SMD_DECODE_task(start_mPacket_delimiter);
end
endtask


/**********************************************************************/
/*                                                                    */
/* eRX_DATA task                                                      */
/*                                                                    */
/**********************************************************************/

task          eRX_DATA;
input[7:0]    data;
begin
    MMS.mod_inst_99_4_7_func.eRX_DATA_task(data);
end
endtask


/**********************************************************************/
/*                                                                    */
/* eRX_DV task                                                        */
/*                                                                    */
/**********************************************************************/

task          eRX_DV;
input         data_valid;
begin
    MMS.mod_inst_99_4_7_func.eRX_DV_task(data_valid);
end
endtask


