#!/usr/bin/bash
iverilog -I "../code" -I "../../.." -Wmacro-replacement -D simulate -o "IEEE_P802_3da_PLCA7Nodes.ve" IEEE_P802_3da_PLCA7Nodes.f 

read -p "Press enter to simulate..."

vvp IEEE_P802_3da_PLCA7Nodes.ve -fst
