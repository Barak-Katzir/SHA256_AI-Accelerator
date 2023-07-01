#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "csr.h"

#define ACCEL_BASE 0x00030000

// Define the calculator module's registers

#define uchar unsigned char
#define uint unsigned int

#define DBL_INT_ADD(a,b,c) if (a > 0xffffffff - (c)) ++b; a += c;
#define ROTLEFT(a,b) (((a) << (b)) | ((a) >> (32-(b))))
#define ROTRIGHT(a,b) (((a) >> (b)) | ((a) << (32-(b))))

#define CH(x,y,z) (((x) & (y)) ^ (~(x) & (z)))
#define MAJ(x,y,z) (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))
#define EP0(x) (ROTRIGHT(x,2) ^ ROTRIGHT(x,13) ^ ROTRIGHT(x,22))
#define EP1(x) (ROTRIGHT(x,6) ^ ROTRIGHT(x,11) ^ ROTRIGHT(x,25))
#define SIG0(x) (ROTRIGHT(x,7) ^ ROTRIGHT(x,18) ^ ((x) >> 3))
#define SIG1(x) (ROTRIGHT(x,17) ^ ROTRIGHT(x,19) ^ ((x) >> 10))

typedef struct {
	uchar data[64];
	uint datalen;
	uint bitlen[2];
	uint state[8];
} SHA256_CTX;

uint k[64] = {
	0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
	0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
	0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
	0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
	0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
	0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
	0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
	0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
};

uint total_num_of_sha256_ops = 0;


void SHA256Init(SHA256_CTX *ctx)
{
	volatile uint32_t* ptr = (volatile uint32_t*)(ACCEL_BASE);
	ctx->datalen = 0;
	ctx->bitlen[0] = 0;
	ctx->bitlen[1] = 0;
	ctx->state[0] = ptr[1];
	ctx->state[1] = ptr[2];
	ctx->state[2] = ptr[3];
	ctx->state[3] = ptr[4];
	ctx->state[4] = ptr[5];
	ctx->state[5] = ptr[6];
	ctx->state[6] = ptr[7];
	ctx->state[7] = ptr[8];
}

void SHA256Transform(SHA256_CTX *ctx, uchar data[])
{
	volatile uint32_t* ptr = (volatile uint32_t*)(ACCEL_BASE);
	volatile uint32_t* tmp_data = (volatile uint32_t *)data;
	volatile uint32_t* ptr_m = (volatile uint32_t*)(&ptr[33]);

	ptr[9] = tmp_data[0];
	ptr[10] = tmp_data[1];
	ptr[11] = tmp_data[2];
	ptr[12] = tmp_data[3];
	ptr[13] = tmp_data[4];
	ptr[14] = tmp_data[5];
	ptr[15] = tmp_data[6];
	ptr[16] = tmp_data[7];
	ptr[17] = tmp_data[8];
	ptr[18] = tmp_data[9];
	ptr[19] = tmp_data[10];
	ptr[20] = tmp_data[11];
	ptr[21] = tmp_data[12];
	ptr[22] = tmp_data[13];
	ptr[23] = tmp_data[14];
	ptr[24] = tmp_data[15];
	ptr[0] = 0x1;

	uint a, b, c, d, e, f, g, h, i, j, t1, t2, m[64];

	a = ctx->state[0];
	b = ctx->state[1];
	c = ctx->state[2];
	d = ctx->state[3];
	e = ctx->state[4];
	f = ctx->state[5];
	g = ctx->state[6];
	h = ctx->state[7];

	for (i = 0; i < 64; ++i) {
		t1 = h + EP1(e) + CH(e, f, g) + k[i] + ptr[i+33];
		t2 = EP0(a) + MAJ(a, b, c);
		h = g;
		g = f;
		f = e;
		e = d + t1;
		d = c;
		c = b;
		b = a;
		a = t1 + t2;
	}

	ctx->state[0] += a;
	ctx->state[1] += b;
	ctx->state[2] += c;
	ctx->state[3] += d;
	ctx->state[4] += e;
	ctx->state[5] += f;
	ctx->state[6] += g;
	ctx->state[7] += h;
    //****** Do not remove this/modify code ******
	total_num_of_sha256_ops++;
    //****** End of do not remove/modify this code ******
}

void SHA256Update(SHA256_CTX *ctx, uchar data[], uint len)
{
	for (uint i = 0; i < len; ++i) {
		ctx->data[ctx->datalen] = data[i];
		ctx->datalen++;
		if (ctx->datalen == 64) {
			SHA256Transform(ctx, ctx->data);
			DBL_INT_ADD(ctx->bitlen[0], ctx->bitlen[1], 512);
			ctx->datalen = 0;
		}
	}
}

