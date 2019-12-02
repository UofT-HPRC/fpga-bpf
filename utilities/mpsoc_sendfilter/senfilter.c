#include <fcntl.h> //open
#include <unistd.h> //close
#include <stdio.h> //printf
#include <stdlib.h> //malloc
#include <stdint.h> //uintN_t
#include <string.h> //perror, sprintf
#include <errno.h> 
#include <sys/mman.h> //mmap

int fd = -1;
void *map_base = MAP_FAILED;

#define PACKETFILTS_BASE 0xA0000000
#define PACKETFILTS_SPAN 0x00012000

int setupMap() {	
	fd = open("/dev/mem", O_RDWR | O_SYNC);
	if (fd == -1) {
		perror("Could not open /dev/mem");
		return -1;
	}
	
	map_base = mmap(0, PACKETFILTS_SPAN, PROT_READ | PROT_WRITE, MAP_SHARED, fd, PACKETFILTS_BASE);
	if (map_base == MAP_FAILED) {
		perror("Could not perform mmap");
		return -1;
	}
	
	return 0;
}

typedef struct {
	uint32_t status;
	uint32_t ctrl;
	uint32_t inst_lo;
	uint32_t inst_hi;
	
	uint8_t unused[0x1000 - 16];
} packetfilt_regmap;

uint32_t fix_endian(uint32_t in, int enable) {
	if (enable == 0) return in;
	union {
		uint32_t val;
		char arr[4];
	} u;

	u.val = in;
	char tmp;
	tmp = u.arr[0];
	u.arr[0] = u.arr[3];
	u.arr[3] = tmp;

	tmp = u.arr[1];
	u.arr[1] = u.arr[2];
	u.arr[2] = tmp;

	return u.val;
}

int main(int argc, char **argv) {
	uint32_t endian_test = 1;
	int enable_fix = 0;
	if (*((char*)&endian_test) == 1) {
		puts("INFO: will apply endianness fix...");
		enable_fix = 1;
	}

	int ret = 0;
	FILE *codefile = NULL;
	void *axigpio = MAP_FAILED;
	char *data = NULL;

	if (argc != 2) {
		puts("Usage: sendfilt FILE");
		ret = -1;
		goto cleanup;
	}
	
	codefile = fopen(argv[1], "rb");
	if (codefile == NULL) {
		char line[80];
		sprintf(line, "Could not open file \"%s\"", argv[1]);
		perror(line);
		ret = -1;
		goto cleanup;
	}
	
	fseek(codefile, 0, SEEK_END);
	int len = ftell(codefile);
	rewind(codefile);
	
	data = malloc(len);
	if (data == NULL) {
		perror("Could not allocate buffer");
		ret = -1;
		goto cleanup;
	}
	fread(data, len, 1, codefile);
	
	if(setupMap() < 0) {
		puts("Aborting...");
		ret = -1;
		goto cleanup;
	}
	
	volatile packetfilt_regmap *filts = (volatile packetfilt_regmap *) map_base;
	
	//Turn off all the packet filters
	int i;
	for (i = 0; i < 4; i++) {
		printf("\t(INFO) Writing 0 to physical address 0x%X\n",
			(((uint64_t)&filts[i].ctrl) - 
			((uint64_t) map_base)) + 
			((uint64_t) PACKETFILTS_BASE)
		);
		filts[i].ctrl = 0;
	}
	
	//Upload code to each packet filter
	for (i = 0; i < 4; i++) {
		uint32_t *words = (uint32_t*) data;
		int j;
		for (j = 0; j < len/8; j+=2) {
			printf("\t(INFO) Writing 0x%08X to physical address 0x%08X\n",
				fix_endian(words[j], enable_fix),
				(((uint64_t)&filts[i].inst_hi) - 
				((uint64_t) map_base)) + 
				((uint64_t) PACKETFILTS_BASE)
			);
			printf("\t(INFO) Writing 0x%08X to physical address 0x%X\n",
				fix_endian(words[j+1], enable_fix),
				(((uint64_t)&filts[i].inst_lo) - 
				((uint64_t) map_base)) + 
				((uint64_t) PACKETFILTS_BASE)
			);
			filts[i].inst_lo = fix_endian(words[j+1], enable_fix);
			filts[i].inst_hi = fix_endian(words[j], enable_fix);
		}
		//filts[i].inst_lo = 0x0000ffff;
		//filts[i].inst_hi = 0x00060000;
	}
	//Re-enable all the packet filters
	for (i = 0; i < 4; i++) {
		printf("\t(INFO) Writing 1s to physical address 0x%X\n",
			(((uint64_t)&filts[i].ctrl) - 
			((uint64_t) map_base)) + 
			((uint64_t) PACKETFILTS_BASE)
		);
		filts[i].ctrl = 0xFFFFFFFF;
	}
	
	/*axigpio = mmap(0, 0x1000, PROT_READ | PROT_WRITE, MAP_SHARED, fd, GPIO_BASE);
	if (axigpio == MAP_FAILED) {
		perror("Could not perform mmap for gpio");
		ret = -1;
		goto cleanup;
	}
	*((volatile uint32_t *) axigpio) = 1; //Enable init signal
	*/
	
	cleanup:
	puts("Cleaning up...");
	if (axigpio != MAP_FAILED) munmap(axigpio, 0x1000);
	if (map_base != MAP_FAILED) munmap(map_base, PACKETFILTS_SPAN);
	if (data != NULL) free(data);
	if (codefile != NULL) fclose(codefile);
	if (fd != -1) close(fd);
	return ret;
}
