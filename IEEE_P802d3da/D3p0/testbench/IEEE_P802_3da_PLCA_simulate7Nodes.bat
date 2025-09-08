iverilog -I "..\code" -I "..\..\.." -Wmacro-replacement -D simulate -o "IEEE_P802_3da_PLCA7Nodes.ve" IEEE_P802_3da_PLCA7Nodes.f 

pause

vvp IEEE_P802_3da_PLCA7Nodes.ve -fst
