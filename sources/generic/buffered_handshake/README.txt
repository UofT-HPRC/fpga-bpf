===============================
WHAT IS "BUFFERED HANDSHAKING"?
===============================

This is a term I learned from Dan Gisselquist:

    https://zipcpu.com/blog/2017/08/14/strategies-for-pipelining.html

Some friends of mine mentioned that they learned a similar technique in their 
undergrad comp arch class. However, a Google search for "buffered handshake" 
doesn't turn up anything other than the article I just linked, so the technique 
must have a different name elsewhere.

Basically, when you have a pipelined design that needs to handle backpressure, 
you need a way to propagate that pressure backwards. If you're not careful and 
just have a global (i.e. combinational) ready signal, then you can fail timing. 
Buffered handshaking is a way of addressing this problem.

Note: this is exactly the same thing as an AXI Stream register slice in one of 
the modes you can choose.

=======
DETAILS
=======

The general idea is something like this: we will delay data and valid in the 
forward direction, and delay ready in the backward direction:

          +-----------+        +-----------+        +-----------+        
  ------->|data   data|------->|data   data|------->|data   data|------->
  ------->|vld     vld|------->|vld     vld|------->|vld     vld|------->
  <-------|rdy     rdy|<-------|rdy     rdy|<-------|rdy     rdy|<-------
          |>          |        |>          |        |>          |        
          +-----------+        +-----------+        +-----------+        
                A                    B                    C

Here's the problem: consider stage B. If its RHS ready goes low, it will take 
one cycle before its LHS ready goes low. That means that B needs a _second 
register_ in order to save the incoming data _without overwriting_ the data 
that is already inside it.

The next few plates (mostly copied from Dan Gisselquist's article and converted 
to use ready+valid signalling) will illustrate the general idea. 


------------------------------------------------ +-----------------------------------------+
                                                 | Legend                                  |
t = 0: Initial state. The value "a" is input.    |-----------------------------------------|
                                                 |                                         |
             +-+      +-+      +-+               |      +-----------------------+          |
             | |      | |      | |               |      |Data saved in extra reg|          |
    +-+ ---> |-|      |-|      |-|               | ---> |-----------------------| ---> vld |
    |a| <--- | | <--- | | <--- | | <---          | <--- |Data for this stage    | <--- rdy |
    +-+      +-+      +-+      +-+               |      +-----------------------+          |
   Input      1        2        3                |                                         |
                                                 | If arrow is present, signal is asserted |
------------------------------------------------ +-----------------------------------------+
t = 1: "a" was accepted, and "b" is input.    

             +-+      +-+      +-+
             | |      | |      | |
    +-+ ---> |-| ---> |-|      |-|     
    |b| <--- |a| <--- | | <--- | | <---
    +-+      +-+      +-+      +-+
   Input      1        2        3
------------------------------------------------------------------------------ 
t = 2: "b" was accepted, and "c" is input.

             +-+      +-+      +-+
             | |      | |      | |
    +-+ ---> |-| ---> |-| ---> |-|     
    |c| <--- |b| <--- |a| <--- | | <---
    +-+      +-+      +-+      +-+
   Input      1        2        3
------------------------------------------------------------------------------ 
t = 3: "c" was accepted, and "d" is input. Because RHS ready and valid are 
high, the value "a" will be output on this cycle.

             +-+      +-+      +-+
             | |      | |      | |
    +-+ ---> |-| ---> |-| ---> |-| --->
    |d| <--- |c| <--- |b| <--- |a| <---
    +-+      +-+      +-+      +-+
   Input      1        2        3
------------------------------------------------------------------------------ 
t = 3: "d" was accepted, and "e" is input. RHS ready went low, so "b" will not 
be output. However, note that stage 3's ready is still high; this means c must 
be saved, since stage 2 will discard it on this cycle.

             +-+      +-+      +-+
             | |      | |      | |
    +-+ ---> |-| ---> |-| ---> |-| --->
    |e| <--- |d| <--- |c| <--- |b|     
    +-+      +-+      +-+      +-+
   Input      1        2        3
------------------------------------------------------------------------------ 
t = 4: "e" was accepted, and "f" is input. RHS ready still low, so "b" will not 
be output. Now, the low ready signal has propagated backwards through stage 3, 
so "d" will not be read. However, note that stage 2's ready is still high; this 
means e must be saved, since stage 1 will discard it on this cycle. 

             +-+      +-+      +-+
             | |      | |      |c|
    +-+ ---> |-| ---> |-| ---> |-| --->
    |f| <--- |e| <--- |d|      |b|     
    +-+      +-+      +-+      +-+
   Input      1        2        3
