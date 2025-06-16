#include <stdio.h>
#include <string.h>

#include "inner_product.h"
#include "case_manager.h"

#define N 100

int main(int argc, char const *argv[])
{
    enum OPERATING_MODE mode = STANDARD;

    if (argc > 1)
    {
        if (argv[1][0] == '-' && argv[1][1] == '-')
            set_operating_mode(&mode, argv[1]);
    }

    switch (mode)
    {
    case STANDARD:
    {
        print_operating_mode(mode);
        assert(mode == STANDARD && "Operating in standard mode.");
        return standard_case(argv[1], argv[2], N);
    }
    case CHECK_DOUBLE_COMPOSITION:
    {
        print_operating_mode(mode);
        assert(mode == CHECK_DOUBLE_COMPOSITION && "Checking double composition.");
        return check_double_composition_case();
    }
    case CHECK_EXPONENT:
    {
        print_operating_mode(mode);
        assert(mode == CHECK_EXPONENT && "Checking exponent addition.");
        return check_exponent_case();
    }

    case CHECK_MANTISSA:
    {
        print_operating_mode(mode);
        assert(mode == CHECK_MANTISSA && "Checking mantissa multiplication.");
        return check_mantissa_case();
    }

    default:
    {
        fprintf(stderr, "Invalid operating mode.\n");
        return 1;
    }
    }
}
