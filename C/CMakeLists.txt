cmake_minimum_required(VERSION 3.20)

# set the project name, version and langauge
project(FPGA_simulation.exe LANGUAGES C VERSION 0.1)

add_library( FPGA_sim_compiler_flags INTERFACE)
target_compile_features(FPGA_sim_compiler_flags INTERFACE c_std_17)
target_compile_options(FPGA_sim_compiler_flags INTERFACE -Wall -Wextra -Wshadow --std=gnu17)

add_subdirectory(components)
add_subdirectory(test_functions)

# Adding the main executale
add_executable(FPGA_simulation.exe main.c)

# Adding links to the components library
target_link_libraries(FPGA_simulation.exe PUBLIC components FPGA_sim_compiler_flags)
target_link_libraries(FPGA_simulation.exe PUBLIC testing_functions FPGA_sim_compiler_flags)



# Testing Section
enable_testing()
include(CTest)


add_test(NAME run COMMAND FPGA_simulation.exe) # Try if runs successfully

add_test(NAME check_multiplier_exponent_addition COMMAND FPGA_simulation.exe --check-multiplier-exponent-addition)
add_test(NAME check_multiplier_mantissa_multiplication COMMAND FPGA_simulation.exe --check-multiplier-mantissa-multiplication)
add_test(NAME check_multiplier_double_formation COMMAND FPGA_simulation.exe --check-double-composition)
