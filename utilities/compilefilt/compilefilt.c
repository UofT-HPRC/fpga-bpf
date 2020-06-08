//Copyright 2020 Marco Merlini. This file is part of the fpga-bpf project,
//whose license information can be found at 
//https://github.com/UofT-HPRC/fpga-bpf/blob/master/LICENSE

#include <stdio.h>
#include <pcap.h>

int main(int argc, char **argv) {
	uint32_t endian_test = 1;
	int fix_endian = 0;
	if (*((char*)&endian_test) == 1) {
		puts("Little endian! Applying fix...");
		fix_endian = 1;
	}
	FILE *bin_file = fopen("prog.bpf", "wb");
	
	struct bpf_program fp = {0, NULL};
	//char filter_exp[] = "tcp port 100 and 200";
	
	if (argc != 2) {
		puts("Usage: compilefilt FILTER-TEXT");
		return -1;
	}
	
	if(pcap_compile_nopcap(65535, DLT_EN10MB, &fp, argv[1], 1, PCAP_NETMASK_UNKNOWN) < 0) {
		puts("Could not compile program");
	} else {
		//Write bin file
		if (!fix_endian) {
			fwrite(fp.bf_insns, sizeof(fp.bf_insns[0]), fp.bf_len, bin_file);
		}
		for (int i = 0; i < fp.bf_len; i++) {
			printf("%04x%02x%02x%08x\n",
				fp.bf_insns[i].code,
				fp.bf_insns[i].jt,
				fp.bf_insns[i].jf,
				fp.bf_insns[i].k
			);
			if (fix_endian) {
				char fixed[8];
				union {
					uint16_t val;
					char bytes[2];
				} un16;
				union {
					uint32_t val;
					char bytes[4];
				} un32;

				un16.val = fp.bf_insns[i].code;
				un32.val = fp.bf_insns[i].k;
				fixed[0] = un16.bytes[1];
				fixed[1] = un16.bytes[0];
				fixed[2] = fp.bf_insns[i].jt;
				fixed[3] = fp.bf_insns[i].jf;
				fixed[4] = un32.bytes[3];
				fixed[5] = un32.bytes[2];
				fixed[6] = un32.bytes[1];
				fixed[7] = un32.bytes[0];

				fwrite(fixed, 1, 8, bin_file);
			}
		}
	}
	
	fclose(bin_file);
	pcap_freecode(&fp);
	return 0;
}
