#pragma once
#define _USE_MATH_DEFINES

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#include "inner_product.h"
#include "multiplier.h"
#include "debug_function.h"

enum OPERATING_MODE
{
    STANDARD,
    CHECK_MANTISSA,
    CHECK_EXPONENT,
    CHECK_DOUBLE_COMPOSITION
};

void print_operating_mode(enum OPERATING_MODE mode);
void set_operating_mode(enum OPERATING_MODE *mode, const char *arg);

int standard_case();
int check_mantissa_case();
int check_exponent_case();
int check_double_composition_case();