void SHA256Final(SHA256_CTX *ctx, uchar hash[])
{
	uint i = ctx->datalen;

	if (ctx->datalen < 56) {
		ctx->data[i++] = 0x80;
		while (i < 56)
			ctx->data[i++] = 0x00;
	}
	else {
		ctx->data[i++] = 0x80;
		while (i < 64)
			ctx->data[i++] = 0x00;
		SHA256Transform(ctx, ctx->data);
		memset(ctx->data, 0, 56);
	}

	DBL_INT_ADD(ctx->bitlen[0], ctx->bitlen[1], ctx->datalen * 8);
	ctx->data[63] = ctx->bitlen[0];
	ctx->data[62] = ctx->bitlen[0] >> 8;
	ctx->data[61] = ctx->bitlen[0] >> 16;
	ctx->data[60] = ctx->bitlen[0] >> 24;
	ctx->data[59] = ctx->bitlen[1];
	ctx->data[58] = ctx->bitlen[1] >> 8;
	ctx->data[57] = ctx->bitlen[1] >> 16;
	ctx->data[56] = ctx->bitlen[1] >> 24;
	SHA256Transform(ctx, ctx->data);

	for (i = 0; i < 4; ++i) {
		hash[i] = (ctx->state[0] >> (24 - i * 8)) & 0x000000ff;
		hash[i + 4] = (ctx->state[1] >> (24 - i * 8)) & 0x000000ff;
		hash[i + 8] = (ctx->state[2] >> (24 - i * 8)) & 0x000000ff;
		hash[i + 12] = (ctx->state[3] >> (24 - i * 8)) & 0x000000ff;
		hash[i + 16] = (ctx->state[4] >> (24 - i * 8)) & 0x000000ff;
		hash[i + 20] = (ctx->state[5] >> (24 - i * 8)) & 0x000000ff;
		hash[i + 24] = (ctx->state[6] >> (24 - i * 8)) & 0x000000ff;
		hash[i + 28] = (ctx->state[7] >> (24 - i * 8)) & 0x000000ff;
	}
}



void SHA256(char* data) {
	int strLen = strlen(data);
	SHA256_CTX ctx;
	unsigned char hash[32];

	SHA256Init(&ctx);
	SHA256Update(&ctx, data, strLen);
	SHA256Final(&ctx, hash);

	char s[3];
	for (int i = 0; i < 32; i++) printf("%02x", hash[i]);
	printf("\n");

}

int main(void)
{

	//#define ACCEL_GO_REG (*(volatile uint32_t *)(ACCEL_BASE))
	volatile uint32_t* ptr = (volatile uint32_t*)(ACCEL_BASE);
    unsigned int mcycle_l_start, mcycle_h_start;
    unsigned int mcycle_l_end, mcycle_h_end;
    unsigned int total_time_l, total_time_h;
    char secrets[20][256] = {
	"I used to play piano by ear, but now I use my hands.",
	"Why don't scientists trust atoms? Because they make up everything.",
	"I'm reading a book about anti-gravity. It's impossible to put down.",
	"I told my wife she was drawing her eyebrows too high. She looked surprised.",
	"Why do seagulls fly over the sea? Because if they flew over the bay, they'd be bagels!",
	"I have a photographic memory, but I always forget to bring the film.",
	"I used to be a baker, but I couldn't raise the dough.",
	"I'm reading a book on the history of glue. I just can't seem to put it down.",
	"Why don't oysters give to charity? Because they're shellfisha!",
	"I told my wife she was overreacting. She just rolled her eyes and left the room.",
	"I'm addicted to brake fluid, but I can stop anytime.",
	"Why don't scientists trust atoms? Because they're always up to something.",
	"I used to be indecisive, but now I'm not sure.",
	"I'm a huge fan of whiteboards. They're re-markable.",
	"Why don't skeletons fight each other? They don't have the guts.",
	"I'm not lazy, I'm just on energy-saving mode.",
	"Why don't ants get sick? Because they have tiny ant-bodies!",
	"The future, the present, and the past walked into a bar. It was tense.",
	"Why did the hipster burn his tongue? He drank his coffee before it was cool.",
    "The identity of the creator of Bitcoin, known by the pseudonym Satoshi Nakamoto, is still unknown. While many people have claimed to be Satoshi Nakamoto, no one has been able to conclusively prove their identity, and the true identity remains a mystery."
};
    printf("SHA256 is RUNNING!! \n");

    //****** Do not remove this/modify code ******
    mcycle_l_start = csr_read(0xc00);
    mcycle_h_start = csr_read(0xc80);
    //****** End of do not remove/modify this code ******
    
    for(int i=0; i<20; i++) SHA256(secrets[i]);
	
    //****** Do not remove this/modify code ******
    mcycle_l_end = csr_read(0xc00);
    mcycle_h_end = csr_read(0xc80);
    printf("***************** Performance Summary: ******************\n");
    printf("Start time (hex): \t\t %08x%08x\n", mcycle_h_start, mcycle_l_start);
    printf("End time (hex): \t\t %08x%08x\n", mcycle_h_end, mcycle_l_end);

    if(mcycle_l_end >= mcycle_l_start){
	    total_time_l = mcycle_l_end - mcycle_l_start;
	    total_time_h = mcycle_h_end - mcycle_h_start;
    }
    else{
	    total_time_l = ((unsigned int)0xffffffff - mcycle_l_start) + 1 + mcycle_l_end;
	    total_time_h = mcycle_h_end - mcycle_h_start-1;
    }
    printf("Total time (hex): \t\t %08x%08x\n", total_time_h, total_time_l);
    printf("For Throughput calculation divide %d by total time (hex) %08x%08x\n", total_num_of_sha256_ops, total_time_h, total_time_l);
    //****** End of do not remove/modify this code ******

    return 0;
}
