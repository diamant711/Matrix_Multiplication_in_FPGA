#include <stdio.h>

#include "inner_product.h"

int main(/* int argc, char const *argv[] */)
{
    double a[] = {1.0, 2.0, 3.0};
    double b[] = {4.0, 5.0, 6.0};
    uint64_t size = sizeof(a) / sizeof(a[0]);

    double expected = standard_inner_product(a, b, size);
    double obtained =  inner_product(a, b, size);

    printf("Standard Inner Product : %f\n", expected);
    printf("Inner product: %f\n", obtained);

    if (expected == obtained)
    {
        printf("TEST SUCCEDED\n");
    }
    else
    {
        printf("TEST FAILED\n");
    }


    return 0;
}
