/**********************************************************************/
/*                           IEEE P802.3br                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_99_5_func.v                                     */
/*        Date:   21/04/2022                                          */
/*                                                                    */
/**********************************************************************/



/**********************************************************************/
/*                                                                    */
/* rTX_CPLT task                                                      */
/*                                                                    */
/**********************************************************************/

reg           rTX_CPLT_done;

task          rTX_CPLT;
begin
    rTX_CPLT_done = false;
    MMS.mod_inst_99_4_7_func.rTX_CPLT_task;
end
endtask

event         rTX_CPLT_task_done;

always @(rTX_CPLT_task_done)
begin
    rTX_CPLT_done = true;
end


/**********************************************************************/
/*                                                                    */
/* rTX_DATA task                                                      */
/*                                                                    */
/**********************************************************************/

reg           rTX_DATA_done;

task          rTX_DATA;
input[7:0]    data;
begin
    rTX_DATA_done = false;
    MMS.mod_inst_99_4_7_func.rTX_DATA_task(data);
end
endtask

event         rTX_DATA_task_done;

always @(rTX_DATA_task_done)
begin
    rTX_DATA_done = true;
end


/**********************************************************************/
/*                                                                    */
/* pTX_DATA function                                                  */
/*                                                                    */
/**********************************************************************/

function[7:0]    pTX_DATA;
input         null;
begin
    pTX_DATA = MMS.mod_inst_99_4_7_func.pTX_DATA_function(null);
end
endfunction


/**********************************************************************/
/*                                                                    */
/* SFD_DET function                                                   */
/*                                                                    */
/* Used  as  a  state  exit  condition so the action [name]_change is */
/* included in the state diagram sensitivity list. The action must be */
/* triggered every time there is a change in value.                   */
/*                                                                    */
/**********************************************************************/

function         SFD_DET;
input         null;
begin
    SFD_DET = MMS.mod_inst_99_4_7_func.SFD_DET_function(null);
end
endfunction

event         SFD_DET_change;
event         SFD_DET_function_change;

always @(SFD_DET_function_change)
begin
    -> SFD_DET_change;
end


/**********************************************************************/
/*                                                                    */
/* SMDC_ENCODE task                                                   */
/*                                                                    */
/**********************************************************************/

reg           SMDC_ENCODE_done;

task          SMDC_ENCODE;
input[7:0]    frame_cnt;
begin
    SMDC_ENCODE_done = false;
    MMS.mod_inst_99_4_7_func.SMDC_ENCODE_task(frame_cnt);
end
endtask

event         SMDC_ENCODE_task_done;

always @(SMDC_ENCODE_task_done)
begin
    SMDC_ENCODE_done = true;
end


/**********************************************************************/
/*                                                                    */
/* SMDS_ENCODE function                                               */
/*                                                                    */
/**********************************************************************/

function[7:0]    SMDS_ENCODE;
input[7:0]    frame_cnt;
begin
    SMDS_ENCODE = MMS.mod_inst_99_4_7_func.SMDS_ENCODE_function(frame_cnt);
end
endfunction


/**********************************************************************/
/*                                                                    */
/* TX_MCRC task                                                       */
/*                                                                    */
/**********************************************************************/

reg           TX_MCRC_done;

task          TX_MCRC;
begin
    TX_MCRC_done = false;
    MMS.mod_inst_99_4_7_func.TX_MCRC_task;
end
endtask

event         TX_MCRC_task_done;

always @(TX_MCRC_task_done)
begin
    TX_MCRC_done = true;
end


/**********************************************************************/
/*                                                                    */
/* TX_R task                                                          */
/*                                                                    */
/**********************************************************************/

reg           TX_R_done;

task          TX_R;
begin
    TX_R_done = false;
    MMS.mod_inst_99_4_7_func.TX_R_task;
end
endtask

event         TX_R_task_done;

always @(TX_R_task_done)
begin
    TX_R_done = true;
end


/**********************************************************************/
/*                                                                    */
/* TX_V task                                                          */
/*                                                                    */
/**********************************************************************/

reg           TX_V_done;

task          TX_V;
begin
    TX_V_done = false;
    MMS.mod_inst_99_4_7_func.TX_V_task;
end
endtask

event         TX_V_task_done;

always @(TX_V_task_done)
begin
    TX_V_done = true;
end


/**********************************************************************/
/*                                                                    */
/* FRAG_ENCODE task                                                   */
/*                                                                    */
/**********************************************************************/

reg           FRAG_ENCODE_done;

task          FRAG_ENCODE;
input[7:0]    frag_cnt;
begin
    FRAG_ENCODE_done = false;
    MMS.mod_inst_99_4_7_func.FRAG_ENCODE_task(frag_cnt);
end
endtask

event         FRAG_ENCODE_task_done;

always @(FRAG_ENCODE_task_done)
begin
    FRAG_ENCODE_done = true;
end


/**********************************************************************/
/*                                                                    */
/* eTX_DATA function                                                  */
/*                                                                    */
/**********************************************************************/

function[7:0]    eTX_DATA;
input         null;
begin
    eTX_DATA = MMS.mod_inst_99_4_7_func.eTX_DATA_function(null);
end
endfunction

