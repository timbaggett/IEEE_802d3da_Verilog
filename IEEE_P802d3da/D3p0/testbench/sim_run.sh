#!/usr/bin/bash
iverilog -I "../code" -I "../../.." -Wmacro-replacement -D simulate $1 $2 $3 $4 $5 $6 $7 $8 $9 -o "IEEE_P802_3da_MultiNodes.ve" IEEE_P802_3da_MultiNodes.f 2>&1 | tee output

#read -p "Press enter to simulate..."

vvp IEEE_P802_3da_MultiNodes.ve -fst
