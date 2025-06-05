#include<stdint.h>
#include<stdio.h>
#include<assert.h>

typedef enum {
    UINT128,
    UINT64
} print_bin_mode_t;

void print_uint128_bin(const __uint128_t);
void print_uint64_bin(const uint64_t);
void print_bin(const void*, print_bin_mode_t);
