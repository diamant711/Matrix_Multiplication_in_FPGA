#include "inner_product.h"


double standard_inner_product(const double *a, const double *b, const uint64_t n)
{
    double result = 0.0;
    for (uint64_t i = 0; i < n; i++)
    {

        result += a[i] * b[i];
    }
    return result;
}


double inner_product(const double *a, const double *b, const uint64_t n)
{
    double result = 0.0;
    double multiplication_result;
    for (uint64_t i = 0; i < n; i++)
    {
#ifdef DEBUG
        printf("%lf * %lf = ", a[i], b[i]);
#endif
        multiplication_result = multiplier(a[i] , b[i]);
#ifdef DEBUG
        printf("%lf\n", multiplication_result);
        printf("%lf + %lf = \n", result, multiplication_result);
#endif
        result = adder(result, multiplication_result, 0);
#ifdef DEBUG
        printf("%lf\n", result);
#endif
    }
    return result;
}
