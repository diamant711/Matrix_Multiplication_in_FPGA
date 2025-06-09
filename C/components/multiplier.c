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
/*#ifdef DEBUG
    printf("\nCheck Mantissa Normalization\n");
    print_hex(&check_normalization, UINT128);
    putchar('\n');
#endif*/

    // @TODO: Define a bitwise multiplication ( Maybe specific to floating point )
    // Bitwise multiplication
    __uint128_t a = (__uint128_t)(mantissa_a);
    __uint128_t b = (__uint128_t)(mantissa_b);
    __uint128_t multiplication_result = 0x0;
#ifdef DEBUG
    printf("\n###DEBUG MANTISSA MULTIPLICATION###\n");
    print_bin(&a, UINT128);
    printf(" *\n");
    print_bin(&b, UINT128);
    printf(" =\n");
#endif
    __uint128_t carry;
    __uint128_t tmp;
    __uint128_t x;
    __uint128_t y;
    while (b > 0) {
        if (b & 1) {
            //Accumulo a in multiplication_result
            carry = 0x1; // Magic Number
            x = a;
            y = multiplication_result;
            while (carry != 0x0) {
                tmp = x ^ y;
                carry = (x & y) << 1;
                x = tmp;
                y = carry;
            }
            multiplication_result = x;
        }
        a <<= 1;
        b >>= 1;
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

    *normalization_needed = ((multiplication_result & check_normalization) >> 105);


    if (*normalization_needed)
    {
        multiplication_result >>= 1; // move the result to the left of one bit
    }

    // @TODO: Need to manage approximation
    // No need for approximation after we see the number as affected with
    // UNCERTAINTY
    // ROUNDING (IEEE-754: round to nearest, ties to even)
    // Estraggo i bit di guardia (bit 52), round (51), sticky (<51)
    uint8_t guard_bit = (multiplication_result >> 51) & 0x1;
    uint8_t round_bit = (multiplication_result >> 50) & 0x1;
    uint8_t sticky_bit = (multiplication_result & ((1ULL << 50) - 1)) ? 1 : 0;

    // Troncamento iniziale a 53 bit (con 1 implicito già incluso)
    multiplication_result >>= 52;

    // Applico l'arrotondamento secondo IEEE
    if (guard_bit && (round_bit || sticky_bit || (multiplication_result & 0x1))) {
        multiplication_result += 1;

        // Se overflow nella mantissa, serve rinormalizzare
        if (multiplication_result & (1ULL << 53)) {
            multiplication_result >>= 1;
            *normalization_needed = 1;
        }
    }

    uint64_t result = (uint64_t)(multiplication_result);
    return result;
}

uint64_t add_exponents(const uint64_t exponent_a, const uint64_t exponent_b)
{
    uint64_t result;
    uint64_t a = exponent_a;
    uint64_t b = exponent_b;
    uint64_t bias = BIAS;
    uint64_t tmp;
    uint64_t carry; //Magic Number
    uint64_t borrow;
    // @TODO: Define a bitwise addition for exponent ( Needs to include in someway the bias )
    // Bitwise Sum
#ifdef DEBUG
    printf("\n###DEBUG EXPONENT SUM###\n");
    print_bin(&exponent_a, UINT64);
    printf(" +\n");
    print_bin(&exponent_b, UINT64);
    printf(" -\n");
    print_bin(&bias, UINT64);
    printf(" =\n");
#endif
    // (exp_1 + BIAS) + (exp_2 + BIAS) = (exp_1 + exp_2) + 2 * BIAS
    while (b != 0) {
        tmp = a ^ b;
        carry = (a & b) << 1;
        a = tmp;
        b = carry;
    }
    while (bias != 0) {
        borrow = (~a) & bias;
        a = a ^ bias;
        bias = borrow << 1;
    }
    result = a;
    //result = exponent_a + exponent_b - BIAS; // Adjust for bias
#ifdef DEBUG
    for (int i = 0; i < 130; i++) putchar('-');
    putchar('\n');
    print_bin(&result, UINT64);
    putchar('\n');
#endif
    return result;
}
