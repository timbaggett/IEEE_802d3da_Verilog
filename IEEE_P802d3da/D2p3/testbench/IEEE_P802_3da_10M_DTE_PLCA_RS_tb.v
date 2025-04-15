`timescale 1ns/100ps

module tb();

`include "IEEE_P802_3da_param.v"
`include "IEEE_802_3_2022_MAC_initial.v"
`include "IEEE_P802_3cg_PHY_initial.v"
`include "IEEE_P802_3da_PLCA_RS_initial.v"

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

    top.dte_node_0.PHY.delay_type                  = no_delay;
    top.dte_node_1.PHY.delay_type                  = no_delay;
    top.dte_node_2.PHY.delay_type                  = no_delay;
    top.dte_node_3.PHY.delay_type                  = no_delay;
    top.dte_node_4.PHY.delay_type                  = no_delay;
    top.dte_node_5.PHY.delay_type                  = no_delay;
    top.dte_node_6.PHY.delay_type                  = no_delay;
    top.dte_node_7.PHY.delay_type                  = no_delay;
    top.dte_node_8.PHY.delay_type                  = no_delay;
    top.dte_node_9.PHY.delay_type                  = no_delay;
    top.dte_node_10.PHY.delay_type                 = no_delay;
    top.dte_node_11.PHY.delay_type                 = no_delay;
    top.dte_node_12.PHY.delay_type                 = no_delay;
    top.dte_node_13.PHY.delay_type                 = no_delay;
    top.dte_node_14.PHY.delay_type                 = no_delay;
    top.dte_node_15.PHY.delay_type                 = no_delay;

/**********************************************************************/
/*                                                                    */
/* Operate in CSMA/CD mode, PLCA disabled                             */
/*                                                                    */
/**********************************************************************/

    #200;

    // Configure and then endable node 0

    top.dte_node_0.MAC.transmitEnabled             = true;
    top.dte_node_0.MAC.receiveEnabled              = true;

    top.dte_node_0.RS.plca_reset                   = true;

    // Configure and then endable node 1

    top.dte_node_1.MAC.transmitEnabled             = true;
    top.dte_node_1.MAC.receiveEnabled              = true;

    top.dte_node_1.RS.plca_reset                   = true;

    // Configure and then endable node 14

    top.dte_node_14.MAC.transmitEnabled            = true;
    top.dte_node_14.MAC.receiveEnabled             = true;

    top.dte_node_14.RS.plca_reset                  = true;

    // Configure and then endable node 15

    top.dte_node_15.MAC.transmitEnabled            = true;
    top.dte_node_15.MAC.receiveEnabled             = true;

    top.dte_node_15.RS.plca_reset                  = true;

    // Configure frame contents
    // Setting FCS to unknow causes MAC to generate FCS

    destination_address                            = 48'hFF_FF_FF_FF_FF_FF;
    source_address                                 = 48'h55_44_33_22_11_00;
    frame_check_sequence                           = 32'hXX_XX_XX_XX;

    mac_service_data_unit                          = {9000{8'h00}};
    mac_service_data_unit[15:0]                    = 16'd1500;
    mac_service_data_unit[100 * 8]                 = 1'bX;

    #100_000;

    fork 

        for (i0 = 0; i0 < 10; i0 = i0 + 1)
        begin
            top.dte_node_0.MAC.MA_DATA_request(destination_address, source_address, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 0 MA_DATA.request serviced");
        end

        for (i1 = 0; i1 < 10; i1 = i1 + 1)
        begin
            top.dte_node_1.MAC.MA_DATA_request(destination_address, source_address + 1, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 1 MA_DATA.request serviced");
        end

        for (i14 = 0; i14 < 10; i14 = i14 + 1)
        begin
            top.dte_node_14.MAC.MA_DATA_request(destination_address, source_address + 14, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 14 MA_DATA.request serviced");
        end

        for (i15 = 0; i15 < 10; i15 = i15 + 1)
        begin
            top.dte_node_15.MAC.MA_DATA_request(destination_address, source_address + 15, mac_service_data_unit, frame_check_sequence);
            $display($time, " MA_DATA.request serviced");
        end

    join

/**********************************************************************/
/*                                                                    */
/* Operate with PLCA enabled, fixed Node IDs                          */
/*                                                                    */
/**********************************************************************/


    #1_000_000;

    top.dte_node_0.MAC.transmitEnabled             = false;
    top.dte_node_1.MAC.transmitEnabled             = false;
    top.dte_node_14.MAC.transmitEnabled            = false;
    top.dte_node_15.MAC.transmitEnabled            = false;

    #100

    top.dte_node_0.MAC.transmitEnabled             = true;
    top.dte_node_1.MAC.transmitEnabled             = true;
    top.dte_node_14.MAC.transmitEnabled            = true;
    top.dte_node_15.MAC.transmitEnabled            = true;

    #100

    top.dte_node_0.RS.plca_reset                   = false;
    top.dte_node_1.RS.plca_reset                   = false;
    top.dte_node_14.RS.plca_reset                  = false;
    top.dte_node_15.RS.plca_reset                  = false;

    #100

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
        for (i0 = 0; i0 < 10; i0 = i0 + 1)
        begin
            top.dte_node_0.MAC.MA_DATA_request(destination_address, source_address, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 0 MA_DATA.request serviced");
        end

        for (i1 = 0; i1 < 10; i1 = i1 + 1)
        begin
            top.dte_node_1.MAC.MA_DATA_request(destination_address, source_address + 1, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 1 MA_DATA.request serviced");
        end

        for (i14 = 0; i14 < 10; i14 = i14 + 1)
        begin
            top.dte_node_14.MAC.MA_DATA_request(destination_address, source_address + 14, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 14 MA_DATA.request serviced");
        end

        for (i15 = 0; i15 < 10; i15 = i15 + 1)
        begin
            top.dte_node_15.MAC.MA_DATA_request(destination_address, source_address + 15, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 15 MA_DATA.request serviced");
        end

    join

/**********************************************************************/
/*                                                                    */
/* Operate with D-PLCA enabled                                        */
/*                                                                    */
/**********************************************************************/

    release top.dte_node_0.RS.local_nodeID;
    release top.dte_node_1.RS.local_nodeID;
    release top.dte_node_14.RS.local_nodeID;
    release top.dte_node_15.RS.local_nodeID;  

    #100

    top.dte_node_0.RS.plca_reset                   = true;
    top.dte_node_1.RS.plca_reset                   = true;
    top.dte_node_14.RS.plca_reset                  = true;
    top.dte_node_15.RS.plca_reset                  = true;

    top.dte_node_0.MAC.transmitEnabled             = false;
    top.dte_node_1.MAC.transmitEnabled             = false;
    top.dte_node_14.MAC.transmitEnabled            = false;
    top.dte_node_15.MAC.transmitEnabled            = false;

    #100

    top.dte_node_0.RS.plca_reset                   = false;
    top.dte_node_1.RS.plca_reset                   = false;
    top.dte_node_14.RS.plca_reset                  = false;
    top.dte_node_15.RS.plca_reset                  = false;

    top.dte_node_0.MAC.transmitEnabled             = true;
    top.dte_node_1.MAC.transmitEnabled             = true;
    top.dte_node_14.MAC.transmitEnabled            = true;
    top.dte_node_15.MAC.transmitEnabled            = true;

    #100

    top.dte_node_0.RS.plca_en                      = true;
    top.dte_node_1.RS.plca_en                      = true;
    top.dte_node_14.RS.plca_en                     = true;
    top.dte_node_15.RS.plca_en                     = true;

    top.dte_node_0.RS.dplca_en                     = true;
    top.dte_node_1.RS.dplca_en                     = true;
    top.dte_node_14.RS.dplca_en                    = true;
    top.dte_node_15.RS.dplca_en                    = true;

    top.dte_node_0.RS.coordinator_role_allowed     = true;

    #5_000_000;

    fork 
        for (i0 = 0; i0 < 20; i0 = i0 + 1)
        begin
            top.dte_node_0.MAC.MA_DATA_request(destination_address, source_address, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 0 MA_DATA.request serviced");
        end

        for (i1 = 0; i1 < 20; i1 = i1 + 1)
        begin
            top.dte_node_1.MAC.MA_DATA_request(destination_address, source_address + 1, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 1 MA_DATA.request serviced");
        end

        for (i14 = 0; i14 < 20; i14 = i14 + 1)
        begin
            top.dte_node_14.MAC.MA_DATA_request(destination_address, source_address + 14, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 14 MA_DATA.request serviced");
        end

        for (i15 = 0; i15 < 20; i15 = i15 + 1)
        begin
            top.dte_node_15.MAC.MA_DATA_request(destination_address, source_address + 15, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 15 MA_DATA.request serviced");
        end

    join

    $stop;
    $finish;

end

endmodule