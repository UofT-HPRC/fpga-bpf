This module essentially acts as a bridge between an AXI Stream and the modified 
BRAM interface on the packetfilter_core.

Here is a transcription of my paper notes:

Datapath
--------

         Optional delays for
          stricter timing
           +-----------+
           |   +---+   |
TDATA------|-->|D Q|---|---------------------------------->sn_wr_data
           |   |   |   |
           |   |>  |   |
           |   +---+   | +-------------------------------->sn_wr_en
           |   +---+   | |    +----------+
ctrl_vld---|-->|D Q|---|-+--->|inc  count|---------------->sn_wr_addr
           |   |   |   |  +-->|rst       |
           |   |>  |   |  |   |>         |
           |   +---+   |  |   +----------+
           |   +---+   |  |   +-----------------+
TKEEP------|-->|D Q|---|--|-->|     popcount    |--------->sn_byte_inc
           |   |   |   |  |   | (combinational) |
           |   |>  |   |  |   |                 |
           |   +---+   |  |   +-----------------+
           |   +---+   |  |
ctrl_done--|-->|D Q|---|--+------------------------------->sn_done
           |   |   |   |
           |   |>  |   |
           |   +---+   |
           +-----------+

               +-----------------------------+
TVALID-------->|                             |-->ctrl_vld
TREADY-------->|                             |-->ctrl_done
TLAST--------->|        CONTROLLER FSM       |
rdy_for_sn---->|                             |------------>rdy_for_sn_ack
               |                             |
               +-----------------------------+



Controller FSM
--------------

This is technically a Mealy machine, but it was a little easer to draw and to
understand using the traditional Moore machine diagram. You'll see what I mean.

Let L = TLAST, R = rdy_for_sn, and V = (TVALID && TREADY)


 +-------------------+        LR=10  +-------------------+
 |    NOT_STARTED    |<--------------|      STARTED      |
 |-------------------|               |-------------------|
 |ctrl_vld = 0       |   LR=11       |ctrl_vld = V       |------+
 |ctrl_done = 0      |-------------->|ctrl_done = L      | LR=11|
 |rdy_for_sn_ack = 1 |       +------>|rdy_for_sn_ack = L |<-----+
 +-------------------+       |       +-------------------+
          |                  |
          |                  |
          |LR=01             |
          |                  |
          |                  |
          v                  |
 +-------------------+       |
 |      WAITING      |       |
 |-------------------|       |
 |ctrl_vld = 0       |  L=1  |
 |ctrl_done = 0      |-------+
 |rdy_for_sn_ack = 1 |
 +-------------------+
