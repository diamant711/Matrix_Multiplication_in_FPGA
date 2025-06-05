#include "multiplier.h"

double multiplier(const double a, const double b)
{
    uint8_t sign_a = get_sign(a);
    uint8_t sign_b = get_sign(b);

    uint64_t mantissa_a = get_mantissa(a);
    uint64_t mantissa_b = get_mantissa(b);

    uint64_t exponent_a = get_exponent(a);
    uint64_t exponent_b = get_exponent(b);

    uint8_t sign_result = sign_a ^ sign_b;

    uint8_t normalization_needed = 0;
    uint64_t mantissa_result = multiply_mantissa(mantissa_a, mantissa_b, &normalization_needed);

    uint64_t exponent_result = add_exponents(exponent_a, exponent_b) + normalization_needed;

    return compose_double(sign_result, exponent_result, mantissa_result);
}

uint64_t multiply_mantissa(const uint64_t mantissa_a, const uint64_t mantissa_b, uint8_t *normalization_needed)
{
    __uint128_t check_normalization = 0x1;
    check_normalization <<= 105;

    // @TODO: Define a bitwise multiplication ( Maybe specific to floating point )
    __uint128_t a = (__uint128_t)(mantissa_a);
    __uint128_t b = (__uint128_t)(mantissa_b);
    __uint128_t multiplication_result = a * b;

    // Now there are 53 + 53 bits = 106 bits, we need to reduce only to the most significant
    // and before that managing overflow, in fact we have one bits to consider before doing anything else
    // this is 106th bit

    // Normalization is always needed, in fact from the multiplication result you
    // will always have 10.xxxx or 11.xxxx, so we alway need to shift the result
    *normalization_needed = ((multiplication_result & check_normalization) >> 105);
    // *normalization_needed = 1;

    if (*normalization_needed)
    {
        multiplication_result >>= 1; // move the result to the left of one bit
    }

    // @TODO: Need to manage approximation

    // Now we always have 105 bits, we want to return to have 53 bits
    // 105 - 53 = 52 bits to shift
    uint64_t result = (uint64_t)(multiplication_result >> 52);

    return result;
}

uint64_t add_exponents(const uint64_t exponent_a, const uint64_t exponent_b)
{
    // @TODO: Define a bitwise addition for exponent ( Needs to include in someway the bias )

    // (exp_1 + BIAS) + (exp_2 + BIAS) = (exp_1 + exp_2) + 2 * BIAS
    uint64_t result = exponent_a + exponent_b - BIAS; // Adjust for bias
    return result;
}
