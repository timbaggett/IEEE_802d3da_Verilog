/**********************************************************************/
/*                           IEEE P802.3da                            */
/**********************************************************************/
/*                                                                    */
/*        Module: mod_148_4_7_func_include.v                          */
/*        Date:   22/11/2024                                          */
/*                                                                    */
/**********************************************************************/





/**********************************************************************/
/*                                                                    */
/* CLEAR_SOFT_CLAIMS_task task                                        */
/*                                                                    */
/**********************************************************************/

task          CLEAR_SOFT_CLAIMS_task;
input         table_name;
integer       i;
begin
    
    for(i = 0; i <= 255; i = i + 1)
    begin
        if(table_name == CLAIM_TABLE && plca.txop_claim_table[i] == SOFT)
        begin
            plca.txop_claim_table[i] = NONE;
        end
        if(table_name == CLAIM_TABLE_NEW && plca.txop_claim_table_new[i] == SOFT)
        begin
            plca.txop_claim_table_new[i] = NONE;
        end
    end

end
endtask


/**********************************************************************/
/*                                                                    */
/* CLEAR_TXOP_TABLE_task task                                         */
/*                                                                    */
/**********************************************************************/

task          CLEAR_TXOP_TABLE_task;
input         table_name;
integer       i;
begin
    
    for(i = 0; i <= 255; i = i + 1)
    begin
        if(table_name == CLAIM_TABLE)
        begin
            plca.txop_claim_table[i] = NONE;
        end
        if(table_name == CLAIM_TABLE_NEW)
        begin
            plca.txop_claim_table_new[i] = NONE;
        end
    end

end
endtask


/**********************************************************************/
/*                                                                    */
/* mod_148_9_ARRAY_ASSIGN_$D$11_task task                             */
/*                                                                    */
/**********************************************************************/

task          mod_148_9_ARRAY_ASSIGN_$D$11_task;
integer       i;
begin
    
    for(i = 0; i <= 255; i = i + 1)
    begin
        plca.txop_claim_table[i] = plca.txop_claim_table_new[i];
    end

end
endtask


/**********************************************************************/
/*                                                                    */
/* HARD_CLAIMING function                                             */
/*                                                                    */
/**********************************************************************/
/*                                                                    */
/* This  function takes  as  parameter  “ID”,  a transmit opportunity */
/* integer number  in the range of 0 to 255. It returns the result of */
/* the following  boolean expression:                                 */
/*  dplca_txop_end * (dplca_txop_claim = HARD) * (dplca_txop_id = ID) */
/*                                                                    */
/**********************************************************************/

function      automatic  HARD_CLAIMING_function;
input[7:0]    nodeID;
begin

    HARD_CLAIMING_function = plca.dplca_txop_end * (plca.dplca_txop_claim == HARD) * (plca.dplca_txop_id == nodeID);

end
endfunction


/**********************************************************************/
/*                                                                    */
/* MAX_HARD_CLAIM function                                            */
/*                                                                    */
/**********************************************************************/
/*                                                                    */
/* This  function takes as parameter  the txop_claim_table defined in */
/* 148.4.7.2.  It returns the highest ID in the table which is marked */
/* as HARD claimed.  Note that the ID claimed by the  local node does */
/* not count as claimed.                                              */
/*                                                                    */
/**********************************************************************/

function      MAX_HARD_CLAIM_function;
input         null_value;
integer       i;
begin

    MAX_HARD_CLAIM_function = 7'h00;
    
    for(i = 0; i <= 255; i = i + 1)
    begin

// Need to add exclusion for ID claimed by the local node
// Need to define what value is returned if no HARD found

        if(plca.txop_claim_table_new[i] == HARD)
        begin
            MAX_HARD_CLAIM_function = i;
        end
    end

end
endfunction


/**********************************************************************/
/*                                                                    */
/* PICK_FREE_TXOP function                                            */
/*                                                                    */
/**********************************************************************/
/*                                                                    */
/* This function takes as  parameter the txop_claim_table  defined in */
/* 148.4.7.2.  It returns any ID  that  is not marked as HARD or SOFT */
/* claimed in the table, with the following exceptions:               */
/*                                                                    */
/* a. it  shall  not  return  zero, which is  reserved  for the  PLCA */
/* coordinator                                                        */
/*                                                                    */
/* b. it  shall  not  return an ID  greater  than  the  highest  HARD */
/* claimed in the table, unless this is the only one available.       */
/*                                                                    */
/* Note that  it  is  allowed  for  this  function  to  return the ID */
/* currently  being  claimed by the  local node, unless it is claimed */
/* by another  node.  The  actual  criteria  for  choosing  among the */
/* available, allowed IDs is implementation defined.                  */
/*                                                                    */

function[7:0] PICK_FREE_TXOP_function;
input         null_value;
reg[8:0]      id_pick;
begin

    PICK_FREE_TXOP_function = 8'hXX;
    
    for(id_pick = 255; id_pick >= 1; id_pick = id_pick - 1)
    begin

        // $display("time = %0t PICK_FREE_TXOP_function = 0x%0h id_pick = 0x%0h txop_claim_table[id_pick] = 0x%0h", $time, PICK_FREE_TXOP_function, id_pick, plca.txop_claim_table[id_pick]);

        if(plca.txop_claim_table[id_pick] == NONE)
        begin
            PICK_FREE_TXOP_function = id_pick;
        end
    end
    // $display("time = %0t %m PICK_FREE_TXOP_function = 0x%0h", $time, PICK_FREE_TXOP_function);

end
endfunction


/**********************************************************************/
/*                                                                    */
/* SOFT_CLAIMING function                                             */
/*                                                                    */
/* This  function  takes as  parameter “ID”,  a transmit  opportunity */
/* integer number in the range of 0  to 255. It returns the result of */
/* the following boolean expression:                                  */
/*  dplca_txop_end * (dplca_txop_claim = SOFT) * (dplca_txop_id = ID) */
/*                                                                    */
/**********************************************************************/

function      automatic SOFT_CLAIMING_function;
input[7:0]    nodeID;

begin

    SOFT_CLAIMING_function = plca.dplca_txop_end * (plca.dplca_txop_claim == SOFT) * (plca.dplca_txop_id == nodeID);

end
endfunction