------------------------------------------------------------------------------ 
t = 5: "f" was accepted, and "g" is input. RHS ready went high again, so "b" 
will be output. Now, the low ready signals have propagated backwards through 
stages 2 and 3, so "d" and "f" will not be read. However, note that stage 1's 
ready is still high; this means g must be saved, since the input will discard 
it on this cycle. 

             +-+      +-+      +-+
             | |      |e|      |c|
    +-+ ---> |-| ---> |-| ---> |-| --->
    |g| <--- |f|      |d|      |b| <---
    +-+      +-+      +-+      +-+
   Input      1        2        3
------------------------------------------------------------------------------ 
t = 6: "g" was accepted, and "h" is input. RHS ready is still high, so "c" will 
be output. Now, the low ready signals have propagated backwards through stages 
1 and 2, so "f" and "h" will not be read. At this point, the input side is 
receiving backpressure. 

             +-+      +-+      +-+
             |g|      |e|      | |
    +-+ ---> |-| ---> |-| ---> |-| --->
    |h|      |f|      |d| <--- |c| <---
    +-+      +-+      +-+      +-+
   Input      1        2        3
------------------------------------------------------------------------------ 
t = 7: RHS ready is still high, so "d" will be output. The low ready signals 
have propagated backwards through stages 1 and 2, so "f" and "h" will not be 
read. At this point, the input side is receiving backpressure. 

             +-+      +-+      +-+
             |g|      | |      | |
    +-+ ---> |-| ---> |-| ---> |-| --->
    |h|      |f| <--- |e| <--- |d| <---
    +-+      +-+      +-+      +-+
   Input      1        2        3
------------------------------------------------------------------------------ 
t = 8: RHS ready is still high, so "d" will be output. All the low ready 
signals have "bubbled out" of the pipeline, and we're back to normal operation. 
Note that the output ready was low for two cycles, and (after a delay) the 
input was also low for two cycles. This is no accident.

             +-+      +-+      +-+
             | |      | |      | |
    +-+ ---> |-| ---> |-| ---> |-| --->
    |h| <--- |g| <--- |f| <--- |e| <---
    +-+      +-+      +-+      +-+
   Input      1        2        3
------------------------------------------------------------------------------ 


==============
IMPLEMENTATION
==============

A buffered handshake can really be thought of as a two-element FIFO:

         +-----------+
 ------->|data   data|------>
 ------->|vld     vld|------>
 <-------|rdy     rdy|<------
         |>          |
         +-----------+

A good question is "why can't we use a one-element FIFO?" The answer is because 
a one-element FIFO will have a combinational path between the right-hand ready 
signal and the left-hand ready signal. This happens when the FIFO is full: if 
the output side is ready (meaning the FIFO's value will be read on this cycle), 
then the input side is ready (meaning a new value can enter), but if the output 
side is not ready, then the input side is not ready.

    That explanation is not 100% complete: you could make the same argument 
    about a two-element FIFO as well (i.e. when it is full, a combinational 
    path exists between right-side ready and left-side ready). We actually do 
    not permit a write into the FIFO when it is full _even if a value will exit 
    on this cycle_. 
        
        One last thing: why can't we do this with a one-element FIFO (i.e. 
        disallow inputting when full)? You can, but then it is impossible to 
        maintain line rate, since the single element will have to be filled and 
        emptied for every data beat.

Because of the (small) fixed FIFO size, we don't need to keep track of read and 
write pointers. Instead, we'll do something a little more ad-hoc: start by 
making a one-element FIFO and add a few things until we're done.

One-element FIFO
----------------

