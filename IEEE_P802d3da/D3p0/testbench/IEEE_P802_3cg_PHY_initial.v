`define initialise_PHY(i)                                                               \
                                                                                        \
initial                                                                                 \
begin                                                                                   \
                                                                                        \
    force top.dte_node_``i``.PHY.pcs_reset                   = true;                    \
    force top.dte_node_``i``.PHY.pma_reset                   = true;                    \
                                                                                        \
    force top.dte_node_``i``.PHY.duplex_mode                 =                          \
          top.dte_node_``i``.PHY.mod_inst_147_7.DUPLEX_HALF;                            \
                                                                                        \
    #200;                                                                               \
                                                                                        \
    force top.dte_node_``i``.PHY.pcs_reset                   = false;                   \
    force top.dte_node_``i``.PHY.pma_reset                   = false;                   \
                                                                                        \
end                                                                                     \