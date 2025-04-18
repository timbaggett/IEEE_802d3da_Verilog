/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_4_7_func.v                                  */
/*        Date:   22/11/2024                                          */
/*                                                                    */
/**********************************************************************/

module           mod_148_4_7_func(
                 CLEAR_TXOP_TABLE_done,
                 mod_148_9_ARRAY_ASSIGN_$D$11_done
                 );

output           CLEAR_TXOP_TABLE_done;
output           mod_148_9_ARRAY_ASSIGN_$D$11_done;

reg              CLEAR_TXOP_TABLE_done;
reg              mod_148_9_ARRAY_ASSIGN_$D$11_done;


`ifdef simulate
`include "IEEE_P802_3da_param.v"
`include "mod_148_4_7_param.v"
`include "mod_148_4_7_func_include.v"


/**********************************************************************/
/*                                                                    */
/* CLEAR_TXOP_TABLE task                                              */
/*                                                                    */
/**********************************************************************/

task          CLEAR_TXOP_TABLE;
input         table_name;
begin
    CLEAR_TXOP_TABLE_done = false;
    plca.mod_inst_148_4_7_func.CLEAR_TXOP_TABLE_task(table_name);
end
endtask

event         CLEAR_TXOP_TABLE_task_done;

always @(CLEAR_TXOP_TABLE_task_done)
begin
    CLEAR_TXOP_TABLE_done = true;
end


/**********************************************************************/
/*                                                                    */
/* mod_148_9_ARRAY_ASSIGN_$D$11 task                                  */
/*                                                                    */
/**********************************************************************/

task          mod_148_9_ARRAY_ASSIGN_$D$11;
begin
    mod_148_9_ARRAY_ASSIGN_$D$11_done = false;
    plca.mod_inst_148_4_7_func.mod_148_9_ARRAY_ASSIGN_$D$11_task;
end
endtask

event         mod_148_9_ARRAY_ASSIGN_$D$11_task_done;

always @(mod_148_9_ARRAY_ASSIGN_$D$11_task_done)
begin
    mod_148_9_ARRAY_ASSIGN_$D$11_done = true;
end

/**********************************************************************/
/*                                                                    */
/* HARD_CLAIMING function                                             */
/*                                                                    */
/* Used  as  a  state  exit  condition so the action [name]_change is */
/* included in the state diagram sensitivity list. The action must be */
/* triggered every time there is a change in value.                   */
/*                                                                    */
/**********************************************************************/

event         HARD_CLAIMING_change;

function      automatic HARD_CLAIMING;
input[7:0]    nodeID;
begin

    HARD_CLAIMING = plca.mod_inst_148_4_7_func.HARD_CLAIMING_function(nodeID);

// $display("time = %0t HARD_CLAIMING = %0b nodeID = 0x%0h", $time, HARD_CLAIMING, nodeID);
// $display("time = %0t mod_148_8_state = 0x%0h next_mod_148_8_state = 0x%0h", $time, mod_inst_148_8.mod_148_8_state, mod_inst_148_8.next_mod_148_8_state);

   -> HARD_CLAIMING_change;

end
endfunction


/**********************************************************************/
/*                                                                    */
/* MAX_HARD_CLAIM function                                            */
/*                                                                    */
/* Used  as  a  state  exit  condition so the action [name]_change is */
/* included in the state diagram sensitivity list. The action must be */
/* triggered every time there is a change in value.                   */
/*                                                                    */
/**********************************************************************/

event         MAX_HARD_CLAIM_change;

function      MAX_HARD_CLAIM;
input         null_value;
begin

    MAX_HARD_CLAIM = plca.mod_inst_148_4_7_func.MAX_HARD_CLAIM_function(null_value);

    -> MAX_HARD_CLAIM_change;

end
endfunction

/**********************************************************************/
/*                                                                    */
/* PICK_FREE_TXOP function                                            */
/*                                                                    */
/**********************************************************************/

function[7:0] PICK_FREE_TXOP;
input         null_value;
begin

    PICK_FREE_TXOP = plca.mod_inst_148_4_7_func.PICK_FREE_TXOP_function(null_value);

end
endfunction

`endif

endmodule