This is about as simple as I can make it:

    module fifo_single (
        input wire clk,
        
        input wire [7:0] idata,
        input wire idata_vld,
        output wire idata_rdy,
        
        output wire [7:0] odata,
        output wire odata_vld,
        input wire odata_rdy
    );

        //Some helper signals for neatening up the code
        wire shift_in;
        assign shift_in = idata_vld && idata_rdy;
        
        wire shift_out;
        assign shift_out = odata_vld && odata_rdy;
        
        
        
        //Internal registers and signals for FIFO element
        reg [7:0] mem = 0;
        reg mem_vld = 0;
        wire mem_rdy;
        
        //We are ready if FIFO is empty, or if the value is leaving on this cycle
        assign mem_rdy = !mem_vld || (odata_vld && odata_rdy);
        
        //We will enable writing into mem if it is ready, and if the input is valid
        wire mem_en;
        assign mem_en = mem_rdy && idata_vld;
        
        always @(posedge clk) begin
            //mem's next value
            if (mem_en) begin
                mem <= idata;
            end
            
            //mem_vld's next value
            if (mem_en) begin
                mem_vld <= 1;
            end else if (shift_out) begin
                mem_vld <= 0;
            end
        end
        
        
        
        //Actually wire up module outputs
        assign idata_rdy = mem_rdy;
        assign odata = mem;
        assign odata_vld = mem_vld;
        
    endmodule

Verilog is so hard to read... I'm not really sure what to do about it...


Converting into a buffered handshake
------------------------------------

We're pretty much already finished. We only need to make four changes:

    - Add a second FIFO element
    - Load second element when original element is full
    - Allow loading the original element from the second element (when needed)
    - Calculate the idata_rdy signal based on whether the extra register is free

The text below is the buffered handshake module. Lines beginning with '#' are 
modifications of the fifo_single module, and lines beginning with '>' are 
additions. (Note: a two-column diff is provided below; this is only here in 
case you prefer using a narrow screen)

   #module buffered_handshake (
           input wire clk,
           
           input wire [7:0] idata,
           input wire idata_vld,
           output wire idata_rdy,
           
           output wire [7:0] odata,
           output wire odata_vld,
           input wire odata_rdy
    );
   
        //Some helper signals for neatening up the code
        wire shift_in;
        assign shift_in = idata_vld && idata_rdy;

        wire shift_out;
        assign shift_out = odata_vld && odata_rdy;
           
           
           
   >    //Forward-declare this signal since extra_mem needs it
   >    reg mem_vld = 0;
   >    
   >    
   >    
   >    //Internal registers and signals for extra element
   >    reg [7:0] extra_mem = 0;
   >    reg extra_mem_vld = 0;
   >    wire extra_mem_rdy;
   >    
   >    //Unlike a regular FIFO, we are only ready if empty:
   >    assign extra_mem_rdy = (extra_mem_vld == 0);
   >    
   >    //We will enable writing into extra mem if a new element is shifting in AND
   >    //mem is full AND mem will not be read on this cycle
   >    wire extra_mem_en;
   >    assign extra_mem_en = shift_in && mem_vld && !shift_out;
   >    
   >    always @(posedge clk) begin
   >        //extra_mem's next value
   >        if (extra_mem_en) begin
   >            extra_mem <= idata;
   >        end
   >        
   >        //extra_mem_vld's next value
   >        if (extra_mem_en) begin
   >            extra_mem_vld <= 1;
   >        end else if (shift_out) begin
   >            extra_mem_vld <= 0;
   >        end
   >    end
   >    
   >    
   >    
        //Internal registers and signals for FIFO element
        reg [7:0] mem = 0;
   #    //reg mem_vld = 0; //moved
        wire mem_rdy;

        //We are ready if FIFO is empty, or if the value is leaving on this cycle
        assign mem_rdy = !mem_vld || (odata_vld && odata_rdy);

        //We will enable writing into mem if it is ready, and if the input is valid
        wire mem_en;
   #    assign mem_en = mem_rdy && (idata_vld || extra_mem_vld);
           
        always @(posedge clk) begin
            //mem's next value
            if (mem_en) begin
   #            mem <= extra_mem_vld ? extra_mem : idata;
            end
               
            //mem_vld's next value
            if (mem_en) begin
                mem_vld <= 1;
            end else if (shift_out) begin
                mem_vld <= 0;
            end
        end
           
           
           
        //Actually wire up module outputs
   #    assign idata_rdy = extra_mem_rdy;
        assign odata = mem;
        assign odata_vld = mem_vld;
       
    endmodule






