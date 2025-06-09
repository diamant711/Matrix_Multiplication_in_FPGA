#pragma once

#include <stdint.h>
#include <assert.h>
#include <stdio.h>

#include "debug_function.h"

#define MANTISSA_MASK (0x000FFFFFFFFFFFFF)
#define EXPONENT_MASK (0x7FF0000000000000)
#define EXPONENT_SHIFT (52)
#define BIAS ((1 << 10) - 1) // 11 bits for exponent, so bias is  1023 = 1024 - 1
#define SIGN_SHIFT (63)

typedef union  {
    double d;
    uint64_t u;
} conversion;

uint64_t get_mantissa(const double value);
uint64_t get_exponent(const double value);
uint8_t get_sign(const double value);

double compose_double(const uint8_t sign, const uint64_t exponent, const uint64_t mantissa);
