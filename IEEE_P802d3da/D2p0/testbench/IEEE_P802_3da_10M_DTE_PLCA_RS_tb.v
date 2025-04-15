`timescale 1ns/100ps

module tb();

`include "IEEE_P802_3da_param.v"
`include "Clause 4\code\IEEE_802_3_2022_MAC_init.v"

reg[47:0]    destination_address;
reg[47:0]    source_address;
reg[71999:0] mac_service_data_unit;
reg[31:0]    frame_check_sequence;

reg[47:0]    rx_destination_address;
reg[47:0]    rx_source_address;
reg[71999:0] rx_mac_service_data_unit;
reg[31:0]    rx_frame_check_sequence;

reg[7:0]     i0;
reg[7:0]     i1;
reg[7:0]     i2;
reg[7:0]     i3;
reg[7:0]     i4;
reg[7:0]     i5;
reg[7:0]     i6;
reg[7:0]     i7;
reg[7:0]     i8;
reg[7:0]     i9;
reg[7:0]     i10;
reg[7:0]     i11;
reg[7:0]     i12;
reg[7:0]     i13;
reg[7:0]     i14;
reg[7:0]     i15;

initial
begin

    $dumpfile("IEEE802_3da.dump");
    $dumpvars(5, top, tb);

end

`initialise_MA_DATA_indication(0)
`initialise_MA_DATA_indication(1)
`initialise_MA_DATA_indication(2)
`initialise_MA_DATA_indication(3)
`initialise_MA_DATA_indication(4)
`initialise_MA_DATA_indication(5)
`initialise_MA_DATA_indication(6)
`initialise_MA_DATA_indication(7)
`initialise_MA_DATA_indication(8)
`initialise_MA_DATA_indication(9)
`initialise_MA_DATA_indication(10)
`initialise_MA_DATA_indication(11)
`initialise_MA_DATA_indication(12)
`initialise_MA_DATA_indication(13)
`initialise_MA_DATA_indication(14)
`initialise_MA_DATA_indication(15)

`initialise_MAC(0)
`initialise_MAC(1)
`initialise_MAC(2)
`initialise_MAC(3)
`initialise_MAC(4)
`initialise_MAC(5)
`initialise_MAC(6)
`initialise_MAC(7)
`initialise_MAC(8)
`initialise_MAC(9)
`initialise_MAC(10)
`initialise_MAC(11)
`initialise_MAC(12)
`initialise_MAC(13)
`initialise_MAC(14)
`initialise_MAC(15)


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



`initialise_PLCA_RS(0)
`initialise_PLCA_RS(1)
`initialise_PLCA_RS(2)
`initialise_PLCA_RS(3)
`initialise_PLCA_RS(4)
`initialise_PLCA_RS(5)
`initialise_PLCA_RS(6)
`initialise_PLCA_RS(7)
`initialise_PLCA_RS(8)
`initialise_PLCA_RS(9)
`initialise_PLCA_RS(10)
`initialise_PLCA_RS(11)
`initialise_PLCA_RS(12)
`initialise_PLCA_RS(13)
`initialise_PLCA_RS(14)
`initialise_PLCA_RS(15)


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
                                                                                        \


`initialise_PHY(0)
`initialise_PHY(1)
`initialise_PHY(2)
`initialise_PHY(3)
`initialise_PHY(4)
`initialise_PHY(5)
`initialise_PHY(6)
`initialise_PHY(7)
`initialise_PHY(8)
`initialise_PHY(9)
`initialise_PHY(10)
`initialise_PHY(11)
`initialise_PHY(12)
`initialise_PHY(13)
`initialise_PHY(14)
`initialise_PHY(15)


initial
begin

    #200;


    // Configure and then endable node 0

    top.dte_node_0.MAC.transmitEnabled             = true;
    top.dte_node_0.MAC.receiveEnabled              = true;

    top.dte_node_0.RS.plca_reset                   = false;
    top.dte_node_0.RS.coordinator_role_allowed     = true;
    top.dte_node_0.RS.dplca_en                     = true;

    // Configure and then endable node 1

    top.dte_node_1.MAC.transmitEnabled             = true;
    top.dte_node_1.MAC.receiveEnabled              = true;

    top.dte_node_1.RS.plca_reset                   = false;
    top.dte_node_1.RS.dplca_en                     = true;

    // Configure and then endable node 14

    top.dte_node_14.MAC.transmitEnabled            = true;
    top.dte_node_14.MAC.receiveEnabled             = true;

    top.dte_node_14.RS.plca_reset                  = false;
    top.dte_node_14.RS.dplca_en                    = true;

    // Configure and then endable node 15

    top.dte_node_15.MAC.transmitEnabled            = true;
    top.dte_node_15.MAC.receiveEnabled             = true;

    top.dte_node_15.RS.plca_reset                  = false;
    top.dte_node_15.RS.dplca_en                    = true;

    destination_address                            = 48'hFF_FF_FF_FF_FF_FF;
    source_address                                 = 48'h55_44_33_22_11_00;
    frame_check_sequence                           = 32'hXX_XX_XX_XX;

    mac_service_data_unit                          = {9000{8'h00}};
    mac_service_data_unit[15:0]                    = 16'd1500;
    mac_service_data_unit[100 * 8]                 = 1'bX;

    #2_000;

    fork 
        for (i0 = 0; i0 < 8; i0 = i0 + 1)
        begin
            top.dte_node_0.MAC.MA_DATA_request(destination_address, source_address, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 0 Packet sent");
        end

        for (i1 = 0; i1 < 8; i1 = i1 + 1)
        begin
            top.dte_node_1.MAC.MA_DATA_request(destination_address, source_address + 1, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 1 Packet sent");
        end

        for (i14 = 0; i14 < 8; i14 = i14 + 1)
        begin
            top.dte_node_14.MAC.MA_DATA_request(destination_address, source_address + 14, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 14 Packet sent");
        end

        for (i15 = 0; i15 < 8; i15 = i15 + 1)
        begin
            top.dte_node_15.MAC.MA_DATA_request(destination_address, source_address + 15, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 15 Packet sent");
        end

    join


    #200_000;

    force top.dte_node_0.RS.local_nodeID           = 0;
    top.dte_node_0.RS.plca_en                      = true;

    force top.dte_node_1.RS.local_nodeID           = 1;
    top.dte_node_1.RS.plca_en                      = true;

    force top.dte_node_14.RS.local_nodeID          = 2;
    top.dte_node_14.RS.plca_en                     = true;

    force top.dte_node_15.RS.local_nodeID          = 3;
    top.dte_node_15.RS.plca_en                     = true;

    #2_000;

    fork 
        for (i0 = 0; i0 < 8; i0 = i0 + 1)
        begin
            top.dte_node_0.MAC.MA_DATA_request(destination_address, source_address, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 0 Packet sent");
        end

        for (i1 = 0; i1 < 8; i1 = i1 + 1)
        begin
            top.dte_node_1.MAC.MA_DATA_request(destination_address, source_address + 1, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 1 Packet sent");
        end

        for (i14 = 0; i14 < 8; i14 = i14 + 1)
        begin
            top.dte_node_14.MAC.MA_DATA_request(destination_address, source_address + 14, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 14 Packet sent");
        end

        for (i15 = 0; i15 < 8; i15 = i15 + 1)
        begin
            top.dte_node_15.MAC.MA_DATA_request(destination_address, source_address + 15, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 15 Packet sent");
        end

    join


    $stop;
    $finish;

end

endmodule