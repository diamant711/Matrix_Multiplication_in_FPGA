add_library(components
    adder.c
    multiplier.c
    inner_product.c
    double_composer.c
)

target_include_directories(
    components
    INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(
    components
    PUBLIC
    FPGA_sim_compiler_flags
)

target_link_libraries(
    components
    PUBLIC
    testing_functions
)