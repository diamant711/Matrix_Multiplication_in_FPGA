#include "adder.h"  // Assumi che ci siano get_mantissa, get_exponent, get_sign, compose_double

// Somma bitwise senza usare '+'
static uint64_t bitwise_add(uint64_t a, uint64_t b) {
    while (b != 0) {
        uint64_t carry = (a & b) << 1;
        a = a ^ b;
        b = carry;
    }
    return a;
}

// Sottrazione bitwise (a >= b)
static uint64_t bitwise_subtract(uint64_t a, uint64_t b) {
    while (b != 0) {
        uint64_t borrow = (~a) & b;
        a = a ^ b;
        b = borrow << 1;
    }
    return a;
}

double adder(const double a, const double b, const uint8_t subtraction_mode)
{
    // Estrai componenti
    uint64_t mantissa_a = get_mantissa(a);
    uint64_t mantissa_b = get_mantissa(b);
    int64_t exponent_a = get_exponent(a);
    int64_t exponent_b = get_exponent(b);
    uint8_t sign_a = get_sign(a);
    uint8_t sign_b = get_sign(b);

    if (subtraction_mode) {
        sign_b ^= 1; // Inverti segno b per sottrazione
    }

    // Allinea mantissa minore con shift a destra e scegli esponente base risultato
    int64_t exponent_result;
    if (exponent_a > exponent_b) {
        int64_t shift = exponent_a - exponent_b;
        if (shift > 63) { // shift troppo grande → b trascurabile
            mantissa_b = 0;
        } else {
            mantissa_b >>= shift;
        }
        exponent_result = exponent_a;
    } else if (exponent_b > exponent_a) {
        int64_t shift = exponent_b - exponent_a;
        if (shift > 63) {
            mantissa_a = 0;
        } else {
            mantissa_a >>= shift;
        }
        exponent_result = exponent_b;
    } else {
        // Esponenti uguali
        exponent_result = exponent_a;
    }

    uint64_t mantissa_result = 0;
    uint8_t sign_result = 0;

    if (sign_a == sign_b) {
        // Somma mantisse
        mantissa_result = bitwise_add(mantissa_a, mantissa_b);
        sign_result = sign_a;

        // Normalizza se carry esce da bit 52 (oltre il range della mantissa)
        if (mantissa_result & (1ULL << 53)) {
            mantissa_result >>= 1;
            exponent_result++;
        }

        // Normalizza a sinistra finché MSB mantissa non è bit 52
        while ((mantissa_result & (1ULL << 52)) == 0 && mantissa_result != 0) {
            mantissa_result <<= 1;
            exponent_result--;
        }
    } else {
        // Sottrazione mantisse (il più grande meno il più piccolo)
        if (mantissa_a >= mantissa_b) {
            mantissa_result = bitwise_subtract(mantissa_a, mantissa_b);
            sign_result = sign_a;
        } else {
            mantissa_result = bitwise_subtract(mantissa_b, mantissa_a);
            sign_result = sign_b;
        }

        // Se risultato zero, ritorna zero con segno positivo
        if (mantissa_result == 0) {
            return 0.0;
        }

        // Normalizza a sinistra
        while ((mantissa_result & (1ULL << 52)) == 0) {
            mantissa_result <<= 1;
            exponent_result--;
        }
    }

    return compose_double(sign_result, exponent_result, mantissa_result);
}
