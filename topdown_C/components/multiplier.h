#pragma once

#include <stdint.h>
#include <assert.h>

#include "double_composer.h"

double multiplier(const double a, const double b);


uint64_t multiply_mantissa(const uint64_t mantissa_a, const uint64_t mantissa_b, uint8_t *normalization_needed);
uint64_t add_exponents(const uint64_t exponent_a, const uint64_t exponent_b);

__uint128_t bitwise_adder_multiplication(const __uint128_t a, const __uint128_t b, __uint128_t *carry );
