
add_library(testing_functions
    case_manager.c
)

target_include_directories(
    testing_functions
    INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(
    testing_functions
    PUBLIC
    components
)

target_link_libraries(
    testing_functions
    PUBLIC
    FPGA_sim_compiler_flags
)