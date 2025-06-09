#pragma once

#include<stdint.h>
#include<stdio.h>
#include<assert.h>

typedef enum {
    UINT128,
    UINT64,
    UINT8
} print_bin_mode_t;

void print_uint128_bin(const __uint128_t value);
void print_uint64_bin(const uint64_t value);
void print_uint8(const uint8_t value);

void print_uint128_hex(const __uint128_t value);
void print_uint64_hex(const uint64_t value);
void print_uint8(const uint8_t value);

void print_bin(const void*, print_bin_mode_t);
void print_hex(const void*, print_bin_mode_t);