As promised, here is the two-column diff:

    module fifo_single (                                                                #  module buffered_handshake (
        input wire clk,                                                                  
                                                                                         
        input wire [7:0] idata,                                                          
        input wire idata_vld,                                                            
        output wire idata_rdy,                                                           
                                                                                         
        output wire [7:0] odata,                                                         
        output wire odata_vld,                                                           
        input wire odata_rdy                                                             
    );                                                                                   
                                                                                         
        //Some helper signals for neatening up the code                                  
        wire shift_in;                                                                   
        assign shift_in = idata_vld && idata_rdy;                                        
                                                                                         
        wire shift_out;                                                                  
        assign shift_out = odata_vld && odata_rdy;                                       
                                                                                         
                                                                                         
                                                                                         
                                                                                        >      //Forward-declare this signal since extra_mem needs it
                                                                                        >      reg mem_vld = 0;
                                                                                        >      
                                                                                        >      
                                                                                        >      
                                                                                        >      //Internal registers and signals for extra element
                                                                                        >      reg [7:0] extra_mem = 0;
                                                                                        >      reg extra_mem_vld = 0;
                                                                                        >      wire extra_mem_rdy;
                                                                                        >      
                                                                                        >      //Unlike a regular FIFO, we are only ready if empty:
                                                                                        >      assign extra_mem_rdy = (extra_mem_vld == 0);
                                                                                        >      
                                                                                        >      //We will enable writing into extra mem if a new element is shifting in AND
                                                                                        >      //mem is full AND mem will not be read on this cycle
                                                                                        >      wire extra_mem_en;
                                                                                        >      assign extra_mem_en = shift_in && mem_vld && !shift_out;
                                                                                        >      
                                                                                        >      always @(posedge clk) begin
                                                                                        >          //extra_mem's next value
                                                                                        >          if (extra_mem_en) begin
                                                                                        >              extra_mem <= idata;
                                                                                        >          end
                                                                                        >          
                                                                                        >          //extra_mem_vld's next value
                                                                                        >          if (extra_mem_en) begin
                                                                                        >              extra_mem_vld <= 1;
                                                                                        >          end else if (shift_out) begin
                                                                                        >              extra_mem_vld <= 0;
                                                                                        >          end
                                                                                        >      end
                                                                                        >      
                                                                                        >      
                                                                                        >      
        //Internal registers and signals for FIFO element                                
        reg [7:0] mem = 0;                                                               
        reg mem_vld = 0;                                                                #      //reg mem_vld = 0; //moved
        wire mem_rdy;                                                                    
                                                                                         
        //We are ready if FIFO is empty, or if the value is leaving on this cycle        
        assign mem_rdy = !mem_vld || (odata_vld && odata_rdy);                           
                                                                                         
        //We will enable writing into mem if it is ready, and if the input is valid      
        wire mem_en;                                                                     
        assign mem_en = mem_rdy && idata_vld;                                           #      assign mem_en = mem_rdy && (idata_vld || extra_mem_vld);
                                                                                         
        always @(posedge clk) begin                                                      
            //mem's next value                                                           
            if (mem_en) begin                                                            
                mem <= idata;                                                           #              mem <= extra_mem_vld ? extra_mem : idata;
            end                                                                          
                                                                                         
            //mem_vld's next value                                                       
            if (mem_en) begin                                                            
                mem_vld <= 1;                                                            
            end else if (shift_out) begin                                                
                mem_vld <= 0;                                                            
            end                                                                          
        end                                                                              
                                                                                         
                                                                                         
                                                                                         
        //Actually wire up module outputs                                                
        assign idata_rdy = mem_rdy;                                                     #      assign idata_rdy = extra_mem_rdy;
        assign odata = mem;                                                              
        assign odata_vld = mem_vld;                                                      
                                                                                         
    endmodule                                                                            


=============
COUNTING MODE
=============

One last thing: in some cases, I need to count how many cycles a value has been 
in a pipeline. To do this, I can use almost the exact same code, except every 
time I assign a value to mem or extra_mem, I increment it first (not forgetting 
the case when the value doesn't change!)

So, taking the extra_mem code,

    always @(posedge clk) begin
        //extra_mem's next value
        if (extra_mem_en) begin
            extra_mem <= idata;
        end
    end

we simply change it to say:

    always @(posedge clk) begin
        //extra_mem's next value
        if (extra_mem_en) begin
            extra_mem <= idata + 1;
        end else begin
            extra_mem <= extra_mem + 1;
    end

And similarly for the mem code, take

    always @(posedge clk) begin
        //mem's next value
        if (mem_en) begin
            mem <= extra_mem_vld ? extra_mem : idata;
        end
    end

and change it to

    always @(posedge clk) begin
        //mem's next value
        if (mem_en) begin
            mem <= extra_mem_vld ? extra_mem + 1 : idata + 1;
        end else begin 
            mem <= mem + 1;
        end
    end
