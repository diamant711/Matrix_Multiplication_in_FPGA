#pragma once

#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <inttypes.h>

#include "debug_function.h"
#include "double_composer.h"

double multiplier(const double a, const double b);
uint64_t multiply_mantissa(const uint64_t mantissa_a, const uint64_t mantissa_b, uint8_t *normalization_needed);
uint64_t add_exponents(const uint64_t exponent_a, const uint64_t exponent_b);
