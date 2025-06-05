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
    for (uint64_t i = 0; i < n; i++)
    {
        printf("%lf * %lf = ", a[i], b[i]);
        double multiplication_result = multiplier(a[i] , b[i]);
        printf("%lf\n", multiplication_result);
        //double expected = a[i] * b[i];
        //assert((expected == multiplication_result) && "multiplication failed, at this stage is composition\n" );
        result += multiplication_result;
    }
    return result;
}
