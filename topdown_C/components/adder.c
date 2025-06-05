#include "adder.h"

double double_adder(const double a, const double b, const uint8_t subtraction_mode)
{
    uint64_t mantissa_a = get_mantissa(a);
    uint64_t mantissa_b = get_mantissa(b);
    uint64_t exponent_a = get_exponent(a);
    uint64_t exponent_b = get_exponent(b);  
    uint8_t sign_a = get_sign(a);
    uint8_t sign_b = get_sign(b);

    if (subtraction_mode)
    {
        // If subtraction mode is enabled, we need to flip the sign of b
        sign_b ^= 1;
    }

    // Check if the exponents are equal
    int64_t exponent_shift = exponent_a - exponent_b;

    // Normalize exponents to same value
    if (exponent_shift >= 0)
    {
        mantissa_b >>= exponent_shift;
    }
    else
    {
        mantissa_a >>= -exponent_shift;
    }

    if (sign_a == sign_b)
    {
        // If both signs are the same, we add the mantissas
        uint64_t mantissa_result = mantissa_a + mantissa_b;

        // Check if normalization is needed
        if (mantissa_result & 0x8000000000000000) // Check if the result is normalized
        {
            mantissa_result >>= 1; // Normalize by shifting right
            exponent_a += 1; // Increase exponent
        }

        return compose_double(sign_a, exponent_a, mantissa_result);
    }
    else
    {
        // If signs are different, we subtract the smaller mantissa from the larger one
        if (mantissa_a >= mantissa_b)
        {
            uint64_t mantissa_result = mantissa_a - mantissa_b;
            return compose_double(sign_a, exponent_a, mantissa_result);
        }
        else
        {
            uint64_t mantissa_result = mantissa_b - mantissa_a;
            return compose_double(sign_b, exponent_b, mantissa_result);
        }
    }


    return 0.0;
}