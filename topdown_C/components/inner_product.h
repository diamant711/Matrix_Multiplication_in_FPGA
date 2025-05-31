#pragma once

#include <stdint.h>
#include <assert.h>

#include "multiplier.h"


// Standard implementation to compare against.
double standard_inner_product(const double *a, const double *b, const uint64_t n);

// Function implementing IEEE 754, to achieve direct comparison with hardware.
double inner_product(const double *a, const double *b, const uint64_t n);


