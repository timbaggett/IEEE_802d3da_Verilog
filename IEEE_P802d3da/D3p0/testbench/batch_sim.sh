#!/usr/bin/bash
./sim_run.sh -DAGING_CYCLES=32 -DNUM_TX_PKTS=20 -DNO_RANDOM_TX -DRAND_TX_MAX=1_000_000
mv IEEE802_3da_MultiNodes.fst wpc_aging32_fullblast.fst
mv output wpc_aging32_fullblast.txt

./sim_run.sh -DAGING_CYCLES=64 -DNUM_TX_PKTS=20 -DNO_RANDOM_TX -DRAND_TX_MAX=1_000_000
mv IEEE802_3da_MultiNodes.fst wpc_aging64_fullblast.fst
mv output wpc_aging64_fullblast.txt

./sim_run.sh -DAGING_CYCLES=128 -DNUM_TX_PKTS=20 -DNO_RANDOM_TX -DRAND_TX_MAX=1_000_000
mv IEEE802_3da_MultiNodes.fst wpc_aging128_fullblast.fst
mv output wpc_aging128_fullblast.txt

./sim_run.sh -DAGING_CYCLES=32 -DNUM_TX_PKTS=20 -DRANDOM_TX -DRAND_TX_MAX=1_000_000
mv IEEE802_3da_MultiNodes.fst wpc_aging32.fst
mv output wpc_aging32.txt

./sim_run.sh -DAGING_CYCLES=64 -DNUM_TX_PKTS=20 -DRANDOM_TX -DRAND_TX_MAX=1_000_000
mv IEEE802_3da_MultiNodes.fst wpc_aging64.fst
mv output wpc_aging64.txt

./sim_run.sh -DAGING_CYCLES=128 -DNUM_TX_PKTS=20 -DRANDOM_TX -DRAND_TX_MAX=1_000_000
mv IEEE802_3da_MultiNodes.fst wpc_aging128.fst
mv output wpc_aging128.txt
