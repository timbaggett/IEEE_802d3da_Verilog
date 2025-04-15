`define initialise_PLCA_RS(i)                                                           \
                                                                                        \
initial                                                                                 \
begin                                                                                   \
                                                                                        \
    top.dte_node_``i``.RS.plca_reset                   = true;                          \
    top.dte_node_``i``.RS.plca_en                      = false;                         \
                                                                                        \
    top.dte_node_``i``.RS.coordinator_role_allowed     = false;                         \
    top.dte_node_``i``.RS.dplca_en                     = false;                         \
                                                                                        \
    force top.dte_node_``i``.RS.max_bc                 = 0;                             \
                                                                                        \
    top.dte_node_``i``.RS.plca_node_count              = 8'h08;                         \
                                                                                        \
    top.dte_node_``i``.RS.hard_aging_cycles            = 32'd100;                       \
    top.dte_node_``i``.RS.soft_aging_cycles            = 32'h8;                         \
                                                                                        \
end                                                                                     \
                                                                                        \