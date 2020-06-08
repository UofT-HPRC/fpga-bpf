//Copyright 2020 Juan Camilo Vega. This file is part of the fpga-bpf 
//project, whose license information can be found at 
//https://github.com/UofT-HPRC/fpga-bpf/blob/master/LICENSE

#include "hls_stream.h"
#include "ap_int.h"
#include "ap_utils.h"

struct dataword_ext
{
	ap_uint<512> data;
	ap_uint<64> keep;
	ap_uint<1> last;
};

struct dataword
{
	ap_uint<64> data;
	ap_uint<8> keep;
	ap_uint<1> last;
};

void compressor_(
	hls::stream<dataword_ext> data_in,
	hls::stream<dataword> data_out
)
{
#pragma HLS DATAFLOW

#pragma HLS INTERFACE ap_ctrl_none port=return

#pragma HLS resource core=AXI4Stream variable = data_in
#pragma HLS DATA_PACK variable=data_in

#pragma HLS resource core=AXI4Stream variable = data_out
#pragma HLS DATA_PACK variable=data_out

	static ap_uint<8> stage = 0;
	static dataword_ext ext_inst;
	dataword norm_inst;
	switch (stage)
	{
	case 0:
		if (!data_in.empty())
		{
			ext_inst = data_in.read();
			norm_inst.data = ext_inst.data.range(511,448);
			if (ext_inst.keep.range(63,48)>0xFF00)
			{
				stage = 1;
				norm_inst.keep=0xff;
				norm_inst.last=0;
			}
			else
			{
				norm_inst.keep = ext_inst.keep.range(63,56);
				norm_inst.last = ext_inst.last;
				stage = 0;
			}
			data_out.write(norm_inst);
		}
		break;
	case 1:
		norm_inst.data = ext_inst.data.range(447,384);
		if (ext_inst.keep.range(55,40)>0xFF00)
		{
			stage = 2;
			norm_inst.keep=0xff;
			norm_inst.last=0;
		}
		else
		{
			norm_inst.keep = ext_inst.keep.range(55,48);
			norm_inst.last = ext_inst.last;
			stage = 0;
		}
		data_out.write(norm_inst);
		break;
	case 2:
		norm_inst.data = ext_inst.data.range(383,320);
		if (ext_inst.keep.range(47,32)>0xFF00)
		{
			stage = 3;
			norm_inst.keep=0xff;
			norm_inst.last=0;
		}
		else
		{
			norm_inst.keep = ext_inst.keep.range(47,40);
			norm_inst.last = ext_inst.last;
			stage = 0;
		}
		data_out.write(norm_inst);
		break;
	case 3:
		norm_inst.data = ext_inst.data.range(319,256);
		if (ext_inst.keep.range(39,24)>0xFF00)
		{
			stage = 4;
			norm_inst.keep=0xff;
			norm_inst.last=0;
		}
		else
		{
			norm_inst.keep = ext_inst.keep.range(39,32);
			norm_inst.last = ext_inst.last;
			stage = 0;
		}
		data_out.write(norm_inst);
		break;
	case 4:
		norm_inst.data = ext_inst.data.range(255,192);
		if (ext_inst.keep.range(31,16)>0xFF00)
		{
			stage = 5;
			norm_inst.keep=0xff;
			norm_inst.last=0;
		}
		else
		{
			norm_inst.keep = ext_inst.keep.range(31,24);
			norm_inst.last = ext_inst.last;
			stage = 0;
		}
		data_out.write(norm_inst);
		break;
	case 5:
		norm_inst.data = ext_inst.data.range(191,128);
		if (ext_inst.keep.range(23,8)>0xFF00)
		{
			stage = 6;
			norm_inst.keep=0xff;
			norm_inst.last=0;
		}
		else
		{
			norm_inst.keep = ext_inst.keep.range(23,16);
			norm_inst.last = ext_inst.last;
			stage = 0;
		}
		data_out.write(norm_inst);
		break;
	case 6:
		norm_inst.data = ext_inst.data.range(127,64);
		if (ext_inst.keep.range(15,0)>0xFF00)
		{
			stage = 7;
			norm_inst.keep=0xff;
			norm_inst.last=0;
		}
		else
		{
			norm_inst.keep = ext_inst.keep.range(15,8);
			norm_inst.last = ext_inst.last;
			stage = 0;
		}
		data_out.write(norm_inst);
		break;
	case 7:
		stage = 0;
		norm_inst.data = ext_inst.data.range(63,0);
		norm_inst.keep = ext_inst.keep.range(7,0);
		norm_inst.last = ext_inst.last;
		data_out.write(norm_inst);
		break;
	}
}
