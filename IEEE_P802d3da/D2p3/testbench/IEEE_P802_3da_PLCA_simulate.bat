iverilog -I "..\code" -I "..\..\.." -Wmacro-replacement -D simulate -o "IEEE_P802_3da_PLCA.ve" IEEE_P802_3da_PLCA.f 

pause

vvp IEEE_P802_3da_PLCA.ve -fst
