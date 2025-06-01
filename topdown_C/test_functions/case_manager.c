#include "case_manager.h"

void print_operating_mode(enum OPERATING_MODE mode)
{
    switch (mode)
    {
    case STANDARD:
        printf("Operating in standard mode.\n");
        break;
    case CHECK_MANTISSA:
        printf("Checking mantissa addition.\n");
        break;
    case CHECK_EXPONENT:
        printf("Checking exponent addition.\n");
        break;
    case CHECK_DOUBLE_COMPOSITION:
        printf("Checking double composition.\n");
        break;
    default:
        printf("Unknown operating mode.\n");
        exit(EXIT_FAILURE);
    }
}

void set_operating_mode(enum OPERATING_MODE *mode, const char *arg)
{
    if (strcmp(arg, "--check-multiplier-mantissa-multiplication") == 0)
    {
        *mode = CHECK_MANTISSA;
    }
    else if (strcmp(arg, "--check-multiplier-exponent-addition") == 0)
    {
        *mode = CHECK_EXPONENT;
    }
    else if (strcmp(arg, "--check-double-composition") == 0)
    {
        *mode = CHECK_DOUBLE_COMPOSITION;
    }
    else
    {
        fprintf(stderr, "Invalid argument: %s\n", arg);
        exit(EXIT_FAILURE);
    }
    
}

int standard_case()
{
    
    double a[] = {1.0, 2.0, 3.0};
    double b[] = {4.0, 5.0, 6.0};
    uint64_t size = sizeof(a) / sizeof(a[0]);

    double expected = standard_inner_product(a, b, size);
    double obtained = inner_product(a, b, size);

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
   
    return (expected == obtained) ? 0 : 1;
}

int check_mantissa_case()
{
    printf("Checking if mantissa is detected correctly. \n");

    int return_code = 0;

    const double first_test = 1.0;
    const double second_test = 2.0;
    const double pi = M_PI;
    const uint64_t expected_test_mantissa = 0x10000000000000;
    const uint64_t expected_pi_mantissa =   0x1921fb54442d18;

    uint64_t first_test_mantissa = get_mantissa(first_test);
    uint64_t second_test_mantissa = get_mantissa(second_test);
    uint64_t pi_mantissa = get_mantissa(pi);

    return_code = (first_test_mantissa == expected_test_mantissa) ? 0 : 1;
    assert((return_code == 0) && "Error in mantissa detection for first test (1.0)");

    return_code = (second_test_mantissa == expected_test_mantissa) ? 0 : 1;
    assert((return_code == 0) && "Error in mantissa detection for second test (2.0)");    

    return_code = (pi_mantissa == expected_pi_mantissa) ? 0 : 1;
    assert((return_code == 0) && "Error in mantissa detection for pi");

    printf("Checking Mantissa multiplication.\n");

    uint8_t normalization_needed = 0;
    const uint64_t multiplied_mantissa_1 = multiply_mantissa(expected_test_mantissa, expected_test_mantissa, &normalization_needed);

    return_code = ((multiplied_mantissa_1 == expected_test_mantissa) && (normalization_needed == 0)) ? 0 : 1;
    assert((return_code == 0) && "1 * 1 == 1, and no normalization needed");

    const uint64_t multiplied_mantissa_2 = multiply_mantissa(expected_test_mantissa, expected_pi_mantissa, &normalization_needed); 
    return_code = ((multiplied_mantissa_2 == expected_pi_mantissa) && (normalization_needed == 0)) ? 0 : 1;
    assert((return_code == 0) && "1 * pi == pi, and no normalization needed");

    const uint64_t multiplied_mantissa_3 = multiply_mantissa(expected_pi_mantissa, expected_pi_mantissa, &normalization_needed);
    const uint64_t expected_pi_squared_mantissa = 0x13bd3cc9be45de;

    return_code = (normalization_needed == 1) ? 0 : 1;
    assert((return_code == 0) && "pi * pi == pi^2, so normalization needed");

    return_code = (multiplied_mantissa_3 == expected_pi_squared_mantissa)  ? 0 : 1;
    assert((return_code == 0) && "pi * pi == pi^2, is it correct?");

    if (return_code == 0)
    {
        printf("Mantissa detection test passed.\n");
    }
    else
    {
        printf("Mantissa detection test failed.\n");
    }

    return return_code;
}

int check_exponent_case()
{
    return 0;
}

int check_double_composition_case()
{
    return 0;
}
