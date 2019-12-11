#include "hls_stream.h"
#include "ap_int.h"
#include "ap_utils.h"
#include "parameter_vals.h"
struct dataword
{
	ap_uint<1024> data;
	ap_uint<128> keep;
	ap_uint<1> last;
};
void chopper(
	hls::stream<dataword> &data_in,
	hls::stream<dataword> &arb_1_out,
#if divisors > 1
	hls::stream<dataword> &arb_2_out,
#if divisors > 2
	hls::stream<dataword> &arb_3_out,
#if divisors > 3
	hls::stream<dataword> &arb_4_out,
#if divisors > 4
	hls::stream<dataword> &arb_5_out,
#if divisors > 5
	hls::stream<dataword> &arb_6_out,
#if divisors > 6
	hls::stream<dataword> &arb_7_out,
#if divisors > 7
	hls::stream<dataword> &arb_8_out,
#if divisors > 8
	hls::stream<dataword> &arb_9_out,
#if divisors > 9
	hls::stream<dataword> &arb_10_out,
#if divisors > 10
	hls::stream<dataword> &arb_11_out,
#if divisors > 11
	hls::stream<dataword> &arb_12_out,
#if divisors > 12
	hls::stream<dataword> &arb_13_out,
#if divisors > 13
	hls::stream<dataword> &arb_14_out,
#if divisors > 14
	hls::stream<dataword> &arb_15_out,
#if divisors > 15
	hls::stream<dataword> &arb_16_out,
#if divisors > 16
	hls::stream<dataword> &arb_17_out,
#if divisors > 17
	hls::stream<dataword> &arb_18_out,
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
	ap_uint<divisors> empty_in,
	ap_uint<divisors> nfull_in
)
{
#pragma HLS DATAFLOW
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS resource core=AXI4Stream variable = data_in
#pragma HLS DATA_PACK variable=data_in
#pragma HLS resource core=AXI4Stream variable = arb_1_out
#pragma HLS DATA_PACK variable=arb_1_out
#if divisors > 1
#pragma HLS resource core=AXI4Stream variable = arb_2_out
#pragma HLS DATA_PACK variable=arb_2_out
#if divisors > 2
#pragma HLS resource core=AXI4Stream variable = arb_3_out
#pragma HLS DATA_PACK variable=arb_3_out
#if divisors > 3
#pragma HLS resource core=AXI4Stream variable = arb_4_out
#pragma HLS DATA_PACK variable=arb_4_out
#if divisors > 4
#pragma HLS resource core=AXI4Stream variable = arb_5_out
#pragma HLS DATA_PACK variable=arb_5_out
#if divisors > 5
#pragma HLS resource core=AXI4Stream variable = arb_6_out
#pragma HLS DATA_PACK variable=arb_6_out
#if divisors > 6
#pragma HLS resource core=AXI4Stream variable = arb_7_out
#pragma HLS DATA_PACK variable=arb_7_out
#if divisors > 7
#pragma HLS resource core=AXI4Stream variable = arb_8_out
#pragma HLS DATA_PACK variable=arb_8_out
#if divisors > 8
#pragma HLS resource core=AXI4Stream variable = arb_9_out
#pragma HLS DATA_PACK variable=arb_9_out
#if divisors > 9
#pragma HLS resource core=AXI4Stream variable = arb_10_out
#pragma HLS DATA_PACK variable=arb_10_out
#if divisors > 10
#pragma HLS resource core=AXI4Stream variable = arb_11_out
#pragma HLS DATA_PACK variable=arb_11_out
#if divisors > 11
#pragma HLS resource core=AXI4Stream variable = arb_12_out
#pragma HLS DATA_PACK variable=arb_12_out
#if divisors > 12
#pragma HLS resource core=AXI4Stream variable = arb_13_out
#pragma HLS DATA_PACK variable=arb_13_out
#if divisors > 13
#pragma HLS resource core=AXI4Stream variable = arb_14_out
#pragma HLS DATA_PACK variable=arb_14_out
#if divisors > 14
#pragma HLS resource core=AXI4Stream variable = arb_15_out
#pragma HLS DATA_PACK variable=arb_15_out
#if divisors > 15
#pragma HLS resource core=AXI4Stream variable = arb_16_out
#pragma HLS DATA_PACK variable=arb_16_out
#if divisors > 16
#pragma HLS resource core=AXI4Stream variable = arb_17_out
#pragma HLS DATA_PACK variable=arb_17_out
#if divisors > 17
#pragma HLS resource core=AXI4Stream variable = arb_18_out
#pragma HLS DATA_PACK variable=arb_18_out
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
	ap_uint<18> empty = empty_in;
	ap_uint<18> nfull = nfull_in;
	static ap_uint<18> empty_bf=0x3FFFF;
	static ap_uint<8> arb = 0;
	dataword data_inst;
	if (!data_in.empty())
	{
		switch (arb)
		{
		case 0:
			if (!arb_1_out.full() && (empty_bf.bit(0)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 1;
				arb_1_out.write(data_inst);
			}
#if divisors > 1
			else if (!arb_2_out.full() && (empty_bf.bit(1)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 2;
				arb_2_out.write(data_inst);
			}
#if divisors > 2
			else if (!arb_3_out.full() && (empty_bf.bit(2)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 3;
				arb_3_out.write(data_inst);
			}
#if divisors > 3
			else if (!arb_4_out.full() && (empty_bf.bit(3)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 4;
				arb_4_out.write(data_inst);
			}
#if divisors > 4
			else if (!arb_5_out.full() && (empty_bf.bit(4)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 5;
				arb_5_out.write(data_inst);
			}
#if divisors > 5
			else if (!arb_6_out.full() && (empty_bf.bit(5)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 6;
				arb_6_out.write(data_inst);
			}
#if divisors > 6
			else if (!arb_7_out.full() && (empty_bf.bit(6)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 7;
				arb_7_out.write(data_inst);
			}
#if divisors > 7
			else if (!arb_8_out.full() && (empty_bf.bit(7)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 8;
				arb_8_out.write(data_inst);
			}
#if divisors > 8
			else if (!arb_9_out.full() && (empty_bf.bit(8)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 9;
				arb_9_out.write(data_inst);
			}
#if divisors > 9
			else if (!arb_10_out.full() && (empty_bf.bit(9)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 10;
				arb_10_out.write(data_inst);
			}
#if divisors > 10
			else if (!arb_11_out.full() && (empty_bf.bit(10)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 11;
				arb_11_out.write(data_inst);
			}
#if divisors > 11
			else if (!arb_12_out.full() && (empty_bf.bit(11)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 12;
				arb_12_out.write(data_inst);
			}
#if divisors > 12
			else if (!arb_13_out.full() && (empty_bf.bit(12)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 13;
				arb_13_out.write(data_inst);
			}
#if divisors > 13
			else if (!arb_14_out.full() && (empty_bf.bit(13)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 14;
				arb_14_out.write(data_inst);
			}
#if divisors > 14
			else if (!arb_15_out.full() && (empty_bf.bit(14)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 15;
				arb_15_out.write(data_inst);
			}
#if divisors > 15
			else if (!arb_16_out.full() && (empty_bf.bit(15)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 16;
				arb_16_out.write(data_inst);
			}
#if divisors > 16
			else if (!arb_17_out.full() && (empty_bf.bit(16)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 17;
				arb_17_out.write(data_inst);
			}
#if divisors > 17
			else if (!arb_18_out.full() && (empty_bf.bit(17)))
			{
				data_inst=data_in.read();
				arb= (data_inst.last==1) ? 0 : 18;
				arb_18_out.write(data_inst);
			}
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
			break;
		case 1:
			if (!arb_1_out.full())
			{
				data_inst=data_in.read();
				arb_1_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 1;
			}
			break;
#if divisors > 1
		case 2:
			if (!arb_2_out.full())
			{
				data_inst=data_in.read();
				arb_2_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 2;
			}
			break;
#if divisors > 2
		case 3:
			if (!arb_3_out.full())
			{
				data_inst=data_in.read();
				arb_3_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 3;
			}
			break;
#if divisors > 3
		case 4:
			if (!arb_4_out.full())
			{
				data_inst=data_in.read();
				arb_4_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 4;
			}
			break;
#if divisors > 4
		case 5:
			if (!arb_5_out.full())
			{
				data_inst=data_in.read();
				arb_5_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 5;
			}
			break;
#if divisors > 5
		case 6:
			if (!arb_6_out.full())
			{
				data_inst=data_in.read();
				arb_6_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 6;
			}
			break;
#if divisors > 6
		case 7:
			if (!arb_7_out.full())
			{
				data_inst=data_in.read();
				arb_7_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 7;
			}
			break;
#if divisors > 7
		case 8:
			if (!arb_8_out.full())
			{
				data_inst=data_in.read();
				arb_8_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 8;
			}
			break;
#if divisors > 8
		case 9:
			if (!arb_9_out.full())
			{
				data_inst=data_in.read();
				arb_9_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 9;
			}
			break;
#if divisors > 9
		case 10:
			if (!arb_10_out.full())
			{
				data_inst=data_in.read();
				arb_10_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 10;
			}
			break;
#if divisors > 10
		case 11:
			if (!arb_11_out.full())
			{
				data_inst=data_in.read();
				arb_11_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 11;
			}
			break;
#if divisors > 11
		case 12:
			if (!arb_12_out.full())
			{
				data_inst=data_in.read();
				arb_12_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 12;
			}
			break;
#if divisors > 12
		case 13:
			if (!arb_13_out.full())
			{
				data_inst=data_in.read();
				arb_13_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 13;
			}
			break;
#if divisors > 13
		case 14:
			if (!arb_14_out.full())
			{
				data_inst=data_in.read();
				arb_14_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 14;
			}
			break;
#if divisors > 14
		case 15:
			if (!arb_15_out.full())
			{
				data_inst=data_in.read();
				arb_15_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 15;
			}
			break;
#if divisors > 15
		case 16:
			if (!arb_16_out.full())
			{
				data_inst=data_in.read();
				arb_16_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 16;
			}
			break;
#if divisors > 16
		case 17:
			if (!arb_17_out.full())
			{
				data_inst=data_in.read();
				arb_17_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 17;
			}
			break;
#if divisors > 17
		case 18:
			if (!arb_18_out.full())
			{
				data_inst=data_in.read();
				arb_18_out.write(data_inst);
				arb= (data_inst.last==1) ? 0 : 18;
			}
			break;
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
		}
	}
	empty_bf= (empty==0) ? ((nfull==0)?(ap_uint<18> (0x3FFFF)):nfull):empty;
}
