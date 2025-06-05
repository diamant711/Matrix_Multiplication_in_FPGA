#include "double_composer.h"

double compose_double(const uint8_t sign, const uint64_t exponent, const uint64_t mantissa)
{
    // Compose the result
    conversion result = {.d = 0.0};

    result.u |= ((uint64_t)(sign) << SIGN_SHIFT);
    assert(((result.u & (EXPONENT_MASK | MANTISSA_MASK)) == 0) && "Error setting sign\n");

    result.u |= (exponent << EXPONENT_SHIFT);
    assert(((result.u & (MANTISSA_MASK)) == 0) && "Error setting exponent\n");

    result.u |= (mantissa & MANTISSA_MASK);

    return result.d;
}

uint64_t get_mantissa(const double value)
{
    conversion conv = {.d = value};
    conv.u &= MANTISSA_MASK;
    conv.u |= (MANTISSA_MASK + 1); // Set the implicit leading bit for normalized numbers
    return conv.u;
}

uint64_t get_exponent(const double value)
{
    conversion conv = {.d = value};
    conv.u &= EXPONENT_MASK;   // Mask to get the exponent bits
    conv.u >>= EXPONENT_SHIFT; // Shift to get the exponent value
    return conv.u;
}

uint8_t get_sign(const double value)
{
    conversion conv = {.d = value};
    return (uint8_t)((conv.u >> SIGN_SHIFT) & 0x01);
}
