/**********************************************************************/
/*                          IEEE_802_3_2022                           */
/**********************************************************************/
/*                                                                    */
/*        Module: IEEE_802_3_2022_MAC.v                               */
/*        Date:   04/04/2025                                          */
/*                                                                    */
/**********************************************************************/

`timescale 1ns/100ps

module MAC();

reg debug;

`include "generic\code\IEEE_802_3_param.v"
`include "Clause 4\code\IEEE_802_3_2022_MAC_param.v"

/*                                                                    */
/* 2.3.1.2 Semantics of the service primitive                         */
/*                                                                    */
/* The semantics of the primitive are as follows:                     */
/*                                                                    */
/* MA_DATA.request (                                                  */
/* destination_address,                                               */
/* source_address,                                                    */
/* mac_service_data_unit,                                             */
/* frame_check_sequence                                               */
/* )                                                                  */
/*                                                                    */

task MA_DATA_request;

event MA_DATA_request;

input[47:0]    destination_address;
input[47:0]    source_address;
input[71999:0] mac_service_data_unit;
input[31:0]    frame_check_sequence;

reg[15:0]      lengthOrType;
reg[71999:0]   data;
reg            fcsPresent;
reg            TransmitFrame;

begin

    -> MA_DATA_request;

    lengthOrType = mac_service_data_unit[15:0];

    data = mac_service_data_unit[71999:16];

    for (clientDataSize = 0; ((clientDataSize < (9000 * 8)) && (data[clientDataSize] !== UNKNOWN)); clientDataSize = clientDataSize + 1);

    padSize = max(0, (minFrameSize - ((2 * addressSize) + lengthOrTypeSize + clientDataSize + crcSize)));

    dataSize = clientDataSize + padSize; 

    frameSize = (2 * addressSize) + lengthOrTypeSize + dataSize + crcSize;

    fcsPresent = (frame_check_sequence === 32'hXXXX_XXXX) ? false : true;

    TransmitFrame(destination_address,
                  source_address,
                  lengthOrType,
                  data,
                  frame_check_sequence,
                  fcsPresent,
                  TransmitFrame);

    while(deferring)
    begin
        nothing;
    end 

end
endtask

/*                                                                    */
/* 2.3.2.2 Semantics of the service primitive                         */
/*                                                                    */
/* The semantics of the primitive are as follows:                     */
/* MA_DATA.indication (                                               */
/* destination_address,                                               */
/* source_address,                                                    */
/* mac_service_data_unit,                                             */
/* frame_check_sequence,                                              */
/* reception_status                                                   */
/* )                                                                  */
/*                                                                    */

task MA_DATA_indication;

event MA_DATA_indication;

output[47:0]    destination_address;
output[47:0]    source_address;
output[71999:0] mac_service_data_unit;
output[31:0]    frame_check_sequence;
output[2:0]     reception_status;

reg[47:0]       destinationParam;  // AddressValue;
reg[47:0]       sourceParam;       // AddressValue;
reg[15:0]       lengthOrTypeParam; // LengthOrTypeValue;
reg[71999:0]    dataParam;         // DataValue;
reg[31:0]       fcsParamValue;     // CRCValue;
reg             fcsParamPresent;   // Bit): 
reg[2:0]        ReceiveFrame;      // ReceiveStatus;

reg[16:0]       length;
reg[5:0]        fcsbit;

begin
    if (debug) $display($time, " %m start MA_DATA_indication");
   
    ReceiveFrame(destinationParam,
                 sourceParam,
                 lengthOrTypeParam,
                 dataParam,
                 fcsParamValue,
                 fcsParamPresent,
                 ReceiveFrame);

    destination_address = destinationParam;
    source_address = sourceParam;

    mac_service_data_unit = dataParam;

    frame_check_sequence = fcsParamValue;

    if(!fcsParamPresent)
    begin
        for (length = 0; ((length < (9000 * 8)) && (dataParam[length] !== UNKNOWN)); length = length + 1);

        length = length - 32;

        for (fcsbit = 0; fcsbit <= 32; fcsbit = fcsbit + 1)
        begin
            frame_check_sequence[fcsbit] = dataParam[length + fcsbit];
        end
    end

    reception_status = ReceiveFrame;

    -> MA_DATA_indication;

    if (debug) $display($time, " %m end MA_DATA_indication");
end
endtask

/*                                                                    */
/* 4.2.7 Global declarations                                          */
/*                                                                    */
/* This subclause  provides detailed  formal  specifications for  the */
/* CSMA/CD MAC sublayer. It  is a  specification of  generic features */
/* and parameters to  be  used  in  systems implementing  this  media */
/* access  method. Subclause  4.4 provides  values for these  sets of */
/* parameters  for recommended  implementations of this  media access */
/* mechanism.                                                         */
/*                                                                    */

/*                                                                    */
/* 4.2.7.1 Common constants, types, and variables                     */
/* The following declarations of constants, types  and  variables are */
/* used by the MAC  frame transmission and reception sections of each */
/* CSMA/CD sublayer:                                                  */
/*                                                                    */

// const
parameter addressSize          = 48;   // {In bits, in compliance with 3.2.3}
parameter lengthOrTypeSize     = 16;   // {In bits}
reg[16:0] clientDataSize;              // {In bits, size of MAC Client Data; see 4.2.2.2, a) 3)}
reg[8:0]  padSize;                     // {{In bits, = max (0, minFrameSize - (2 x addressSize +
                                       //   lengthOrTypeSize + clientDataSize + crcSize))}
reg[16:0] dataSize;                    // {In bits, = clientDataSize + padSize}
parameter crcSize              = 32;   // {In bits, 32-bit CRC}
reg[16:0] frameSize;                   // {In bits, = 2 x addressSize + lengthOrTypeSize +
                                       //  dataSize + crcSize; see 4.2.2.2, a)}
parameter minFrameSize         = 512;  // {In bits, see 4.4}
parameter maxBasicFrameSize    = 1518; // {In octets, see 3.2.7, 4.4}
parameter maxEnvelopeFrameSize = 2000; // {In octets, see 3.2.7, 4.4}
parameter qTagPrefixSize       = 4;    // {In octets, length of Q-tag prefix, see 3.2.7, 4.4}
reg[16:0] maxFrameSizeLimit;           // = maxBasicFrameSize or (maxBasicFrameSize + qTagPrefixSize) or
                                       //   maxEnvelopeFrameSize ; {in octets}
reg       extend;                      // {Boolean, true if (slotTime – minFrameSize) > 0, false otherwise}
parameter extensionBit         = 2'h2; // {A non-data value which is used for carrier extension and interpacket
                                       //  during bursts}
parameter extensionErrorBit    = 2'h3; // {A non-data value which is used to jam during carrier extension}
parameter minTypeValue         = 1536; // {Minimum value of the Length/Type field for Type interpretation}
parameter maxBasicDataSize     = 1500; // {In octets, the maximum length of the MAC Client Data field of the basic frame.}
reg[13:0] slotTime;                    // {In bit times, unit of time for collision handling, implementation-dependent, see 4.4}
parameter preambleSize         = 56;   // {In bits, see 4.2.5}
parameter sfdSize              = 8;    // {In bits, Start Frame Delimiter}
parameter headerSize           = 64;   // {In bits, sum of preambleSize and sfdSize}

// type
reg       Bit;                         // (0, 1);
reg[1:0]  PhysicalBit;                 // (0, 1, extensionBit, extensionErrorBit);
                                       // {Bits transmitted to the Physical Layer can be either 0, 1, extensionBit or
                                       // extensionErrorBit. Bits received from the Physical Layer can be either 0, 1
                                       // or extensionBit}
reg[47:0] AddressValue;                // array [1..addressSize] of Bit;

// TransmitStatus = (transmitDisabled, transmitOK, excessiveCollisionError,
// lateCollisionErrorStatus);

parameter transmitDisabled         = 2'b00;
parameter transmitOK               = 2'b01;
parameter excessiveCollisionError  = 2'b10;
parameter lateCollisionErrorStatus = 2'b11;

// ReceiveStatus = (receiveDisabled, receiveOK, frameTooLong, frameCheckError,
// lengthError, alignmentError);

parameter receiveDisabled          = 3'b000;
parameter receiveOK                = 3'b001;
parameter frameTooLong             = 3'b010;
parameter lengthError              = 3'b011;
parameter frameCheckError          = 3'b100;
parameter alignmentError           = 3'b101;

reg       halfDuplex;                  // Boolean; {Indicates the desired mode. halfDuplex is a static variable; its value does
                                       // not change between invocations of the Initialize procedure}

/*                                                                    */
/* 4.2.7.2 Transmit state variables                                   */
/*                                                                    */
/* The following items  are  specific  to  packet transmission.  (See */
/* also 4.4.)                                                         */
/*                                                                    */

// const
parameter interPacketGap = 96;         // {In bit times, minimum gap between packets, see 4.4}
parameter interPacketGapPart1 = 64;    // {In bit times, duration of the first portion of
                                       //  interPacketGap. In the
                                       //  range of 0 to 2/3 of interPacketGap}
parameter interPacketGapPart2 =        // {In bit times, duration of the remainder of
          interPacketGap -             //  interPacketGap. Equal to
          interPacketGapPart1;         //  interPacketGap –
                                       //  interPacketGapPart1}
parameter ipgStretchRatio = 104;       // {In bits, determines the number of bits in a packet that
                                       //  require one octet of interPacketGap extension,
                                       //  when ipgStretchMode is enabled;
                                       //  see 4.4 and 4.2.8}
parameter attemptLimit = 16;           // {Max number of times to attempt transmission}
parameter backOffLimit = 10;           // {Limit on number of times to back off}
parameter burstLimit= 65_536;          // {In bits, limit for initiation of packet transmission in Burst Mode,
                                       // see 4.4 and 4.2.8}
parameter jamSize = 32;                // {In bits, the value depends upon port type and duplex/half-duplex mode.
                                       // See 4.1.2.2 and 4.4.}
// var
reg[71999:0] outgoingFrame;            // Frame; {The frame to be transmitted}
reg[64:0]    outgoingHeader;           // Header;
reg[16:0]    currentTransmitBit;       // 1..frameSize; {Positions of current and last outgoing bits in
reg[16:0]    lastTransmitBit;          //                outgoingFrame}
reg[6:0]     lastHeaderBit;            // 1..headerSize;
reg          deferring;                // Boolean; {Implies any pending transmission must wait for the medium to clear}
reg          frameWaiting;             // Boolean; {Indicates that outgoingFrame is deferring}
reg[4:0]     attempts;                 //           0..attemptLimit; {Number of transmission attempts on outgoingFrame}
reg          newCollision;             // Boolean; {Indicates that a collision has occurred but has not yet been jammed}
reg          transmitSucceeding;       // Boolean; {Running indicator of whether transmission is succeeding}
reg          burstMode;                // Boolean; {Indicates the desired mode of operation, and enables the transmission of
                                       //           multiple frames in a single carrier event. burstMode is a static variable; its
                                       //           value shall only be changed by the invocation of the Initialize procedure}
reg          bursting;                 // Boolean; {In burstMode, the given station has acquired the medium and the burst timer has
                                       //           not yet expired}
reg          burstStart;               // Boolean; {In burstMode, indicates that the first frame transmission is in progress}
reg          extendError;              // Boolean; {Indicates a collision occurred while sending extension bits}
reg          ipgStretchMode;           // Boolean; {Indicates the desired mode of operation, and enables
                                       //           the lowering of the average data rate
                                       //           of the MAC sublayer (with packet granularity), using
                                       //           extension of the minimum interPacketGap.
                                       //           ipgStretchMode is a static
                                       //           variable; its value shall only be changed by the invocation of the Initialize
                                       //           procedure}
reg[6:0]     ipgStretchCount;          // 0..ipgStretchRatio; {In bits, a running
                                       //           counter that counts the number of bits during a
                                       //           packet’s transmission that are to be considered for the
                                       //           minimum interPacketGap extension,
                                       //           while operating in ipgStretchMode}
reg[13:0]    ipgStretchSize;           // 0..(((maxFrameSizeLimit) x + headerSize + interPacketGap
                                       // + ipgStretchRatio – 1) div ipgStretchRatio);
                                       //          {In octets, a running counter that counts the integer number of octets that are to be
                                       //           added to the minimum interPacketGap, while operating in
                                       //           ipgStretchMode}

/*                                                                    */
/* 4.2.7.3 Receive state variables                                    */
/*                                                                    */
/* The  following items  are  specific to  frame reception. (See also */
/* 4.4.)                                                              */
/*                                                                    */

//var
reg[71999:0] incomingFrame;            // Frame; {The frame being received}
reg          receiving;                // Boolean; {Indicates that a frame reception is in progress}
reg[2:0]     excessBits;               // 0..7; {Count of excess trailing bits beyond octet boundary}
reg          receiveSucceeding;        // Boolean; {Running indicator of whether reception is succeeding}
reg          validLength;              // Boolean; {Indicator of whether received frame has a length error}
reg          exceedsMaxLength;         // Boolean; {Indicator of whether received frame has a length longer than the
                                       //           maximum permitted length}
reg          extending;                // Boolean; {Indicates whether the current frame is subject to carrier extension}
reg          extensionOK;              // Boolean; {Indicates whether any bit errors were found in the extension part of a packet,
                                       //           which is not checked by the CRC}
reg          passReceiveFCSMode;       // Boolean; {Indicates the desired mode of operation, and enables passing of
                                       //           the frame check sequence field of all received frames from the
                                       //           MAC sublayer to the MAC client. passReceiveFCSMode is a
                                       //           static variable}

/*                                                                    */
/* 4.2.7.4 State variable initialization                              */
/*                                                                    */
/* The procedure Initialize must be run when  the MAC sublayer begins */
/* operation,  before   any  of  the   processes    begin  execution. */
/* Initialize sets  certain crucial shared  state variables  to their */
/* initial values.  (All other  global  variables  are  appropriately */
/* reinitialized  before  each use.) Initialize then  waits  for  the */
/* medium to be idle, and starts operation of the various processes.  */
/*                                                                    */
/* If  Layer Management  is  implemented,  the  Initialize  procedure */
/* shall only be  called as  the result of  the initializeMAC  action */
/* (30.3.1.2.1).                                                      */
/*                                                                    */

task Initialize;
begin

    if (debug) $display($time, " %m start Initialize");

    frameWaiting = false;
    deferring = false;
    newCollision = false;
    transmitting = false;      // {An interface to Physical Layer; see below}
    receiving = false;

//  halfDuplex = ...;          // {True for half duplex operation, false for full duplex operation. For
                               //  operation at speeds above 1000 Mb/s, halfDuplex shall always be false}
    bursting = false;
//  burstMode := ...;          // {True for half duplex operation at an operating speed of 1000 Mb/s, 
                               //  when multiple frames’ transmission in a single carrier event is
                               //  desired and supported, false otherwise}
    extending = extend && halfDuplex;
//  ipgStretchMode := ...;     // {True for operating speeds above 1000 Mb/s when lowering the
                               //  average data rate of the MAC sublayer (with frame granularity)
                               //  is desired and supported, false otherwise}
    ipgStretchCount = 0;
    ipgStretchSize = 0;
//  passReceiveFCSMode := ...; // {True when enabling the passing of the frame check sequence of all
                               //  received frames from the MAC sublayer to the MAC client is desired and
                               //  supported, false otherwise}

    if (halfDuplex)
    begin
        while (carrierSense || receiveDataValid)
        begin
           nothing; // nothing;
        end
    end
    else
    begin
        while (receiveDataValid)
        begin
           nothing; // nothing
        end
    end

    // extend; {Boolean, true if (slotTime – minFrameSize) > 0, false otherwise}

    if ((slotTime - minFrameSize) > 0)
    begin
        extend = true;
    end
    else
    begin
        extend = false;
    end

    // {Start execution of all processes}

    disable BurstTimer;
    disable Deference;
    disable BitTransmitter;

    LayerMgmtInitialize;

    if (debug) $display($time, " %m end Initialize");

end // {Initialize}

endtask


/*                                                                    */
/* 4.2.8 Frame transmission                                           */
/*                                                                    */
/* The  algorithms  in  this  subclause  define  MAC  sublayer  frame */
/* transmission.  The  function  TransmitFrame implements  the  frame */
/* transmission operation provided to the MAC client.                 */
/*                                                                    */
/* The  TransmitFrame operation is synchronous.  Its duration  is the */
/* entire  attempt  to  transmit    the  frame;  when  the  operation */
/* completes,  transmission  has  either   succeeded  or  failed,  as */
/* indicated by the TransmitStatus status code.                       */
/*                                                                    */
/* The   transmitDisabled   status  code  (if   layer  management  is */
/* implemented)  indicates  that  the  transmitter  is  not  enabled. */
/* Successful  transmission   is  indicated  by  the     status  code */
/* transmitOK.  The  code excessiveCollisionError  indicates that the */
/* transmission  attempt was  aborted due  to  excessive  collisions, */
/* because of heavy  traffic or a network failure. MACs operating  in */
/* the half  duplex mode  at  the speed  of 1000 Mb/s are required to */
/* report lateCollisionErrorStatus  in  response to a late collision; */
/* MACs operating in the  half duplex mode at speeds of 100  Mb/s and */
/* below  are not required to do so.  TransmitStatus is  not  used by */
/* the  service  interface  defined in 2.3.1.  TransmitStatus  may be */
/* used in an implementation dependent manner.                        */
/*                                                                    */

task TransmitFrame;               // (
input[47:0]    destinationParam;  // AddressValue;
input[47:0]    sourceParam;       // AddressValue;
input[15:0]    lengthOrTypeParam; // LengthOrTypeValue;
input[71999:0] dataParam;         // DataValue;
input[31:0]    fcsParamValue;     // CRCValue;
input          fcsParamPresent;   // Bit): 

output[1:0]    TransmitFrame;  

// procedure TransmitDataEncap; {Nested procedure; see body below}
begin

    if (debug) $display($time, " %m start TransmitFrame");

    destinationParam = destinationParam;

    if (transmitEnabled)
    begin
        TransmitDataEncap(destinationParam,
                          sourceParam,
                          lengthOrTypeParam,
                          dataParam,
                          fcsParamValue,
                          fcsParamPresent);
        TransmitLinkMgmt(TransmitFrame);
    end
    else
    begin
        TransmitFrame = transmitDisabled;
    end //{TransmitFrame}

    if (debug) $display($time, " %m end TransmitFrame");

end

endtask

/*                                                                    */
/* If  transmission is  enabled,  TransmitFrame  calls  the  internal */
/* procedure  TransmitDataEncap  to   construct  the    frame.  Next, */
/* TransmitLinkMgmt  is called  to  perform the actual  transmission. */
/* The  TransmitStatus returned indicates  the success or failure  of */
/* the transmission attempt.                                          */
/*                                                                    */

task TransmitDataEncap;

input[47:0]    destinationParam;  // AddressValue;
input[47:0]    sourceParam;       // AddressValue;
input[15:0]    lengthOrTypeParam; // LengthOrTypeValue;
input[71999:0] dataParam;         // DataValue;
input[31:0]    fcsParamValue;     // CRCValue;
input          fcsParamPresent;   // Bit): 

begin

    if (debug) $display($time, " %m start TransmitDataEncap");

    // with outgoingFrame do
    begin // {Assemble frame}
        // view := fields;
        outgoingFrame[48:1]     = destinationParam;  // destinationField := destinationParam;
        outgoingFrame[96:49]    = sourceParam;       // sourceField := sourceParam;
        outgoingFrame[113:97]   = lengthOrTypeParam; // lengthOrTypeField := lengthOrTypeParam;
        if (fcsParamPresent)
        begin
            outgoingFrame[71999:113] = dataParam;                    // dataField := dataParam; {No need to generate pad if the FCS is passed from MAC client}
            outgoingFrame = InsertFCS(outgoingFrame, fcsParamValue); // fcsField := fcsParamValue {Use the FCS passed from MAC client}
        end
        else
        begin
           outgoingFrame[71999:113] = ComputePad(dataParam);                       // dataField := ComputePad(dataParam);
           outgoingFrame = InsertFCS(outgoingFrame, CRC32(outgoingFrame, FALSE));  // fcsField := CRC32(outgoingFrame)
        end
        //view := bits
    end // {Assemble frame}
    // with outgoingHeader do
    begin
        // headerView := headerFields;
        outgoingHeader[56:1]  = {7{8'h55}}; // {* ‘1010...10,’ LSB to MSB*}
        outgoingHeader[64:57] = 8'hD5;      // {* ‘10101011,’ LSB to MSB*}
        // headerView := headerBits
    end

    if (debug) $display($time, " %m end TransmitDataEncap");

end // {TransmitDataEncap}
endtask

/*                                                                    */
/* ComputePad  appends an  array of arbitrary bits  to the MAC client */
/* data to pad the frame to the minimum frame size:                   */
/*                                                                    */

function[71999:0] ComputePad; // (var dataParam: DataValue): DataValue;
input[71999:0] data_in;

reg[16:0]      length;
reg[9:0]       padBits;

begin

    if (debug) $display($time, " %m start ComputePad");

    ComputePad = data_in;

    for (length = 0; ((length < (9000 * 8)) && (data_in[length] !== UNKNOWN)); length = length + 1);

    for (padBits = 0; padBits < padSize; padBits = padBits + 1)
    begin
        ComputePad[length + padBits] = 1'b1;
    end
    ComputePad[length + padBits] = 1'bX;

    if (debug) $display($time, " %m end ComputePad");

end // {ComputePad}
endfunction


/*                                                                    */
/* TransmitLinkMgmt                                                   */
/*                                                                    */
/* TransmitLinkMgmt attempts to  transmit the  frame.  In half duplex */
/* mode,  it first defers  to  any passing traffic.  In  half  duplex */
/* mode, if  a collision occurs,  transmission is terminated properly */
/* and  retransmission  is  scheduled  following  a suitable  backoff */
/* interval:                                                          */
/*                                                                    */

task TransmitLinkMgmt;

output[1:0] TransmitLinkMgmt;

begin

    if (debug) $display($time, " %m start TransmitLinkMgmt");

    attempts           = 0;
    transmitSucceeding = false;
    lateCollisionCount = 0;
    deferred           = false; // {Initialize}
    excessDefer        = false;
    while ((attempts < attemptLimit) && !transmitSucceeding && (!extend || lateCollisionCount == 0)) // do
    // {No retransmission after late collision if operating at 1000 Mb/s}
    begin // {Loop}
        if (bursting) // then {This is a burst continuation}
        begin
             frameWaiting = true; // {Start transmission without checking deference}
        end
        else // {Non bursting case, or first frame of a burst}
        begin
            if (attempts > 0)
            begin // then
                BackOff;
            end
            frameWaiting = true;
            while (deferring) // do {Defer to passing frame, if any}
            begin
                if (halfDuplex) // then 
                begin
                    deferred   = true;
                end
                nothing;   // Need to add delay to advance time
            end
            burstStart = true;
            if (burstMode) // then
            begin
                bursting = true;
            end
        end
        lateCollisionError = false;
        StartTransmit();
        frameWaiting = false;
        if (halfDuplex) // then
        begin
            while (transmitting) // do 
            begin
                WatchForCollision;
                nothing;   // Need to add delay to advance time
            end
            if (lateCollisionError) // then
            begin
                lateCollisionCount = lateCollisionCount + 1;
            end
            attempts = attempts + 1;
        end // {Half duplex mode}
        else
        begin
            while (transmitting) // do
            begin
                nothing; // nothing; {Full duplex mode}
            end
        end
    end //; {Loop}
    LayerMgmtTransmitCounters(); // {Update transmit and transmit error counters in 5.2.4.2}
    if (transmitSucceeding) // then
    begin
        if (burstMode) // then 
        begin
            burstStart = false; // {Can’t be the first frame anymore}
        end
        TransmitLinkMgmt = transmitOK;
    end
    else if (extend && (lateCollisionCount > 0)) // then 
    begin
        TransmitLinkMgmt = lateCollisionErrorStatus;
    end
    else
    begin
        TransmitLinkMgmt = excessiveCollisionError;
    end

    if (debug) $display($time, " %m end TransmitLinkMgmt");

end // {TransmitLinkMgmt}

endtask

/*                                                                    */
/* StartTransmit                                                      */
/*                                                                    */
/* Each   time   a  frame   transmission    attempt    is  initiated, */
/* StartTransmit is called to alert  the BitTransmitter  process that */
/* bit transmission should begin:                                     */
/*                                                                    */

task StartTransmit;
begin

    if (debug) $display($time, " %m start StartTransmit");

    currentTransmitBit = 1;
    lastTransmitBit    = frameSize;
    lastHeaderBit      = headerSize;
    transmitSucceeding = true;
    transmitting       = true;

    if (debug) $display($time, " %m end StartTransmit");

end // {StartTransmit}
endtask

/*                                                                    */
/* WatchForCollision                                                  */
/*                                                                    */
/* In  half  duplex  mode,  TransmitLinkMgmt monitors the medium  for */
/* contention  by  repeatedly  calling WatchForCollision, once  frame */
/* transmission has been initiated:                                   */
/*                                                                    */

task WatchForCollision;
begin

    if (debug) $display($time, " %m start WatchForCollision");

    if (transmitSucceeding && collisionDetect) // then
    begin
        if (currentTransmitBit > (slotTime - headerSize))
        begin
           lateCollisionError = true;
        end
        newCollision       = true;
        transmitSucceeding = false;
        if (burstMode) // then
        begin
            bursting = false;
            if (!burstStart) // then
            begin
                lateCollisionError = true; // {Every collision is late, unless it hits the first frame in a burst}
            end
        end
    end

    if (debug) $display($time, " %m end WatchForCollision");

end // {WatchForCollision}
endtask

/*                                                                    */
/* WatchForCollision,  upon   detecting   a       collision,  updates */
/* newCollision  to  ensure  proper  jamming  by  the  BitTransmitter */
/* process.  The current transmit bit  number  is  checked  to see if */
/* this is a late  collision.  If the  collision occurs  later than a */
/* collision  window  of   slotTime  bits  into  the  packet,  it  is */
/* considered  as evidence  of  a late collision. The  point at which */
/* the  collision is  received  is determined  by  the network  media */
/* propagation  time  and the delay  time through a  station and,  as */
/* such, is implementation-dependent  (see 4.1.2.2). While  operating */
/* at  speeds of 100 Mb/s or lower, an implementation may  optionally */
/* elect to end  retransmission attempts after  a  late collision  is */
/* detected.  While  operating  at    the  speed  of  1000  Mb/s,  an */
/* implementation shall  end retransmission  attempts  after  a  late */
/* collision is detected.                                             */
/*                                                                    */

/*                                                                    */
/* Random                                                             */
/*                                                                    */
/* After  transmission   of  the   jam   has   been    completed,  if */
/* TransmitLinkMgmt determines  that another attempt should  be made, */
/* BackOff  is called to schedule the next  attempt to retransmit the */
/* frame.                                                             */
/*                                                                    */

function automatic [10:0] Random; // (low, high: integer): integer;
input[10:0] low;
input[10:0] high;
begin
    Random = $urandom_range((high - 1), low); // {Uniformly distributed random integer r, such that low <= r < high}
end // {Random}
endfunction

/*                                                                    */
/* BackOff                                                            */
/*                                                                    */
/* BackOff  performs   the  truncated    binary  exponential  backoff */
/* computation  and then waits for  the selected multiple of the slot */
/* time:                                                              */

task BackOff;
reg[10:0] maxBackOff; // var maxBackOff: 2..1024; {Working variable of BackOff}

reg[10:0] BackOffBitTimes;

begin

    if (debug) $display($time, " %m start BackOff");

    if (attempts == 1) // then
    begin
        maxBackOff = 2;
    end
    else if (attempts <= backOffLimit) // then 
    begin
        maxBackOff = maxBackOff * 2;
    end

//  Wait(slotTime * Random(0, maxBackOff));
    BackOffBitTimes = slotTime * Random(0, maxBackOff);
    Wait(BackOffBitTimes);

    if (debug) $display($time, " %m end BackOff");

end // {BackOff}
endtask

/*                                                                    */
/* BurstTimer                                                         */
/*                                                                    */
/* BurstTimer is  a  process  that  does nothing unless  the bursting */
/* variable  is  true. When  bursting is  true, BurstTimer increments */
/* burstCounter until  the  burstLimit  limit is  reached,  whereupon */
/* BurstTimer assigns the value false to bursting:                    */
/*                                                                    */

always // process BurstTimer;
begin : BurstTimer

    if (debug) $display($time, " %m start BurstTimer");

    wait(bursting) // while not bursting do nothing; {Wait for a burst}
    Wait(burstLimit);
    bursting = false;

    if (debug) $display($time, " %m end BurstTimer");

end // {burstMode cycle}
// end; {BurstTimer}

/*                                                                    */
/* Deference                                                          */
/*                                                                    */
/* The Deference process  runs asynchronously to continuously compute */
/* the  proper value for the variable  deferring. In the case of half */
/* duplex burst mode, deferring remains  true  throughout the  entire */
/* burst.  Interpacket gap spacing may be used  to lower  the average */
/* data rate of  a MAC  at  operating speeds  above 1000 Mb/s  in the */
/* full  duplex mode, when it is  necessary to adapt it to  the  data */
/* rate of a WAN-based  Physical Layer.  When  interpacket stretching */
/* is enabled, deferring remains true throughout the entire  extended */
/* interpacket gap, which includes the  sum of interPacketGap and the */
/* interpacket extension as determined by the BitTransmitter:         */
/*                                                                    */

reg[31:0] realTimeCounter;
reg       wasTransmitting;

always // process Deference;
begin : Deference

    if (debug) $display($time, " %m start Deference");

    if (halfDuplex) // then cycle {Half duplex loop}
    begin
        wait (carrierSense); // while not carrierSense do nothing; {Watch for carrier to appear}
        deferring = true; // {Delay start of new transmissions}
        wasTransmitting = transmitting;
        while (carrierSense || transmitting)
        begin
            wasTransmitting = (wasTransmitting || transmitting);
            #0.1;   // Need to add delay to advance time
        end
        if (wasTransmitting)
        begin
            Wait(interPacketGapPart1); // {Time out first part of interpacket gap}
        end
        else
        begin
            realTimeCounter = interPacketGapPart1;
            while (realTimeCounter != 0) // repeat
            begin
                while (carrierSense)
                begin
                    realTimeCounter = interPacketGapPart1;
                    nothing;   // Need to add delay to advance time
                end
                Wait(1);
//#(bitTimeDuration/1_000_000);
                realTimeCounter = realTimeCounter - 1;
            end // until (realTimeCounter = 0)
        end
        Wait(interPacketGapPart2); // {Time out second part of interpacket gap}
        deferring = false;    // {Allow new transmissions to proceed}
        wait (!frameWaiting); // while frameWaiting do nothing {Allow waiting transmission, if any}
    end // {Half duplex loop}
    else // cycle {Full duplex loop}
    begin
        wait (transmitting);  // while not transmitting do nothing; {Wait for the start of a transmission}
        deferring = true;     // {Inhibit future transmissions}
        wait (!transmitting); // while transmitting do nothing; {Wait for the end of the current transmission}
        Wait(interPacketGap + (ipgStretchSize * 8)); // {Time out entire interpacket gap and IPG extension}
        if (!frameWaiting)    // then {Don’t roll over the remainder into the next frame}
        begin
            Wait(8);
            ipgStretchCount = 0;
        end
        deferring = false; // {Don’t inhibit transmission}
    end // {Full duplex loop}

    if (debug) $display($time, " %m end Deference");

end // {Deference}

/*                                                                    */
/* If the ipgStretchMode  is enabled, the Deference process continues */
/* to enforce interpacket gap  for an additional number of bit times, */
/* after the completion of timing the interPacketGap.  The additional */
/* number of bit  times is reflected by the variable  ipgStretchSize. */
/* If the variable ipgStretchCount  is  less than ipgStretchRatio and */
/* the next frame  is ready for transmission  (variable  frameWaiting */
/* is true), the Deference process enforces interpacket gap  only for */
/* the integer  number of octets, as indicated by ipgStretchSize, and */
/* saves  ipgStretchCount for the  next frame’s transmission. If  the */
/* next  frame is  not ready for transmission (variable  frameWaiting */
/* is   false),    then   the   Deference   process  initializes  the */
/* ipgStretchCount variable to zero.                                  */
/*                                                                    */

/*                                                                    */
/* BitTransmitter                                                     */
/*                                                                    */
/* The  BitTransmitter process runs asynchronously, transmitting bits */
/* at  a  rate  determined  by   the  Physical   Layer’s  TransmitBit */
/* operation:                                                         */
/*                                                                    */

always @ * // process BitTransmitter;
begin : BitTransmitter // cycle {Outer loop}

    if (debug) $display($time, " %m start BitTransmitter");

    if (transmitting) // then
    begin // {Inner loop}
        extendError = false;
        if (ipgStretchMode) // then {Calculate the counter values}
        begin
            ipgStretchSize = ((ipgStretchCount + headerSize + frameSize + interPacketGap) / ipgStretchRatio); // {Extension of the interpacket gap}
            ipgStretchCount = (ipgStretchCount + headerSize + frameSize + interPacketGap);
        end
        PhysicalSignalEncap; // {Send preamble and start of frame delimiter}
        while (transmitting) // do
        begin
            if (currentTransmitBit > lastTransmitBit)
            begin
                TransmitBit(extensionBit);
            end
            else if (extendError) // then 
            begin
                TransmitBit(extensionErrorBit); // {Jam in extension}
            end
            else 
            begin
                TransmitBit({1'b0, outgoingFrame[currentTransmitBit]});
            end
            if (newCollision) // then 
            begin
                StartJam;
            end
            else
            begin
                NextBit;
            end
        end
        if (bursting) // then
        begin
            interPacketSignal;
            if (extendError) // then
            begin
                if (transmitting) // then 
                begin
                    transmitting = false; // {TransmitFrame may have been called during interPacketSignal}
                end
                else 
                begin
                    lateCollision = IncLargeCounter(lateCollision); // {Count late collisions which were missed by TransmitLinkMgmt}
                end
            bursting = bursting && (frameWaiting || transmitting);
            end
        end // {Inner loop}
    end // {Outer loop}

    if (debug) $display($time, " %m end BitTransmitter");

end // {BitTransmitter}

/* The bits transmitted to the  Physical Layer can  take  one of four */
/* values:  data  zero (0), data  one (1), extensionBit (EXTEND),  or */
/* extensionErrorBit  (EXTEND_ERROR).  The  values  extensionBit  and */
/* extensionErrorBit are  not transmitted between the first  preamble */
/* bit  of  a frame  and  the  last data bit  of  a  frame  under any */
/* circumstances. The BitTransmitter calls the  procedure TransmitBit */
/* with bitParam = extensionBit only  when it is necessary to perform */
/* carrier extension  on a frame after  all of  the data  bits  of  a */
/* frame   have  been  transmitted.  The  BitTransmitter   calls  the */
/* procedure TransmitBit with bitParam  = extensionErrorBit only when */
/* it is necessary to jam during carrier extension.                   */

task PhysicalSignalEncap;
begin

    if (debug) $display($time, " %m start PhysicalSignalEncap");

    while (currentTransmitBit <= lastHeaderBit) // do
    begin
        TransmitBit({1'b0, outgoingHeader[currentTransmitBit]}); // {Transmit header one bit at a time}
        currentTransmitBit = currentTransmitBit + 1;
    end
    if (newCollision)
    begin
       StartJam;
    end
    else
    begin
        currentTransmitBit = 1;
    end

    if (debug) $display($time, " %m end PhysicalSignalEncap");

end // {PhysicalSignalEncap}
endtask


/* The procedure  interPacketSignal  fills the  interpacket  interval */
/* between   the      frames  of  a   burst      with  extensionBits. */
/* InterPacketSignal  also  monitors   the  variable  collisionDetect */
/* during  the interpacket interval  between  the frames of  a burst, */
/* and will end a burst if a collision occurs during the  interpacket */
/* interval.  The  procedural  model  is  defined  such  that  a  MAC */
/* operating  in the burstMode will  emit an extraneous  sequence  of */
/* interPacketSize extensionBits  in  the  event  that there  are  no */
/* additional frames ready for  transmission after  interPacketSignal */
/* returns.  Implementations  may  be  able  to  avoid  sending  this */
/* extraneous  sequence of  extensionBits  if  they  have  access  to */
/* information (such as  the  occupancy of  a transmit queue) that is */
/* not assumed to be available to the procedural model.               */

initial if (debug) $display("Maint? interPacketTotal = interPacketSpacing;");

task interPacketSignal;
reg[6:0] interPacketCount;
reg[6:0] interPacketTotal;
begin

    if (debug) $display($time, " %m start interPacketSignal");

    interPacketCount = 0;
    interPacketTotal = interPacketGap;
    while (interPacketCount < interPacketTotal) // do
    begin
        if (!extendError)
        begin
            TransmitBit(extensionBit);
        end
        else
        begin
            TransmitBit(extensionErrorBit);
        end
        interPacketCount = interPacketCount + 1;
        if (collisionDetect && !extendError) // then
        begin
            bursting = false;
            extendError = true;
            interPacketCount = 0;
            interPacketTotal = jamSize;
        end
    end

    if (debug) $display($time, " %m end interPacketSignal");

end // {interPacketSignal}
endtask

task NextBit;
begin
    currentTransmitBit = currentTransmitBit + 1;
    if (halfDuplex && burstStart && transmitSucceeding) // then {Carrier extension may be required}
    begin
       transmitting = (currentTransmitBit <= max(lastTransmitBit, slotTime));
    end
    else
    begin
        transmitting = (currentTransmitBit <= lastTransmitBit);
    end
end // {NextBit}
endtask

task StartJam;
begin

    if (debug) $display($time, " %m start StartJam");

    extendError        = (currentTransmitBit > lastTransmitBit) ? true : false;
    currentTransmitBit = 1;
    lastTransmitBit    = jamSize;
    newCollision       = false;

    if (debug) $display($time, " %m end StartJam");

end // {StartJam}
endtask

/* BitTransmitter,   upon  detecting  a  new  collision,  immediately */
/* enforces  it by calling StartJam to  initiate  the transmission of */
/* the  jam. The  jam should  contain a sufficient number  of bits of */
/* arbitrary  data  so  that it  is assured  that both  communicating */
/* stations detect  the  collision. (StartJam  uses  the first set of */
/* bits of the frame up to jamSize, merely to simplify this program.) */


/*                                                                    */
/* 4.2.9 Frame reception                                              */
/*                                                                    */
/* The algorithms  in  this  subclause  define CSMA/CD  Media  Access */
/* sublayer frame reception.                                          */
/*                                                                    */
/* The   function   ReceiveFrame   implements  the   frame  reception */
/* operation provided to the MAC client.                              */
/*                                                                    */
/* The ReceiveFrame operation is synchronous. The operation does  not */
/* complete until a frame has been
received. The fields  of  the frame */
/* are delivered via the output parameters with a status code.        */
/*                                                                    */
/* The   receiveDisabled   status  code  (if   layer   management  is */
/* implemented)  indicates  that  the   receiver  is   not   enabled. */
/* Successful reception is indicated by  the status  code  receiveOK. */
/* The frameTooLong error  code (if layer management is  implemented) */
/* indicates that the last frame received had a frameSize  beyond the */
/* maximum  allowable frame size. The code  frameCheckError indicates */
/* that the frame received  was damaged by a transmission  error. The */
/* lengthError  indicates  that the lengthOrTypeParam  value was both */
/* consistent with a length interpretation  of this field (i.e.,  its */
/* value was  less  than or equal to maxValidFrame), and inconsistent */
/* with the frameSize of the  received frame. The code alignmentError */
/* indicates  that  the  frame  received  was  damaged, and  that  in */
/* addition,  its  length  was  not  an  integer  number  of  octets. */
/* ReceiveStatus is not mapped  to any  MAC client parameter  by  the */
/* service  interface defined in 2.3.2. ReceiveStatus  may be used in */
/* an implementation dependent manner.                                */
/*                                                                    */

task ReceiveFrame;                 //
output[47:0]    destinationParam;  // AddressValue;
output[47:0]    sourceParam;       // AddressValue;
output          lengthOrTypeParam; // LengthOrTypeValue;
output[71999:0] dataParam;         // DataValue;
output[31:0]    fcsParamValue;     // CRCValue;
output          fcsParamPresent;   // Bit): 
output[2:0]     ReceiveFrame;      // ReceiveStatus;

reg             repeateControl;    // Needed to emulate Pascal repeat-until loop

// function ReceiveDataDecap: ReceiveStatus; {Nested function; see body below}
begin

    if (debug) $display($time, " %m start ReceiveFrame");

    if (receiveEnabled) // then
    begin

        repeateControl = true; // Pascal repeat-until loop always executes once
        while (repeateControl) // repeat
        begin
            if (debug) $display($time, " %m ReceiveLinkMgmtCall");
            ReceiveLinkMgmt(ReceiveFrame);
            if (debug) $display($time, " %m ReceiveLinkMgmtDone");
            if (debug) $display($time, " %m ReceiveDataDecapCall");
            ReceiveDataDecap(
                           destinationParam,
                           sourceParam,
                           lengthOrTypeParam,
                           dataParam,
                           fcsParamValue,
                           fcsParamPresent,
                           ReceiveFrame
                           );
            if (debug) $display($time, " %m ReceiveDataDecapDone");
            repeateControl = !receiveSucceeding; // until receiveSucceeding
        end
    end 
    else 
    begin
        #100; // Added to advance time when receiveDisabled = true
        ReceiveFrame = receiveDisabled;
    end

    if (debug) $display($time, " %m end ReceiveFrame");

end // {ReceiveFrame}
endtask

/*                                                                    */
/* If enabled,  ReceiveFrame  calls  ReceiveLinkMgmt  to  receive the */
/* next  valid   frame,   and   then  calls  the   internal  function */
/* ReceiveDataDecap  to return the  frame’s fields to the  MAC client */
/* if  the  frame’s  address  indicates that it  should  do  so.  The */
/* returned  ReceiveStatus  indicates  the  presence  or  absence  of */
/* detected transmission errors in the frame.                         */
/*                                                                    */

task ReceiveDataDecap; // : ReceiveStatus;

output[47:0]    destinationParam;  // AddressValue;
output[47:0]    sourceParam;       // AddressValue;
output[15:0]    lengthOrTypeParam; // LengthOrTypeValue;
output[71999:0] dataParam;         // DataValue;
output[31:0]    fcsParamValue;     // CRCValue;
output          fcsParamPresent;   // Bit): 
output[2:0]     status;            // ReceiveStatus;

begin
    // with incomingFrame do

    if (debug) $display($time, " %m start ReceiveDataDecap");

    begin
        // view = fields;
        receiveSucceeding = LayerMgmtRecognizeAddress(incomingFrame[48:1]);
        if (receiveSucceeding) // then
        begin // {Disassemble MAC frame}
            destinationParam  = incomingFrame[48:1];
            sourceParam       = incomingFrame[96:49];
            lengthOrTypeParam = incomingFrame[112:97];
            dataParam         = RemovePad(incomingFrame[112:97], incomingFrame[71999:113]);
            fcsParamValue     = ExtractFCS(incomingFrame, incomingFrameSize);
            fcsParamPresent   = passReceiveFCSMode;

                                    // {Check to determine if received MAC frame size exceeds
                                    // maxFrameSizeLimit.
                                    // MAC implementations use maxFrameSizeLimit to
                                    // determine if management counts the frame as too long.
                                    // It is recommended that new implementations support
                                    // maxFrameSizeLimit = maxEnvelopeFrameSize )
            exceedsMaxLength = (incomingFrameSize > maxFrameSizeLimit) ? true : false;

            if (exceedsMaxLength) // then
            begin
                status = frameTooLong;
            end
            // else if fcsField = CRC32(incomingFrame) and extensionOK then
            else if ((fcsParamValue == CRC32(incomingFrame, TRUE)) && (extensionOK)) // then
            begin
                if (validLength)
                begin
                    status = receiveOK;
                end
                else
                begin
                    status = lengthError;
                end
            end
            else if ((excessBits == 0) || (!extensionOK))
            begin
                status = frameCheckError;
            end
            else
            begin
                status = alignmentError;
            end
            LayerMgmtReceiveCounters(status); // {Update receive counters in 5.2.4.3}
            // view := bits;
        end // {Disassemble MAC frame}
    end // {With incomingFrame}
    // ReceiveDataDecap = status;

    if (debug) $display($time, " %m end ReceiveDataDecap");

end // {ReceiveDataDecap}
endtask

/*                                                                    */
/* Function LayerMgmtRecognizeAddress checks if reception of  certain */
/* addressing    types  has  been  enabled.  Note   that  in  Pascal, */
/* assignment  to  a  function   causes   the   function  to   return */
/* immediately.                                                       */
/*                                                                    */

reg       promiscuous_receive_enabled;
reg       multicast_receive_enabled;
reg[47:0] MAC_station_address;

parameter Broadcast_address = 48'hFF_FF_FF_FF_FF_FF;

function LayerMgmtRecognizeAddress; // (address: AddressValue): Boolean;
input[47:0] address;
begin

    if (debug) $display($time, " %m start LayerMgmtRecognizeAddress");

    if (promiscuous_receive_enabled) // then
    begin
        LayerMgmtRecognizeAddress = true;
    end
    else if (address == MAC_station_address) // then
    begin
        LayerMgmtRecognizeAddress = true;
    end
    else if (address == Broadcast_address) // then
    begin
        LayerMgmtRecognizeAddress = true;
    end
    else if (address_on_multicast_list(address) && multicast_receive_enabled) //... {One of the addresses on the multicast list
    begin                                                                     //     and multicast reception is enabled} then
       LayerMgmtRecognizeAddress = true;
    end
    else
    begin
        LayerMgmtRecognizeAddress = false;
    end

    if (debug) $display($time, " %m end LayerMgmtRecognizeAddress");

end // {LayerMgmtRecognizeAddress}
endfunction

/*                                                                    */
/* The  function RemovePad strips any  padding that was  generated to */
/* meet  the  minFrameSize  constraint,  if  possible.  When the  MAC */
/* sublayer  operates in the  mode  that enables passing of the frame */
/* check sequence field of all received  MAC frames to the MAC client */
/* (passReceiveFCSMode  variable  is  true), it  shall  not strip the */
/* padding  and  it shall  leave  the  data  field  of the MAC  frame */
/* intact. Length  checking is provided for Length interpretations of */
/* the Length/Type field.  For Length/Type field  values in the range */
/* between  maxBasicDataSize and  minTypeValue, the  behavior of  the */
/* RemovePad function is unspecified:                                 */
/*                                                                    */

function[71999:0] RemovePad; // (var lengthOrTypeParam: LengthOrTypeValue; dataParam: DataValue): DataValue;

input[15:0]     lengthOrTypeParam;
input[71999:0]  dataParam;

reg[13:0]       length;

begin

    if (debug) $display($time, " %m start RemovePad");

    if (lengthOrTypeParam >= minTypeValue) // then
    begin
        validLength = true; // {Don’t perform length checking for Type interpretation}
        RemovePad = dataParam;
    end
    else if (lengthOrTypeParam <= maxBasicDataSize) //  then
    begin

        // {For length interpretations of the Length/Type field, check to determine if value
        //  represented by Length/Type field matches the received clientDataSize};

        if (debug) $display($time, " %m Need to add length check");
        validLength = true;

        if (validLength && !passReceiveFCSMode) // then
        begin
            // {Truncate the dataParam (when present) to the value represented by the
            // lengthOrTypeParam (in octets) and return the result}

            RemovePad = {72000{1'bX}};
            for (length = 0; (length <= (lengthOrTypeParam * 8)); length = length + 1);
            begin
                RemovePad[length] = dataParam[length];
            end
        end
        else
        begin
           RemovePad = dataParam;
        end
    end

    if (debug) $display($time, " %m end RemovePad");

end // {RemovePad}
endfunction

/*                                                                    */
/* ReceiveLinkMgmt  attempts  repeatedly  to  receive  the  bits of a */
/* frame,  discarding any fragments from collisions by comparing them */
/* to the minimum valid frame size:                                   */
/*                                                                    */

task ReceiveLinkMgmt;

reg             repeateControl;    // Needed to emulate Pascal repeat-until loop

begin

    if (debug) $display($time, " %m start ReceiveLinkMgmt");

    repeateControl = true; // Pascal repeat-until loop always executes once

    while (repeateControl) // repeat
    begin
        StartReceive;
        wait (!receiving); // while receiving do nothing; {Wait for frame to finish arriving}
        excessBits = incomingFrameSize % 8;                 // Was excessBits = frameSize mod 8;"
        incomingFrameSize = incomingFrameSize - excessBits; // Was frameSize = frameSize - excessBits; // {Truncate to octet boundary}
        receiveSucceeding = (receiveSucceeding && (incomingFrameSize >= minFrameSize));
                                                            // Was receiveSucceeding = (receiveSucceeding && (frameSize >= minFrameSize));
                          // {Reject collision fragments}
        repeateControl = !receiveSucceeding; // until receiveSucceeding
    end

    if (debug) $display($time, " %m end ReceiveLinkMgmt");

end // {ReceiveLinkMgmt}
endtask

task StartReceive;
begin

    if (debug) $display($time, " %m start StartReceive");

    receiveSucceeding = true;
    receiving = true;

    if (debug) $display($time, " %m end StartReceive");

end // {StartReceive}
endtask

/*                                                                    */
/* The  BitReceiver process runs  asynchronously, receiving bits from */
/* the  medium  at  the  rate  determined  by  the  Physical  Layer’s */
/* ReceiveBit    operation,  partitioning   them  into   frames,  and */
/* optionally receiving them:                                         */
/*                                                                    */

reg[1:0]  b;                 // PhysicalBit
reg[16:0] incomingFrameSize; // {Count of all bits received in frame including extension}
reg       frameFinished;
reg       enableBitReceiver; // Boolean
reg[16:0] currentReceiveBit; // 1..frameSize; {Position of current bit in incomingFrame}

initial  // process BitReceiver;
begin
    forever
    begin // : BitReceiver // cycle {Outer loop}

        if (debug) $display($time, " %m start BitReceiver");

        if (receiveEnabled) // then
        begin // {Receive next frame from Physical Layer}
            
            currentReceiveBit = 1;
            incomingFrameSize = 0;
            frameFinished     = false;
            enableBitReceiver = receiving;
            PhysicalSignalDecap; // {Skip idle and extension, strip off preamble and sfd}
            if (enableBitReceiver)
            begin
                extensionOK = true;
            end
            while (receiveDataValid && !frameFinished) // do
            begin // {Inner loop to receive the rest of an incoming frame}
                ReceiveBit(b); // b := ReceiveBit; {Next bit from physical medium}
                incomingFrameSize = incomingFrameSize + 1;
                if ((b == 0) || (b == 1)) // then {Normal case}
                begin
                    if (enableBitReceiver) // then {Append to frame}
                    begin
                        if (incomingFrameSize > currentReceiveBit)
                        begin
                            extensionOK = false;
                        end
                        incomingFrame[currentReceiveBit] = b;
                        currentReceiveBit = currentReceiveBit + 1;
                    end
                    else if (!extending)
                    begin
                        frameFinished = true; // {b must be an extensionBit}
                    end
                end
                if (incomingFrameSize >= slotTime) // then 
                begin
                    extending = false;
                end
            end  // {Inner loop}

            if (enableBitReceiver) // then
            begin

                // Need a clock after RX_DV negates to exit loop");
                // Need a dealy at end of loop to prevent incomingFrameSize and receiving race conditon");
                // Was frameSize = currentReceiveBit - 1;");

                incomingFrame[currentReceiveBit] = 1'bx;   // Addition since first 1'bx marks end of frame
                incomingFrameSize = currentReceiveBit - 2; // Was frameSize = currentReceiveBit - 1;

                receiveSucceeding = !extending;
                receiving = false;
                #0.1; // Need a dealy to prevent incomingFrameSize and receiving race conditon
            end
        end // {Enabled}
        else #100; // Added to advance time when receiveEnabled = false
    end // {Outer loop} 
end // {BitReceiver}

/* The bits  received from the Physical Layer can take one  of  three */
/* values: data  zero (0), data one  (1), or  extensionBit  (EXTEND). */
/* The value extensionBit will not  occur between  the first preamble */
/* bit  of  a frame  and the  last  data  bit  of  a frame  in normal */
/* circumstances. Extension bits  are counted by the  BitReceiver but */
/* are not  appended to  the incoming  frame. The  BitReceiver checks */
/* whether the bit  received from the Physical Layer is a data bit or */
/* an extensionBit before appending it to  the incoming frame.  Thus, */
/* the  array of  bits in incomingFrame will  only contain data bits. */
/* The  underlying  Reconciliation  Sublayer   (RS)  maps    incoming */
/* EXTEND_ERROR  bits to  normal  data  bits. Thus,  the reception of */
/* additional data bits after the frame extension  has started  is an */
/* indication that the frame should be discarded.                     */

task PhysicalSignalDecap;

reg[7:0] lastEightBits;
reg      sfdFound;
reg      ReceiveBit;

begin // {Receive one bit at a time from physical medium until a valid sfd is detected, discard bits and return}

    if (debug) $display($time, " %m start PhysicalSignalDecap");

    sfdFound = false;
    lastEightBits = 8'hXX;

    while (sfdFound == false)
    begin

        ReceiveBit(ReceiveBit);

        if((ReceiveBit == zero) && (receiveDataValid === true))
        begin
            lastEightBits = {lastEightBits[6:0], 1'b0};
        end
        else if((ReceiveBit == one) && (receiveDataValid === true))
        begin
            lastEightBits = {lastEightBits[6:0], 1'b1};
        end
        else
        begin
            lastEightBits = {lastEightBits[6:0], 1'bx};
        end

       if(lastEightBits === 8'b10101011)
       begin
           sfdFound = true;
       end

    end

    if (debug) $display($time, " %m end BitReceiver");

end // {PhysicalSignalDecap}
endtask

/* The  process  SetExtending controls the extending  variable, which */
/* determines whether  a received frame  must be  at  least  slotTime */
/* bits  in length  or  merely  minFrameSize  bits  in  length to  be */
/* considered  valid  by   the  BitReceiver.  SetExtending  sets  the */
/* extending  variable     to   true  whenever   receiveDataValid  is */
/* de-asserted, while in half duplex  mode  at an  operating speed of */
/* 1000 Mb/s:                                                         */

initial // process SetExtending;
begin
    forever
    begin
        while (receiveDataValid)
        begin
            nothing;
        end
        extending = extend && halfDuplex;
        nothing; // Need to add delay to advance time
    end //{Loop}
end // {SetExtending}

/*                                                                    */
/* 4.2.10 Common procedures                                           */
/*                                                                    */
/* The function  CRC32  is  used  by  both the transmit  and  receive */
/* algorithms to generate a 32-bit CRC value:                         */
/*                                                                    */

function[31:0] CRC32;
input[71999:0] Frame;
input          FCS_present;

reg[16:0]      CRC32_bit;
reg[31:0]      CRC32_next;

begin

    CRC32 = 32'hFF_FF_FF_FF;

    if(FCS_present)
    begin
        for (CRC32_bit = 1; Frame[CRC32_bit] !== 1'bx; CRC32_bit = CRC32_bit + 1);
        Frame[CRC32_bit - 33] = 1'bx;
    end

    for (CRC32_bit = 1; Frame[CRC32_bit] !== 1'bx; CRC32_bit = CRC32_bit + 1)
    begin
        CRC32_next[0]     = CRC32[31] ^ Frame[CRC32_bit];
        CRC32_next[1]     = CRC32[0]  ^ CRC32[31] ^ Frame[CRC32_bit];
        CRC32_next[2]     = CRC32[1]  ^ CRC32[31] ^ Frame[CRC32_bit];
        CRC32_next[3]     = CRC32[2];
        CRC32_next[4]     = CRC32[3]  ^ CRC32[31] ^ Frame[CRC32_bit];
        CRC32_next[5]     = CRC32[4]  ^ CRC32[31] ^ Frame[CRC32_bit];
        CRC32_next[6]     = CRC32[5];
        CRC32_next[7]     = CRC32[6]  ^ CRC32[31] ^ Frame[CRC32_bit];
        CRC32_next[8]     = CRC32[7]  ^ CRC32[31] ^ Frame[CRC32_bit];
        CRC32_next[9]     = CRC32[8];
        CRC32_next[10]    = CRC32[9]  ^ CRC32[31] ^ Frame[CRC32_bit];
        CRC32_next[11]    = CRC32[10] ^ CRC32[31] ^ Frame[CRC32_bit];
        CRC32_next[12]    = CRC32[11] ^ CRC32[31] ^ Frame[CRC32_bit];
        CRC32_next[15:13] = CRC32[14:12];
        CRC32_next[16]    = CRC32[15] ^ CRC32[31] ^ Frame[CRC32_bit];
        CRC32_next[21:17] = CRC32[20:16];
        CRC32_next[22]    = CRC32[21] ^ CRC32[31] ^ Frame[CRC32_bit];
        CRC32_next[23]    = CRC32[22] ^ CRC32[31] ^ Frame[CRC32_bit];
        CRC32_next[25:24] = CRC32[24:23];
        CRC32_next[26]    = CRC32[25] ^ CRC32[31] ^ Frame[CRC32_bit];
        CRC32_next[31:27] = CRC32[30:26];

        CRC32 = CRC32_next;

    end

    CRC32_next = ~CRC32_next;
    CRC32 = ~CRC32;

end // {CRC32}

endfunction

/* Purely  to  enhance readability, the following  procedure is  also */
/* defined:                                                           */

task automatic nothing;
begin
    if (|bitTimeDuration === 1'bx) 
    begin
        #10; // bitTimeDuration not set to a value
    end
    else
    begin
        #(bitTimeDuration/10_000_000); // 1/10 of a bit time
    end
end
endtask

/* The idle state  of  a  process  (that  is, while waiting  for some */
/* event) is cast as repeated calls on this procedure.                */

/*                                                                    */
/* 4.3.3 Services required from the Physical Layer                    */
/*                                                                    */

/*                                                                    */
/* During transmission, the contents of an  outgoing frame are passed */
/* from  the MAC sublayer to  the Physical Layer by  way  of repeated */
/* use of the TransmitBit operation:                                  */
/*                                                                    */

event      sendBit;
event      bitSent;

task TransmitBit; // procedure TransmitBit (bitParam: PhysicalBit);
input[1:0] bitParam;
begin
    -> sendBit;
    @(bitSent);
end
endtask

/*                                                                    */
/* Each invocation of TransmitBit passes one new  bit of the outgoing */
/* frame  to  the  Physical  Layer.  The  TransmitBit   operation  is */
/* synchronous.  The  duration  of   the  operation   is  the  entire */
/* transmission  of  the  bit.  The  operation  completes,  when  the */
/* Physical Layer  is ready to accept the  next bit and it  transfers */
/* control to the MAC sublayer.                                       */
/*                                                                    */
/* The  overall  event of data  being transmitted  is signaled to the */
/* Physical Layer by way of the variable transmitting:                */
/*                                                                    */

reg transmitting; // Boolean;

/*                                                                    */
/* Before sending  the  first  bit of a frame, the  MAC sublayer sets */
/* transmitting to  true, to inform the Physical Media  Access that a */
/* stream of bits  will  be presented  via the TransmitBit operation. */
/* After  the  last bit  of  the  frame has been presented,  the  MAC */
/* sublayer  sets  transmitting to  false to  indicate the end of the */
/* frame.                                                             */
/*                                                                    */
/* The presence of a collision in the physical medium is  signaled to */
/* the MAC sublayer by the variable collisionDetect:                  */
/*                                                                    */

reg collisionDetect; // Boolean;

/* During reception, the contents of  an incoming frame are retrieved */
/* from  the Physical Layer by the  MAC sublayer  via repeated use of */
/* the ReceiveBit operation:                                          */

event      PLS_DATA_indication;

task ReceiveBit; // function ReceiveBit: Bit;
output     ReceiveBit;
reg[1:0]   receive_bit_value;

begin : ReceiveBitTask
   @(PLS_DATA_indication)
   ReceiveBit = receive_bit_value;
end
endtask

/* Each  invocation of  ReceiveBit  retrieves  one  new  bit  of  the */
/* incoming frame from the Physical Layer.  The ReceiveBit  operation */
/* is synchronous. Its  duration is the entire reception of a  single */
/* bit. Upon receiving a  bit, the  MAC  sublayer  shall  immediately */
/* request  the  next bit until all  bits  of  the  frame  have  been */
/* received (see 4A.2 for details).                                   */

/*                                                                    */
/* The  overall event of data being received is signaled  to the  MAC */
/* sublayer by the variable receiveDataValid:                         */
/*                                                                    */

reg receiveDataValid; // Boolean;

always @(negedge receiveDataValid)
begin
    disable ReceiveBit.ReceiveBitTask;
end

/*                                                                    */
/* The  overall event of activity on  the physical medium is signaled */
/* to the MAC sublayer by the variable carrierSense:                  */
/*                                                                    */

reg carrierSense; // Boolean;

/*                                                                    */
/* Wait                                                               */
/*                                                                    */
/* The Physical Layer also provides the procedure Wait:               */
/*                                                                    */

task automatic Wait; // (bitTimes: integer);
input[31:0] bitTimes;
reg[31:0]   count;
begin
    count     = 0;
    for(count = 0; count < bitTimes; count = count + 1) 
    begin
       #(bitTimeDuration/1_000_000);
    end
end
endtask

/*                                                                    */
/* 4.4 Specific implementations                                       */
/*                                                                    */

/*                                                                    */
/* slotTime                                                           */
/*                                                                    */
/* {In  bit    times,  unit   of   time  for    collision   handling, */
/* implementation-dependent, see 4.4}                                 */
/*                                                                    */

always @(rate)
begin

    case(rate)

    ten_hundred_mbs: slotTime = 512; 
    one_gbs:         slotTime = 4096; 
    default:         slotTime = 4096;
    endcase

end

/*                                                                    */
/* 5.2.4 DTE Management procedural model                              */
/*                                                                    */
/* The   following  model  provides  the  descriptions     for  Layer */
/* Management facilities.                                             */
/*                                                                    */
/* 5.2.4.1 Common constants and types                                 */
/* The following are the common constants and types  required for the */
/* Layer Management procedures:                                       */
/*                                                                    */

// const
// maxDeferTime = …; {2 X (maxBasicFrameSize x 8), for operating speeds of 100 Mb/s and below,
// and 2 x (burstLimit + maxBasicFrameSize x 8 + headerSize) for operating
// speeds greater than 100 Mb/s, in bits, error timer limit for maxDeferTime}

initial if(debug) $display("Doesn't seem correct for 2.5Gb/s and greater");

reg[32:0] maxDeferTime;

always @(rate)
begin

    case(rate)

    ten_hundred_mbs: maxDeferTime = 2 * (maxBasicFrameSize * 8); 
    one_gbs:         maxDeferTime = 2 * (burstLimit + (maxBasicFrameSize * 8) + headerSize); 
    other_gbs:       maxDeferTime = 2 * (burstLimit + (maxBasicFrameSize * 8) + headerSize);
    ten_gbs:         maxDeferTime = 2 * (burstLimit + (maxBasicFrameSize * 8) + headerSize);
    endcase



end

// type
// CounterLarge = 0..maxLarge; {see footnote31}.

/*                                                                    */
/* 5.2.4.2 Transmit variables and procedures                          */
/*                                                                    */
/* The following items are specific to frame transmission:            */
/*                                                                    */

// var

reg       excessDefer;                  // Boolean; {set in process DeferTest}
reg       carrierSenseFailure;          // Boolean; {set in process CarrierSenseTest}
reg       transmitEnabled;              // Boolean; {set by MAC action}
reg       lateCollisionError;           // Boolean; {set in Section 4 procedure WatchForCollision}
reg       deferred;                     // Boolean; {set in Section 4 function TransmitLinkMgmt}
reg       carrierSenseTestDone;         // Boolean; {set in process CarrierSenseTest}
reg[4:0]  lateCollisionCount;           // 0..attemptLimit - 1; {count of late collision that is used in Clause 4 TransmitLinkMgmt and BitTransmitter}

// {MAC transmit counters}

reg[31:0] framesTransmittedOK;          // CounterLarge; {mandatory}
reg[31:0] singleCollisionFrames;        // CounterLarge; {mandatory}
reg[31:0] multipleCollisionFrames;      // CounterLarge; {mandatory}
reg[31:0] collisionFrames_1;            // array [1..attemptLimit – 1] of CounterLarge; {recommended}
reg[31:0] collisionFrames_2;
reg[31:0] collisionFrames_3;
reg[31:0] collisionFrames_4;
reg[31:0] collisionFrames_5;
reg[31:0] collisionFrames_6;
reg[31:0] collisionFrames_7;
reg[31:0] collisionFrames_8;
reg[31:0] collisionFrames_9;
reg[31:0] octetsTransmittedOK;          // CounterLarge; {recommended}
reg[31:0] deferredTransmissions;        // CounterLarge; {recommended}
reg[31:0] multicastFramesTransmittedOK; // CounterLarge; {optional}
reg[31:0] broadcastFramesTransmittedOK; // CounterLarge; {optional}

// {MAC transmit error counters}

reg[31:0] lateCollision;                // CounterLarge; {recommended}
reg[31:0] excessiveCollision;           // CounterLarge; {recommended}
reg[31:0] carrierSenseErrors;           // CounterLarge; {optional}
reg[31:0] excessiveDeferral;            // CounterLarge; {optional}


task LayerMgmtTransmitCounters;
begin
    if (halfDuplex)
    begin
        while (!carrierSenseTestDone)
        begin
            nothing;
        end
        if (transmitSucceeding)
        begin
            framesTransmittedOK = IncLargeCounter(framesTransmittedOK);
            octetsTransmittedOK = SumLarge(octetsTransmittedOK, dataSize/8); // {dataSize (in bits) is defined in 4.2.7.1}
            if (TransmitDataEncap.destinationParam[0] === 1'b1) // {check to see if to a multicast destination}
            begin
                multicastFramesTransmittedOK = IncLargeCounter(multicastFramesTransmittedOK);
            end
            if (TransmitDataEncap.destinationParam === Broadcast_address) // {check to see if to a broadcast destination}
            begin
                broadcastFramesTransmittedOK = IncLargeCounter(broadcastFramesTransmittedOK);
            end
            if (attempts > 1)
            begin // {transmission delayed by collision}
                if (attempts == 2)
                begin
                    singleCollisionFrames = IncLargeCounter(singleCollisionFrames); // {delay by 1 collision}
                end
                else // {attempts > 2, delayed by multiple collisions}
                begin
                    multipleCollisionFrames = IncLargeCounter(multipleCollisionFrames);

                end

                case(attempts) // IncLargeCounter(collisionFrames[attempts – 1])

                2  : collisionFrames_1 = IncLargeCounter(collisionFrames_1);
                3  : collisionFrames_2 = IncLargeCounter(collisionFrames_2);
                4  : collisionFrames_3 = IncLargeCounter(collisionFrames_3);
                5  : collisionFrames_4 = IncLargeCounter(collisionFrames_4);
                6  : collisionFrames_5 = IncLargeCounter(collisionFrames_5);
                7  : collisionFrames_6 = IncLargeCounter(collisionFrames_6);
                8  : collisionFrames_7 = IncLargeCounter(collisionFrames_7);
                9  : collisionFrames_8 = IncLargeCounter(collisionFrames_8);
                10 : collisionFrames_9 = IncLargeCounter(collisionFrames_9);

                endcase

            end // {delay by collision}
        end // {transmitSucceeding}
        if (deferred && (attempts == 1))
        begin
            deferredTransmissions = IncLargeCounter(deferredTransmissions);
        end
        if (lateCollisionCount > 0) // {test if late collision detected}
        begin
            lateCollision = SumLarge(lateCollision, lateCollisionCount);
        end
        if ((attempts == attemptLimit) && !transmitSucceeding)
        begin
            excessiveCollision = IncLargeCounter(excessiveCollision);
        end
        if (carrierSenseFailure)
        begin
            carrierSenseErrors = IncLargeCounter(carrierSenseErrors);
        end
        if (excessDefer)
        begin
            excessiveDeferral = IncLargeCounter(excessiveDeferral);
        end
    end
end // {LayerMgmtTransmitCounters}
endtask

/* The DeferTest process sets the excessDefer flag if a  transmission */
/* attempt  has been  deferred  for  a  period  of time  longer  than */
/* maxDeferTime.                                                      */

// process DeferTest;
reg[31:0] deferBitTimer; // var deferBitTimer: 0..maxDeferTime;

always @ (frameWaiting, excessDefer, deferBitTimer, maxDeferTime, transmitting)
begin : DeferTest // cycle
    begin
        deferBitTimer = 0;
        while (frameWaiting && !excessDefer)
        begin
            Wait(one); // Wait(oneBitTime); {see 4.3.3}
            if (deferBitTimer == maxDeferTime)
            begin
                excessDefer = true;
            end
            else
            begin
                deferBitTimer = deferBitTimer + 1;
            end
        end
        while (transmitting)
        begin
            nothing;
        end
    end // {cycle}
end // {DeferTest}

/*                                                                    */
/* The CarrierSenseTest process sets the carrierSenseFailure  flag if */
/* carrier  sense  disappears  while  transmitting  or  if  it  never */
/* appears during an entire transmission.                             */
/*                                                                    */


// process CarrierSenseTest;
// var
reg carrierSeen;   // Boolean; {Running indicator of whether or not carrierSense has been true at any
                   //           time during the current transmission}
reg collisionSeen; // Boolean; {Running indicator of whether or not the collisionDetect asserted any
                   //           time during the entire transmission}

always @(transmitting, carrierSense, carrierSeen, collisionDetect, collisionSeen)
begin : CarrierSenseTest
// cycle {main loop}
    while (!transmitting)
    begin
        nothing; // {wait for start of transmission}
    end
    carrierSenseFailure  = false;
    carrierSeen          = false;
    collisionSeen        = false;
    carrierSenseTestDone = false;
    while (transmitting)
    begin // {inner loop}
        if (carrierSense)
        begin
            carrierSeen = true;
        end
        else if (carrierSeen) // {carrierSense disappeared before end of transmission}
        begin
            carrierSenseFailure = true;
        end
        if (collisionDetect)
        begin
            collisionSeen = true;
        end
        nothing;
    end // {inner loop}
    if (!carrierSeen)
    begin
        carrierSenseFailure = true; // {carrier sense never appeared}
    end
    else if (collisionSeen)
    begin
        carrierSenseFailure = false;
    end
    carrierSenseTestDone = true;
// end {main loop}
end // {CarrierSenseTest}


/*                                                                    */
/* 5.2.4.3 Receive variables and procedures                           */
/* The following items are specific to frame reception:               */
/*                                                                    */

// var

reg       receiveEnabled;               // Boolean; {set by MAC action}

// {MAC receive counters}

reg[31:0] framesReceivedOK;             // CounterLarge; {mandatory}
reg[31:0] octetsReceivedOK;             // CounterLarge; {recommended}

// {MAC receive error counters}

reg[31:0] frameCheckSequenceErrors;     // CounterLarge; {mandatory}
reg[31:0] alignmentErrors;              // CounterLarge; {mandatory}
reg[31:0] inRangeLengthErrors;          // CounterLarge; {optional}
reg[31:0] outOfRangeLengthField;        // CounterLarge; {optional}
reg[31:0] frameTooLongErrors;           // CounterLarge; {optional}

// {MAC receive address counters}

reg[31:0] multicastFramesReceivedOK;    // CounterLarge; {optional}
reg[31:0] broadcastFramesReceivedOK;    // CounterLarge; {optional}

/*                                                                    */
/* Procedure    LayerMgmtReceiveCounters        is  called    by  the */
/* ReceiveDataDecap function in  4.2.9 and increments
 the appropriate */
/* receive counters.                                                  */
/*                                                                    */

task LayerMgmtReceiveCounters;
input[2:0] status;
begin

    case (status) // of

    receiveDisabled:
    begin
        // nothing
    end // {receiveDisabled}

    receiveOK:
    begin
        framesReceivedOK = IncLargeCounter(framesReceivedOK);

        octetsReceivedOK = SumLarge(octetsReceivedOK, dataSize/8); // {dataSize (in bits) is defined in 4.2.7.1}

        if (ReceiveDataDecap.destinationParam[0] === 1'b1) // {check to see if to a multicast destination}
        begin
            multicastFramesReceivedOK = IncLargeCounter(multicastFramesReceivedOK);
        end

        if (ReceiveDataDecap.destinationParam === Broadcast_address) // {check to see if to a broadcast destination}
        begin
            broadcastFramesReceivedOK = IncLargeCounter(broadcastFramesReceivedOK);
        end
    end // {receiveOK}

    frameTooLong:
    begin
        frameTooLongErrors = IncLargeCounter(frameTooLongErrors);
    end // {frameTooLong}

    frameCheckError:
    begin
        frameCheckSequenceErrors = IncLargeCounter(frameCheckSequenceErrors);
    end // {frameCheckError}

    alignmentError:
    begin
        alignmentErrors = IncLargeCounter(alignmentErrors);
    end // {alignmentError}

    lengthError: // {Note that ReceiveStatus is never lengthError for a type interpretation of the
                 // Length/Type field. See 4.2.9}
    begin
        // if {Length/Type field value is between the minimum MAC client data size that does not
        // require padding and maxBasicDataSize inclusive, and does not match the number of data
        // octets received} or {Length/Type field value is less than the minimum allowed MAC
        // client data size that does not require padding and the number of MAC client data octets
        // received is greater than the minimum MAC client data size that does not
        // require padding}
        if(((ReceiveDataDecap.lengthOrTypeParam >= (minFrameSize/8)) &&
            (ReceiveDataDecap.lengthOrTypeParam <= (maxBasicDataSize/8))) ||
           ((ReceiveDataDecap.lengthOrTypeParam < (minFrameSize/8)) &&
            (incomingFrameSize >= (minFrameSize/8))))
        begin
            inRangeLengthErrors = IncLargeCounter(inRangeLengthErrors);
        end

        // if {Length/Type field value is greater than maxBasicDataSize} then
        if(ReceiveDataDecap.lengthOrTypeParam > (maxBasicDataSize/8))
        begin
            outOfRangeLengthField = IncLargeCounter(outOfRangeLengthField);
        end

    end // {lengthError}

    endcase // {case status}

end // {LayerMgmtReceiveCounters}
endtask


/*                                                                    */
/* 5.2.4.4 Common procedures                                          */
/*                                                                    */
/* Procedure LayerMgmtInitialize  initializes all  the  variables and */
/* constants required to implement Layer Management.                  */
/*                                                                    */

task LayerMgmtInitialize;
begin

    // {initialize flags for enabling/disabling transmission and reception}
    receiveEnabled = true;
    transmitEnabled = true;

    // {initialize transmit flags for DeferTest and CarrierSenseTest}
    deferred = false;
    lateCollisionError = false;
    excessDefer = false;
    carrierSenseFailure = false;
    carrierSenseTestDone = false;

    // {Initialize all MAC sublayer management counters to zero}

    framesReceivedOK              = 32'h0000_0000;
    octetsReceivedOK              = 32'h0000_0000;

    // {MAC receive error counters}

    frameCheckSequenceErrors     = 32'h0000_0000;
    alignmentErrors              = 32'h0000_0000;
    inRangeLengthErrors          = 32'h0000_0000;
    outOfRangeLengthField        = 32'h0000_0000;
    frameTooLongErrors           = 32'h0000_0000;

    // {MAC receive address counters}

    multicastFramesReceivedOK    = 32'h0000_0000;
    broadcastFramesReceivedOK    = 32'h0000_0000;

    // {MAC transmit counters}

    framesTransmittedOK          = 32'h0000_0000;
    singleCollisionFrames        = 32'h0000_0000;
    multipleCollisionFrames      = 32'h0000_0000;
    collisionFrames_1            = 32'h0000_0000;
    collisionFrames_2            = 32'h0000_0000;
    collisionFrames_3            = 32'h0000_0000;
    collisionFrames_4            = 32'h0000_0000;
    collisionFrames_5            = 32'h0000_0000;
    collisionFrames_6            = 32'h0000_0000;
    collisionFrames_7            = 32'h0000_0000;
    collisionFrames_8            = 32'h0000_0000;
    collisionFrames_9            = 32'h0000_0000;
    octetsTransmittedOK          = 32'h0000_0000;
    deferredTransmissions        = 32'h0000_0000;
    multicastFramesTransmittedOK = 32'h0000_0000;
    broadcastFramesTransmittedOK = 32'h0000_0000;

// {MAC transmit error counters}

    lateCollision                = 32'h0000_0000;
    excessiveCollision           = 32'h0000_0000;
    carrierSenseErrors           = 32'h0000_0000;
    excessiveDeferral            = 32'h0000_0000;

end // {LayerMgmtInitialize}
endtask


/*                                                                    */
/* Procedure IncLargeCounter increments a 32-bit wraparound counter.  */
/*                                                                    */

function[31:0] IncLargeCounter; // (var counter: CounterLarge);
input[31:0] counter;
begin
    IncLargeCounter = counter + 1; // {increment the 32-bit counter}
end // {IncLargeCounter}
endfunction

/*                                                                    */
/* Procedure SumLarge adds a value to a 32-bit wraparound counter.    */
/*                                                                    */

function[31:0] SumLarge; // var counter: CounterLarge; var offset: Integer);
input[31:0] counter;
input[15:0] offset;
begin
    SumLarge = counter + offset;
end
endfunction


/* ADDITIONS */
/* ========= */

function address_on_multicast_list;
input[47:0] address;

parameter   multicast_list_length = 256;

reg[47:0]   multicast_list[0:255];
reg[8:0]    multicast_entry;

begin
    address_on_multicast_list = false;

    for(multicast_entry = 0; (multicast_entry < multicast_list_length) && address_on_multicast_list == false; multicast_entry = multicast_entry + 1)
    begin
        if(address === multicast_list[multicast_entry])
        begin
            address_on_multicast_list = true;
        end
        else
        begin
            address_on_multicast_list = false;
        end
    end
end
endfunction


function[71999:0] InsertFCS;
input[71999:0]    outgoingFrame;
input[31:0]       fcsField;

reg[16:0]         length;
reg[5:0]          fcsBit;

begin
    InsertFCS = outgoingFrame;

    for (length = 1; ((length < (9000 * 8)) && (InsertFCS[length] !== UNKNOWN)); length = length + 1);

    for(fcsBit = 0; fcsBit < 32; fcsBit = fcsBit + 1)
    begin
        InsertFCS[length + fcsBit] = fcsField[fcsBit];
    end

end
endfunction


function[31:0] ExtractFCS;
input[71999:0] incomingFrame;
input[16:0]    incomingFrameSize;

reg[5:0]       fcsBit;

begin
    for(fcsBit = 0; fcsBit < 32; fcsBit = fcsBit + 1)
    begin
        ExtractFCS[fcsBit] = incomingFrame[incomingFrameSize - 31 + fcsBit];
        incomingFrame[incomingFrameSize - 31] = 1'bx;
    end
end
endfunction

reg[3:0]  data_rate;
reg[31:0] bitTimeDuration;

always @(data_rate)
begin
    case(data_rate)

    _10M_:
    begin
        bitTimeDuration = 100_000_000; // fs
        rate            = ten_hundred_mbs;
    end

    _100M_:
    begin
        bitTimeDuration = 10_000_000; // fs
        rate            = ten_hundred_mbs;
    end

    _1G_:
    begin
        bitTimeDuration = 1_000_000; // fs
        rate            = one_gbs;
    end

    _2p5G_:
    begin
        bitTimeDuration = 400_000; // fs
        rate            = other_gbs;
    end

    _5G_:
    begin
        bitTimeDuration = 200_000; // fs
        rate            = other_gbs;
    end

    _10G_:
    begin
        bitTimeDuration = 100_000; // fs
        rate            = ten_gbs;
    end

    _25G_:
    begin
        bitTimeDuration = 40_000; // fs
        rate            = other_gbs;
    end

    _40G_:
    begin
        bitTimeDuration = 25_000; // fs
        rate            = other_gbs;
    end

    _100G_:
    begin
        bitTimeDuration = 1_000; // fs
        rate            = other_gbs;
    end

    _200G_:
    begin
        bitTimeDuration = 500; // fs
        rate            = other_gbs;
    end


    _400G_:
    begin
        bitTimeDuration = 250;  // fs
        rate            = other_gbs;
    end

    endcase
end


/*                                                                    */
/* MAC rate                                                           */
/*                                                                    */

reg [1:0]   rate;
reg [543:0] rate_ASCII;

always @(rate)
begin
    casex(rate)
        ten_hundred_mbs : rate_ASCII = "<= 100 Mb/s";
        one_gbs         : rate_ASCII = "1 Gb/s";
        other_gbs       : rate_ASCII = "2.5 Gb/s, 5 Gb/s, 25 Gb/s, 40 Gb/s, 100 Gb/s, 200 Gb/s, and 400 Gb/s";
        ten_gbs         : rate_ASCII = "10 Gb/s";
    endcase
end

reg[191:0] TransmitBit_ASCII;
always @(TransmitBit.bitParam)
begin
    case(TransmitBit.bitParam)
        2'b00   : TransmitBit_ASCII = "zero";
        2'b01   : TransmitBit_ASCII = "one";
        2'b10   : TransmitBit_ASCII = "extensionBit";
        2'b11   : TransmitBit_ASCII = "extensionErrorBit";
        default : TransmitBit_ASCII = "ERROR";
    endcase
end


reg[191:0] TransmitFrame_ASCII;

always @(TransmitFrame.TransmitFrame)
begin
    casex(TransmitFrame.TransmitFrame)
        2'b00 : TransmitFrame_ASCII = "transmitDisabled";
        2'b01 : TransmitFrame_ASCII = "transmitOK";
        2'b10 : TransmitFrame_ASCII = "excessiveCollisionError";
        2'b11 : TransmitFrame_ASCII = "lateCollisionErrorStatus";
    endcase
end


reg[191:0] ReceiveFrame_ASCII;

always @(ReceiveFrame.ReceiveFrame)
begin
    casex(ReceiveFrame.ReceiveFrame)
        3'b000: ReceiveFrame_ASCII = "receiveDisabled";
        3'b001: ReceiveFrame_ASCII = "receiveOK";
        3'b010: ReceiveFrame_ASCII = "frameTooLong";
        3'b011: ReceiveFrame_ASCII = "lengthError";
        3'b100: ReceiveFrame_ASCII = "frameCheckError";
        3'b101: ReceiveFrame_ASCII = "alignmentError";
    endcase
end


endmodule
