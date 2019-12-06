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

#define PACKETFILT_SPAN 0x00001000

int setupMap(unsigned long physaddr) {
	if (fd == -1) {
        puts("Error, file descriptor invalid");
        return -1;
    }
    
	map_base = mmap(0, PACKETFILT_SPAN, PROT_READ | PROT_WRITE, MAP_SHARED, fd, physaddr);
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

uint32_t fixendian(uint32_t in, int enable) {
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
	int ret = 0;
	FILE *codefile = NULL;
	char *data = NULL;

	int en_fix = 0;
	uint32_t testendian = 1;
	char c = *((char*)&testendian);
	if (c) {
		//puts("\t(WARN) The machine is little endian. Applying fix...");
		en_fix = 1;
	} else {
		puts("\t(INFO) The machine is big endian");
	}

	if (argc < 3) {
		puts("Usage: sendfilter FILE addr1 [addr2] [addr3] ...");
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
	
    fd = open("/dev/mem", O_RDWR | O_SYNC);
	if (fd == -1) {
		perror("Could not open /dev/mem");
		goto cleanup;
	}
    
	data = malloc(len);
	if (data == NULL) {
		perror("Could not allocate buffer");
		ret = -1;
		goto cleanup;
	}
	fread(data, len, 1, codefile);
	
    int i;
    for (i = 2; i < argc; i++) {
        unsigned long addr = strtoul(argv[i], 0, 0);
        if (addr == 0) {
            printf("Error, could not parse [%s] as an address. Skipping...\n", argv[i]);
            continue;
        }
        if(setupMap(addr) < 0) {
            puts("Aborting...");
            ret = -1;
            goto cleanup;
        }
	
        volatile packetfilt_regmap *filt = (volatile packetfilt_regmap *) map_base;
	
        //Turn off packet filter
        printf("\t(INFO) Writing 0 to physical address 0x%lX\n",
            (((uint64_t)&(filt->ctrl)) - 
            ((uint64_t) map_base)) + 
            ((uint64_t) addr)
        );
        filt->ctrl = 0;
        
        //Upload code to the packet filter
        uint32_t *words = (uint32_t*) data;
        int j;
        for (j = 0; j < len/4; j+=2) {
            filt->inst_lo = fixendian(words[j+1], en_fix);
            filt->inst_hi = fixendian(words[j], en_fix); 
            printf("\t(INFO) Writing %08x to physical address 0x%lX\n", fixendian(words[j], en_fix),
                (((uint64_t)&(filt->inst_hi)) - 
                ((uint64_t) map_base)) + 
                ((uint64_t) addr)
            );
            printf("\t(INFO) Writing %08x to physical address 0x%lX\n", fixendian(words[j+1], en_fix),
                (((uint64_t)&(filt->inst_lo)) - 
                ((uint64_t) map_base)) + 
                ((uint64_t) addr)
            );
        }
        //Re-enable the packet filter
        printf("\t(INFO) Writing 1s to physical address 0x%lX\n",
            (((uint64_t)&(filt->ctrl)) - 
            ((uint64_t) map_base)) + 
            ((uint64_t) addr)
        );
        filt->ctrl = 0xFFFFFFFF;
	}
    
	cleanup:
	puts("Cleaning up...");
	if (map_base != MAP_FAILED) munmap(map_base, PACKETFILT_SPAN);
	if (data != NULL) free(data);
	if (codefile != NULL) fclose(codefile);
	if (fd != -1) close(fd);
	return ret;
}
