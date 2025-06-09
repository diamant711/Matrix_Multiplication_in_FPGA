#include "adder.h"

double old_adder(const double a, const double b, const uint8_t subtraction_mode)
{
    double return_value = 0.0;
    uint64_t mantissa_a = get_mantissa(a);
    uint64_t mantissa_b = get_mantissa(b);
    uint64_t exponent_a = get_exponent(a);
    uint64_t exponent_b = get_exponent(b);
    uint8_t sign_a = get_sign(a);
    uint8_t sign_b = get_sign(b);
    uint64_t tmp;
    uint64_t carry;
    uint64_t borrow;
    //if (a == 0.0) return b;
    //if (b == 0.0) return a;
#ifdef DEBUG
    printf("\n###DEBUG MANTISSA SUM###\n");
    print_bin(&mantissa_a, UINT64);
    printf(" +/-\n");
    print_bin(&mantissa_b, UINT64);
    printf(" =\n");
    for (int i = 0; i < 130; i++) putchar('-');
    putchar('\n');
#endif
    if (subtraction_mode)
    {
        // If subtraction mode is enabled, we need to flip the sign of b
        sign_b ^= 1;
    }
    // Check if the exponents are equal
    int64_t exponent_shift = exponent_a - exponent_b;
    uint64_t mantissa_result;
    // Normalize exponents to same value
    if (exponent_shift >= 0)
    {
        mantissa_b >>= exponent_shift;
    }
    else
    {
        mantissa_a >>= -exponent_shift;
    }
#ifdef DEBUG
    print_bin(&mantissa_a, UINT64);
    printf(" +/-\n");
    print_bin(&mantissa_b, UINT64);
    printf(" =\n");
    for (int i = 0; i < 130; i++) putchar('-');
    putchar('\n');
#endif
    if (sign_a == sign_b)
    {
        // If both signs are the same, we add the mantissas
        // @TODO Need a bitwise algorithm here
        //mantissa_result = mantissa_a + mantissa_b;
        while (mantissa_b != 0) {
            tmp = mantissa_a ^ mantissa_b;
            carry = (mantissa_a & mantissa_b) << 1;
            mantissa_a = tmp;
            mantissa_b = carry;
        }
        mantissa_result = mantissa_a;
        /*
        // Check if normalization is needed
        if (mantissa_result & 0x8000000000000000) // Check if the result is normalized
        {
            mantissa_result >>= 1; // Normalize by shifting right
            exponent_a += 1; // Increase exponent
        }
        */
        // Normalizza a sinistra (solo se != 0)
        if (mantissa_result != 0) {
            while ((mantissa_result & (1ULL << 52)) == 0) {
                mantissa_result <<= 1;
                exponent_a -= 1;
            }
        }
        // togli il bit implicito prima di ricomporre
        mantissa_result &= ~(1ULL << 52);
        return_value = compose_double(sign_a, exponent_a, mantissa_result);
    }
    else
    {
        // If signs are different, we subtract the smaller mantissa from the larger one
        if (mantissa_a >= mantissa_b)
        {
            // @TODO Need a bitwise algorithm here
            //mantissa_result = mantissa_a - mantissa_b;
            while (mantissa_b != 0) {
                borrow = (~mantissa_a) & mantissa_b;
                mantissa_a = mantissa_a ^ mantissa_b;
                mantissa_b = borrow << 1;
            }
            mantissa_result = mantissa_a;
            // Normalizza a sinistra (solo se != 0)
            if (mantissa_result != 0) {
                while ((mantissa_result & (1ULL << 52)) == 0) {
                    mantissa_result <<= 1;
                    exponent_a -= 1;
                }
            }
            // togli il bit implicito prima di ricomporre
            mantissa_result &= ~(1ULL << 52);
            return_value = compose_double(sign_a, exponent_a, mantissa_result);
        }
        else
        {
            // @TODO Need a bitwise algorithm here
            //mantissa_result = mantissa_b - mantissa_a;
            while (mantissa_b != 0) {
                borrow = (~mantissa_a) & mantissa_b;
                mantissa_a = mantissa_a ^ mantissa_b;
                mantissa_b = borrow << 1;
            }
            mantissa_result = mantissa_a;
            // Normalizza a sinistra (solo se != 0)
            if (mantissa_result != 0) {
                while ((mantissa_result & (1ULL << 52)) == 0) {
                    mantissa_result <<= 1;
                    exponent_a -= 1;
                }
            }
            // togli il bit implicito prima di ricomporre
            mantissa_result &= ~(1ULL << 52);
            return_value = compose_double(sign_b, exponent_b, mantissa_result);
        }
    }
#ifdef DEBUG
    for (int i = 0; i < 130; i++) putchar('-');
    putchar('\n');
    print_bin(&mantissa_result, UINT64);
    putchar('\n');
#endif
    return return_value;
}
