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
    __uint128_t multiplication_result = 0x0;
    __uint128_t partial_multiplication_result = 0x0;
    uint8_t uint128_t_bit_size = 128;
#ifdef DEBUG
    printf("\n###DEBUG MANTISSA CONVERSION###\n");
    print_bin(&mantissa_a, UINT64);
    printf(" ->\n");
    print_bin(&a, UINT128);
    putchar('\n');
    for (int i = 0; i < 131; i++) putchar('-');
    putchar('\n');
    print_bin(&mantissa_b, UINT64);
    printf(" ->\n");
    print_bin(&b, UINT128);
    // Bitwise multiplication
    printf("\n###DEBUG MANTISSA MULTIPLICATION###\n");
    print_bin(&a, UINT128);
    printf(" *\n");
    print_bin(&b, UINT128);
    printf(" =\n");
    for (int i = 0; i < 130; i++) putchar('-');
    putchar('\n');
#endif
    uint8_t carry = 0;
    for (uint8_t i = 0; i < uint128_t_bit_size; i++) {
        for (uint8_t j = 0; j < uint128_t_bit_size; j++) {
            partial_multiplication_result |=
              (((a >> i) & 1) & (b >> i) & 1) * (2*i);
        }
#ifdef DEBUG
        print_bin(&partial_multiplication_result, UINT128);
        printf(" +\n");
#endif
        for (uint8_t j = 0; j < uint128_t_bit_size; j++) {
            multiplication_result |=
                (((multiplication_result >> j) & 1) ^
                (partial_multiplication_result >> j & 1) ^
                carry) * (2*j) ;
            carry =
              ((multiplication_result >> j) & (partial_multiplication_result >> j)) |
              (carry & ((multiplication_result >> j) ^ (partial_multiplication_result >> j)));
        }
    }
#ifdef DEBUG
    for (int i = 0; i < 130; i++) putchar('-');
    putchar('\n');
    print_bin(&multiplication_result, UINT128);
    putchar('\n');
#endif
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
    // No need for approximation after we see the number as affected with
    // UNCERTAINTY

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
