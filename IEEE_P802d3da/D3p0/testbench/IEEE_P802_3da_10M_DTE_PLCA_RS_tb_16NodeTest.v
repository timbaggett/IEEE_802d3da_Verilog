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

real d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15;

initial
begin

    $timeformat(-6, 3, " us", 20);
    $dumpfile("IEEE802_3da_16Nodes.fst");
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
//
//    #200;
//
//    // Configure and then endable node 0
//
//    top.dte_node_0.MAC.transmitEnabled             = true;
//    top.dte_node_0.MAC.receiveEnabled              = true;
//
//    top.dte_node_0.RS.plca_reset                   = true;
//
//    // Configure and then endable node 1
//
//    top.dte_node_1.MAC.transmitEnabled             = true;
//    top.dte_node_1.MAC.receiveEnabled              = true;
//
//    top.dte_node_1.RS.plca_reset                   = true;
//
//    // Configure and then endable node 14
//
//    top.dte_node_14.MAC.transmitEnabled            = true;
//    top.dte_node_14.MAC.receiveEnabled             = true;
//
//    top.dte_node_14.RS.plca_reset                  = true;
//
//    // Configure and then endable node 15
//
//    top.dte_node_15.MAC.transmitEnabled            = true;
//    top.dte_node_15.MAC.receiveEnabled             = true;
//
//    top.dte_node_15.RS.plca_reset                  = true;
//
    // Configure frame contents
    // Setting FCS to unknow causes MAC to generate FCS

    destination_address                            = 48'hFF_FF_FF_FF_FF_FF;
    source_address                                 = 48'h55_44_33_22_11_00;
    frame_check_sequence                           = 32'hXX_XX_XX_XX;

    mac_service_data_unit                          = {9000{8'h00}};
    mac_service_data_unit[15:0]                    = 16'd1500;
    mac_service_data_unit[100 * 8]                 = 1'bX;

//    #100_000;
//
//    fork
//
//        for (i0 = 0; i0 < 10; i0 = i0 + 1)
//        begin
//            top.dte_node_0.MAC.MA_DATA_request(destination_address, source_address, mac_service_data_unit, frame_check_sequence);
//            $display($time, " Node 0 MA_DATA.request serviced");
//        end
//
//        for (i1 = 0; i1 < 10; i1 = i1 + 1)
//        begin
//            top.dte_node_1.MAC.MA_DATA_request(destination_address, source_address + 1, mac_service_data_unit, frame_check_sequence);
//            $display($time, " Node 1 MA_DATA.request serviced");
//        end
//
//        for (i14 = 0; i14 < 10; i14 = i14 + 1)
//        begin
//            top.dte_node_14.MAC.MA_DATA_request(destination_address, source_address + 14, mac_service_data_unit, frame_check_sequence);
//            $display($time, " Node 14 MA_DATA.request serviced");
//        end
//
//        for (i15 = 0; i15 < 10; i15 = i15 + 1)
//        begin
//            top.dte_node_15.MAC.MA_DATA_request(destination_address, source_address + 15, mac_service_data_unit, frame_check_sequence);
//            $display($time, " MA_DATA.request serviced");
//        end
//
//    join

/**********************************************************************/
/*                                                                    */
/* Operate with PLCA enabled, fixed Node IDs                          */
/*                                                                    */
/**********************************************************************/

//
//    #1_000_000;
//
//    top.dte_node_0.MAC.transmitEnabled             = false;
//    top.dte_node_1.MAC.transmitEnabled             = false;
//    top.dte_node_14.MAC.transmitEnabled            = false;
//    top.dte_node_15.MAC.transmitEnabled            = false;
//
//    #100
//
//    top.dte_node_0.MAC.transmitEnabled             = true;
//    top.dte_node_1.MAC.transmitEnabled             = true;
//    top.dte_node_14.MAC.transmitEnabled            = true;
//    top.dte_node_15.MAC.transmitEnabled            = true;
//
//    #100
//
//    top.dte_node_0.RS.plca_reset                   = false;
//    top.dte_node_1.RS.plca_reset                   = false;
//    top.dte_node_14.RS.plca_reset                  = false;
//    top.dte_node_15.RS.plca_reset                  = false;
//
//    #100
//
//    force top.dte_node_0.RS.local_nodeID           = 0;
//    top.dte_node_0.RS.plca_en                      = true;
//
//    force top.dte_node_1.RS.local_nodeID           = 1;
//    top.dte_node_1.RS.plca_en                      = true;
//
//    force top.dte_node_14.RS.local_nodeID          = 2;
//    top.dte_node_14.RS.plca_en                     = true;
//
//    force top.dte_node_15.RS.local_nodeID          = 3;
//    top.dte_node_15.RS.plca_en                     = true;
//
//    #2_000;
//
//    fork
//        for (i0 = 0; i0 < 10; i0 = i0 + 1)
//        begin
//            top.dte_node_0.MAC.MA_DATA_request(destination_address, source_address, mac_service_data_unit, frame_check_sequence);
//            $display($time, " Node 0 MA_DATA.request serviced");
//        end
//
//        for (i1 = 0; i1 < 10; i1 = i1 + 1)
//        begin
//            top.dte_node_1.MAC.MA_DATA_request(destination_address, source_address + 1, mac_service_data_unit, frame_check_sequence);
//            $display($time, " Node 1 MA_DATA.request serviced");
//        end
//
//        for (i14 = 0; i14 < 10; i14 = i14 + 1)
//        begin
//            top.dte_node_14.MAC.MA_DATA_request(destination_address, source_address + 14, mac_service_data_unit, frame_check_sequence);
//            $display($time, " Node 14 MA_DATA.request serviced");
//        end
//
//        for (i15 = 0; i15 < 10; i15 = i15 + 1)
//        begin
//            top.dte_node_15.MAC.MA_DATA_request(destination_address, source_address + 15, mac_service_data_unit, frame_check_sequence);
//            $display($time, " Node 15 MA_DATA.request serviced");
//        end
//
//    join

/**********************************************************************/
/*                                                                    */
/* Operate with D-PLCA enabled                                        */
/*                                                                    */
/**********************************************************************/

    release top.dte_node_0.RS.local_nodeID;
    release top.dte_node_1.RS.local_nodeID;
    release top.dte_node_2.RS.local_nodeID;
    release top.dte_node_3.RS.local_nodeID;
    release top.dte_node_4.RS.local_nodeID;
    release top.dte_node_5.RS.local_nodeID;
    release top.dte_node_6.RS.local_nodeID;
    release top.dte_node_7.RS.local_nodeID;
    release top.dte_node_8.RS.local_nodeID;
    release top.dte_node_9.RS.local_nodeID;
    release top.dte_node_10.RS.local_nodeID;
    release top.dte_node_11.RS.local_nodeID;
    release top.dte_node_12.RS.local_nodeID;
    release top.dte_node_13.RS.local_nodeID;
    release top.dte_node_14.RS.local_nodeID;
    release top.dte_node_15.RS.local_nodeID;

    #100

    top.dte_node_0.RS.plca_reset                   = true;
    top.dte_node_1.RS.plca_reset                   = true;
    top.dte_node_2.RS.plca_reset                   = true;
    top.dte_node_3.RS.plca_reset                   = true;
    top.dte_node_4.RS.plca_reset                   = true;
    top.dte_node_5.RS.plca_reset                   = true;
    top.dte_node_6.RS.plca_reset                   = true;
    top.dte_node_7.RS.plca_reset                   = true;
    top.dte_node_8.RS.plca_reset                   = true;
    top.dte_node_9.RS.plca_reset                   = true;
    top.dte_node_10.RS.plca_reset                  = true;
    top.dte_node_11.RS.plca_reset                  = true;
    top.dte_node_12.RS.plca_reset                  = true;
    top.dte_node_13.RS.plca_reset                  = true;
    top.dte_node_14.RS.plca_reset                  = true;
    top.dte_node_15.RS.plca_reset                  = true;

    top.dte_node_0.MAC.transmitEnabled             = false;
    top.dte_node_1.MAC.transmitEnabled             = false;
    top.dte_node_2.MAC.transmitEnabled             = false;
    top.dte_node_3.MAC.transmitEnabled             = false;
    top.dte_node_4.MAC.transmitEnabled             = false;
    top.dte_node_5.MAC.transmitEnabled             = false;
    top.dte_node_6.MAC.transmitEnabled             = false;
    top.dte_node_7.MAC.transmitEnabled             = false;
    top.dte_node_8.MAC.transmitEnabled             = false;
    top.dte_node_9.MAC.transmitEnabled             = false;
    top.dte_node_10.MAC.transmitEnabled            = false;
    top.dte_node_11.MAC.transmitEnabled            = false;
    top.dte_node_12.MAC.transmitEnabled            = false;
    top.dte_node_13.MAC.transmitEnabled            = false;
    top.dte_node_14.MAC.transmitEnabled            = false;
    top.dte_node_15.MAC.transmitEnabled            = false;

    #100

    top.dte_node_0.RS.plca_reset                   = false;
    top.dte_node_1.RS.plca_reset                   = false;
    top.dte_node_2.RS.plca_reset                   = false;
    top.dte_node_3.RS.plca_reset                   = false;
    top.dte_node_4.RS.plca_reset                   = false;
    top.dte_node_5.RS.plca_reset                   = false;
    top.dte_node_6.RS.plca_reset                   = false;
    top.dte_node_7.RS.plca_reset                   = false;
    top.dte_node_8.RS.plca_reset                   = false;
    top.dte_node_9.RS.plca_reset                   = false;
    top.dte_node_10.RS.plca_reset                  = false;
    top.dte_node_11.RS.plca_reset                  = false;
    top.dte_node_12.RS.plca_reset                  = false;
    top.dte_node_13.RS.plca_reset                  = false;
    top.dte_node_14.RS.plca_reset                  = false;
    top.dte_node_15.RS.plca_reset                  = false;

    top.dte_node_0.MAC.transmitEnabled             = true;
    top.dte_node_1.MAC.transmitEnabled             = true;
    top.dte_node_2.MAC.transmitEnabled             = true;
    top.dte_node_3.MAC.transmitEnabled             = true;
    top.dte_node_4.MAC.transmitEnabled             = true;
    top.dte_node_5.MAC.transmitEnabled             = true;
    top.dte_node_6.MAC.transmitEnabled             = true;
    top.dte_node_7.MAC.transmitEnabled             = true;
    top.dte_node_8.MAC.transmitEnabled             = true;
    top.dte_node_9.MAC.transmitEnabled             = true;
    top.dte_node_10.MAC.transmitEnabled            = true;
    top.dte_node_11.MAC.transmitEnabled            = true;
    top.dte_node_12.MAC.transmitEnabled            = true;
    top.dte_node_13.MAC.transmitEnabled            = true;
    top.dte_node_14.MAC.transmitEnabled            = true;
    top.dte_node_15.MAC.transmitEnabled            = true;

    #100

    top.dte_node_0.RS.plca_en                      = true;
    top.dte_node_1.RS.plca_en                      = true;
    top.dte_node_2.RS.plca_en                      = true;
    top.dte_node_3.RS.plca_en                      = true;
    top.dte_node_4.RS.plca_en                      = true;
    top.dte_node_5.RS.plca_en                      = true;
    top.dte_node_6.RS.plca_en                      = true;
    top.dte_node_7.RS.plca_en                      = true;
    top.dte_node_8.RS.plca_en                      = true;
    top.dte_node_9.RS.plca_en                      = true;
    top.dte_node_10.RS.plca_en                     = true;
    top.dte_node_11.RS.plca_en                     = true;
    top.dte_node_12.RS.plca_en                     = true;
    top.dte_node_13.RS.plca_en                     = true;
    top.dte_node_14.RS.plca_en                     = true;
    top.dte_node_15.RS.plca_en                     = true;

    // top.dte_node_0.RS.dplca_min_node_count         = 4;

    top.dte_node_0.RS.aging_cycles                 = 32'd32;
    top.dte_node_1.RS.aging_cycles                 = 32'd32;
    top.dte_node_2.RS.aging_cycles                 = 32'd32;
    top.dte_node_3.RS.aging_cycles                 = 32'd32;
    top.dte_node_4.RS.aging_cycles                 = 32'd32;
    top.dte_node_5.RS.aging_cycles                 = 32'd32;
    top.dte_node_6.RS.aging_cycles                 = 32'd32;
    top.dte_node_7.RS.aging_cycles                 = 32'd32;
    top.dte_node_8.RS.aging_cycles                 = 32'd32;
    top.dte_node_9.RS.aging_cycles                 = 32'd32;
    top.dte_node_10.RS.aging_cycles                = 32'd32;
    top.dte_node_11.RS.aging_cycles                = 32'd32;
    top.dte_node_12.RS.aging_cycles                = 32'd32;
    top.dte_node_13.RS.aging_cycles                = 32'd32;
    top.dte_node_14.RS.aging_cycles                = 32'd32;
    top.dte_node_15.RS.aging_cycles                = 32'd32;

    top.dte_node_0.RS.dplca_en                     = true;
    top.dte_node_1.RS.dplca_en                     = true;
    top.dte_node_2.RS.dplca_en                     = true;
    top.dte_node_3.RS.dplca_en                     = true;
    top.dte_node_4.RS.dplca_en                     = true;
    top.dte_node_5.RS.dplca_en                     = true;
    top.dte_node_6.RS.dplca_en                     = true;
    top.dte_node_7.RS.dplca_en                     = true;
    top.dte_node_8.RS.dplca_en                     = true;
    top.dte_node_9.RS.dplca_en                     = true;
    top.dte_node_10.RS.dplca_en                    = true;
    top.dte_node_11.RS.dplca_en                    = true;
    top.dte_node_12.RS.dplca_en                    = true;
    top.dte_node_13.RS.dplca_en                    = true;
    top.dte_node_14.RS.dplca_en                    = true;
    top.dte_node_15.RS.dplca_en                    = true;

    top.dte_node_0.RS.coordinator_role_allowed     = true;

    // #5_000_000;
    #100_000;

    fork
        for (i0 = 0; i0 < 50; i0 = i0 + 1)
        begin
            d0 = $urandom_range(500_000, 0);
            // $display(d0, " Node0 MAC Delay");
            #d0 top.dte_node_0.MAC.MA_DATA_request(destination_address, source_address, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 0 MA_DATA.request serviced");
        end

        for (i1 = 0; i1 < 50; i1 = i1 + 1)
        begin
            d1 = $urandom_range(500_000, 0);
            // $display(d1, " Node1 MAC Delay");
            #d1 top.dte_node_1.MAC.MA_DATA_request(destination_address, source_address + 1, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 1 MA_DATA.request serviced");
        end

        for (i2 = 0; i2 < 50; i2 = i2 + 1)
        begin
            d2 = $urandom_range(500_000, 0);
            // $display(d2, " Node2 MAC Delay");
            #d2 top.dte_node_2.MAC.MA_DATA_request(destination_address, source_address + 2, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 2 MA_DATA.request serviced");
        end

        for (i3 = 0; i3 < 50; i3 = i3 + 1)
        begin
            d3 = $urandom_range(500_000, 0);
            // $display(d3, " Node3 MAC Delay");
            #d3 top.dte_node_3.MAC.MA_DATA_request(destination_address, source_address + 3, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 3 MA_DATA.request serviced");
        end

        for (i4 = 0; i4 < 50; i4 = i4 + 1)
        begin
            d4 = $urandom_range(500_000, 0);
            // $display(d4, " Node4 MAC Delay");
            #d4 top.dte_node_4.MAC.MA_DATA_request(destination_address, source_address + 4, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 4 MA_DATA.request serviced");
        end

        for (i5 = 0; i5 < 50; i5 = i5 + 1)
        begin
            d5 = $urandom_range(500_000, 0);
           //  $display(d5, " Node5 MAC Delay");
            #d5 top.dte_node_5.MAC.MA_DATA_request(destination_address, source_address + 5, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 5 MA_DATA.request serviced");
        end

        for (i6 = 0; i6 < 50; i6 = i6 + 1)
        begin
            d6 = $urandom_range(50_000, 0);
            // $display(d6, " Node6 MAC Delay");
            #d6 top.dte_node_6.MAC.MA_DATA_request(destination_address, source_address + 6, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 6 MA_DATA.request serviced");
        end

        for (i7 = 0; i7 < 50; i7 = i7 + 1)
        begin
            d7 = $urandom_range(50_000, 0);
            // $display(d7, " Node7 MAC Delay");
            #d7 top.dte_node_7.MAC.MA_DATA_request(destination_address, source_address + 6, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 7 MA_DATA.request serviced");
        end

        for (i8 = 0; i8 < 50; i8 = i8 + 1)
        begin
            d8 = $urandom_range(50_000, 0);
            // $display(d8, " Node8 MAC Delay");
            #d8 top.dte_node_8.MAC.MA_DATA_request(destination_address, source_address + 6, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 8 MA_DATA.request serviced");
        end

        for (i9 = 0; i9 < 50; i9 = i9 + 1)
        begin
            d9 = $urandom_range(50_000, 0);
            // $display(d9, " Node9 MAC Delay");
            #d9 top.dte_node_9.MAC.MA_DATA_request(destination_address, source_address + 9, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 9 MA_DATA.request serviced");
        end

        for (i10 = 0; i10 < 50; i10 = i10 + 1)
        begin
            d10 = $urandom_range(50_000, 0);
            // $display(d10, " Node10 MAC Delay");
            #d10 top.dte_node_10.MAC.MA_DATA_request(destination_address, source_address + 10, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 10 MA_DATA.request serviced");
        end

        for (i11 = 0; i11 < 50; i11 = i11 + 1)
        begin
            d11 = $urandom_range(50_000, 0);
            // $display(d11, " Node11 MAC Delay");
            #d11 top.dte_node_11.MAC.MA_DATA_request(destination_address, source_address + 11, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 11 MA_DATA.request serviced");
        end

        for (i12 = 0; i12 < 50; i12 = i12 + 1)
        begin
            d12 = $urandom_range(50_000, 0);
            // $display(d12, " Node12 MAC Delay");
            #d12 top.dte_node_12.MAC.MA_DATA_request(destination_address, source_address + 12, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 12 MA_DATA.request serviced");
        end

        for (i13 = 0; i13 < 50; i13 = i13 + 1)
        begin
            d13 = $urandom_range(50_000, 0);
            // $display(d13, " Node13 MAC Delay");
            #d13 top.dte_node_13.MAC.MA_DATA_request(destination_address, source_address + 13, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 13 MA_DATA.request serviced");
        end

        for (i14 = 0; i14 < 50; i14 = i14 + 1)
        begin
            d14 = $urandom_range(50_000, 0);
            // $display(d14, " Node14 MAC Delay");
            #d14 top.dte_node_14.MAC.MA_DATA_request(destination_address, source_address + 14, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 14 MA_DATA.request serviced");
        end

        for (i15 = 0; i15 < 50; i15 = i15 + 1)
        begin
            d15 = $urandom_range(50_000, 0);
            // $display(d15, " Node15 MAC Delay");
            #d15 top.dte_node_15.MAC.MA_DATA_request(destination_address, source_address + 15, mac_service_data_unit, frame_check_sequence);
            $display($time, " Node 15 MA_DATA.request serviced");
        end

    join

    $stop;
    $finish;

end

endmodule
