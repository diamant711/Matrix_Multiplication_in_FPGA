cmake_minimum_required(VERSION 3.20)

# set the project name, version and langauge
project(FPGA_simulation.exe LANGUAGES C VERSION 0.1)

add_library( FPGA_sim_compiler_flags INTERFACE)
target_compile_features(FPGA_sim_compiler_flags INTERFACE c_std_11)
target_compile_options(FPGA_sim_compiler_flags INTERFACE -Wall -Wextra -Wshadow)

add_subdirectory(components)

# Adding the main executale
add_executable(FPGA_simulation.exe main.c)

# Adding links to the components library
target_link_libraries(FPGA_simulation.exe PUBLIC components FPGA_sim_compiler_flags)

