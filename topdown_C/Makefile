# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -Wshadow -std=gnu17 -std=c17
INCLUDES = -Icomponents -Itest_functions -lm

# Directories
SRC_DIR = .
BUILD_DIR = build
COMPONENTS_DIR = components
TEST_DIR = test_functions

# Source files
MAIN_SRC = $(SRC_DIR)/main.c
COMPONENTS_SRC = $(wildcard $(COMPONENTS_DIR)/*.c)
TEST_SRC = $(wildcard $(TEST_DIR)/*.c)
ALL_SRC = $(MAIN_SRC) $(COMPONENTS_SRC) $(TEST_SRC)

# Object files (in build/)
OBJS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(subst ./,,$(ALL_SRC)))

# Executable
TARGET = FPGA_simulation.exe

.PHONY: all clean test dirs

all: dirs $(TARGET)

dirs:
	mkdir -p $(BUILD_DIR)/components $(BUILD_DIR)/test_functions

# Link
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

# Compile .c -> build/.o
$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

# Clean up
clean:
	rm -rf $(BUILD_DIR) $(TARGET)

# Run tests
test: all
	@echo "Running tests..."
	@./$(TARGET)
	@./$(TARGET) --check-multiplier-exponent-addition
	@./$(TARGET) --check-multiplier-mantissa-multiplication
	@./$(TARGET) --check-multiplier-double-formation
