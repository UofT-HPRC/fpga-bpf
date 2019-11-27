`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// 'packet_filter' Register Definitions
// Revision: 10
// -----------------------------------------------------------------------------
// Generated on 2019-08-21 at 20:28 (UTC) by airhdl version 2019.07.1
// -----------------------------------------------------------------------------
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
// POSSIBILITY OF SUCH DAMAGE.
// -----------------------------------------------------------------------------

package packet_filter_regs_pkg;

    // Revision number of the 'packet_filter' register map
    localparam PACKET_FILTER_REVISION = 10;

    // Default base address of the 'packet_filter' register map 
    localparam logic [31:0] PACKET_FILTER_DEFAULT_BASEADDR = 32'h00000000;
    
    // Register 'Status'
    localparam logic [31:0] STATUS_OFFSET = 32'h00000000; // address offset of the 'Status' register
    localparam STATUS_NUM_PACKETS_DROPPED_BIT_OFFSET = 0; // bit offset of the 'num_packets_dropped' field
    localparam STATUS_NUM_PACKETS_DROPPED_BIT_WIDTH = 16; // bit width of the 'num_packets_dropped' field
    localparam logic [15:0] STATUS_NUM_PACKETS_DROPPED_RESET = 16'b0000000000000000; // reset value of the 'num_packets_dropped' field
    
    // Register 'Control'
    localparam logic [31:0] CONTROL_OFFSET = 32'h00000004; // address offset of the 'Control' register
    localparam CONTROL_START_BIT_OFFSET = 0; // bit offset of the 'start' field
    localparam CONTROL_START_BIT_WIDTH = 1; // bit width of the 'start' field
    localparam logic [0:0] CONTROL_START_RESET = 1'b0; // reset value of the 'start' field
    
    // Register 'inst_low'
    localparam logic [31:0] INST_LOW_OFFSET = 32'h00000008; // address offset of the 'inst_low' register
    localparam INST_LOW_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam INST_LOW_VALUE_BIT_WIDTH = 32; // bit width of the 'value' field
    localparam logic [31:0] INST_LOW_VALUE_RESET = 32'b00000000000000000000000000000000; // reset value of the 'value' field
    
    // Register 'inst_high'
    localparam logic [31:0] INST_HIGH_OFFSET = 32'h0000000C; // address offset of the 'inst_high' register
    localparam INST_HIGH_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam INST_HIGH_VALUE_BIT_WIDTH = 32; // bit width of the 'value' field
    localparam logic [31:0] INST_HIGH_VALUE_RESET = 32'b00000000000000000000000000000000; // reset value of the 'value' field

endpackage: packet_filter_regs_pkg
