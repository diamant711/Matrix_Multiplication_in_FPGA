#include "debug_function.h"

void print_uint128_bin(const __uint128_t value) {
    for (int i = 127; i >= 0; i--) {
        int bit = (value >> i) & 1;
        putchar(bit ? '1' : '0');
    }
    return;
}

void print_uint64_bin(const uint64_t value) {
    for (int i = 63; i >= 0; i--) putchar(' ');
    for (int i = 63; i >= 0; i--) {
        int bit = (value >> i) & 1;
        putchar(bit ? '1' : '0');
    }
    return;
}

void print_uint8_bin(const uint8_t value) {
    for (int i = 119; i >= 0; i--) putchar(' ');
    for (int i = 7; i >= 0; i--) {
        int bit = (value >> i) & 1;
        putchar(bit ? '1' : '0');
    }
    return;
}

void print_uint128_hex(const __uint128_t value)
{
    for (int i = 31; i >= 0; i--) {
        printf("%x", (unsigned int)(value >> (i * 4)) & 0xF);
    }
}

void print_uint64_hex(const uint64_t value)
{
    for (int i = 15; i >= 0; i--) {
        printf("%x", (unsigned int)(value >> (i * 4)) & 0xF);
    }
}

void print_uint8_hex(const uint8_t value)
{
    for (int i = 1; i >= 0; i--) {
        printf("%x", (unsigned int)(value >> (i * 4)) & 0xF);
    }
}

void print_bin(const void* value, print_bin_mode_t mode) {
    switch (mode) {
        case UINT128:
          print_uint128_bin(*((__uint128_t*) value));
        break;
        case UINT64:
          print_uint64_bin(*((uint64_t*) value));
        break;
        case UINT8:
          print_uint8_bin(*((uint8_t*) value));
        break;
        default:
            assert(mode == UINT8 && "mode selection undefined");
        break;
    }
    return;
}

void print_hex(const void* value, print_bin_mode_t mode) {
    switch (mode) {
        case UINT128:
          print_uint128_hex(*((__uint128_t*) value));
          return;
        case UINT64:
          print_uint64_hex(*((uint64_t*) value));
          return;
        case UINT8:
          print_uint8_hex(*((uint8_t*) value));
          return;
        default:
            assert(mode == UINT8 && "mode selection undefined");
        break;
    }
    return;
}
