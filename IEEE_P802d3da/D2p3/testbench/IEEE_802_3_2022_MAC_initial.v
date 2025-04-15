/**********************************************************************/
/*                          IEEE_802_3_2022                           */
/**********************************************************************/
/*                                                                    */
/*        Module: IEEE_802_3_2022_MAC_init.v                          */
/*        Date:   04/04/2025                                          */
/*                                                                    */
/**********************************************************************/

`define initialise_MA_DATA_indication(i)                                                \
                                                                                        \
reg[15:0] dte_node_``i``_receiveCount;                                                  \
reg[15:0] dte_node_``i``_debugCount;                                                    \
reg[2:0]  dte_node_``i``_rx_status;                                                     \
                                                                                        \
initial                                                                                 \
begin                                                                                   \
                                                                                        \
    dte_node_``i``_receiveCount  = 16'h0000;                                            \
    dte_node_``i``_debugCount    = 16'h0000;                                            \
    forever                                                                             \
                                                                                        \
    begin                                                                               \
                                                                                        \
        top.dte_node_``i``.MAC.MA_DATA_indication(rx_destination_address,               \
                                                  rx_source_address,                    \
                                                  rx_mac_service_data_unit,             \
                                                  rx_frame_check_sequence,              \
                                                  dte_node_``i``_rx_status);            \
                                                                                        \
        dte_node_``i``_receiveCount = dte_node_``i``_receiveCount + 1;                  \
                                                                                        \
    end                                                                                 \
end                                                                                     \
                                                                                        \
always @(dte_node_``i``_receiveCount)                                                   \
begin                                                                                   \
                                                                                        \
   case(dte_node_``i``_rx_status)                                                       \
                                                                                        \
        3'b000: begin if(MAC_debug) $display($time, " Node_``i`` receiveDisabled"); end \
        3'b001: begin $display($time, " Node_``i`` receiveOK"); end                     \
        3'b010: begin $display($time, " Node_``i`` frameTooLong"); $stop; end           \
        3'b011: begin $display($time, " Node_``i`` lengthError"); $stop; end            \
        3'b100: begin $display($time, " Node_``i`` frameCheckError"); $stop; end        \
        3'b101: begin $display($time, " Node_``i`` alignmentError"); $stop; end         \
                                                                                        \
   endcase                                                                              \
                                                                                        \
end                                                                                     \
                                                                                        \

reg          MAC_debug;
initial      MAC_debug = false;

`define initialise_MAC(i)                                                               \
                                                                                        \
initial                                                                                 \
begin                                                                                   \
                                                                                        \
    #10;                                                                                \
                                                                                        \
    top.dte_node_``i``.MAC.debug                       = MAC_debug;                     \
                                                                                        \
    top.dte_node_``i``.MAC.Initialize();                                                \
                                                                                        \
    top.dte_node_``i``.MAC.data_rate                   = top.dte_node_``i``.MAC._10M_;  \
                                                                                        \
    top.dte_node_``i``.MAC.transmitEnabled             = false;                         \
    top.dte_node_``i``.MAC.halfDuplex                  = true;                          \
    top.dte_node_``i``.MAC.ipgStretchMode              = false;                         \
    top.dte_node_``i``.MAC.burstMode                   = false;                         \
                                                                                        \
    top.dte_node_``i``.MAC.receiveEnabled              = false;                         \
    top.dte_node_``i``.MAC.passReceiveFCSMode          = true;                          \
    top.dte_node_``i``.MAC.promiscuous_receive_enabled = true;                          \
    top.dte_node_``i``.MAC.multicast_receive_enabled   = false;                         \
    top.dte_node_``i``.MAC.MAC_station_address         = 48'h00_11_22_33_44_55 + ``i``; \
                                                                                        \
    top.dte_node_``i``.MAC.carrierSense                = false;                         \
    top.dte_node_``i``.MAC.receiveDataValid            = false;                         \
                                                                                        \
end                                                                                     \
                                                                                        \

