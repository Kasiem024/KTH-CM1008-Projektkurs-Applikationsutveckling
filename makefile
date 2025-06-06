# --- Variables ---

# Directories
SRCDIR := ./src
OBJDIR := ./obj
INCDIR := ./include

# Executable name
EXECUTABLE := main

# Compiler and flags
CC := gcc

# Allow overriding SDL paths via environment or command line
# Example: make SDL_BASE_PATH=C:/my_sdl3_install
SDL_BASE_PATH ?= C:/msys64/mingw64
SDL_INCLUDE_DIR ?= $(SDL_BASE_PATH)/include
SDL_LIB_DIR ?= $(SDL_BASE_PATH)/lib

# Preprocessor flags (include paths)
# Includes the project's include directory and the SDL include directory
CPPFLAGS := -I$(INCDIR) -I$(SDL_INCLUDE_DIR)

# C compiler flags
# -g: Debug symbols
# -Wall -Wextra: Enable most warnings
# -MMD -MP: Generate dependency files (.d)
CFLAGS := -g -Wall -Wextra -MMD -MP

# Linker flags (library paths)
# Add the SDL library directory
LDFLAGS := -L$(SDL_LIB_DIR)

# Libraries to link
# Note the order can be important
LDLIBS := -lmingw32 -lSDL3 -lSDL3_net -lSDL3_image -lSDL3_ttf

# --- Files ---

# Find all .c files in the source directory automatically
SOURCES := $(wildcard $(SRCDIR)/*.c)

# Create object file paths in the object directory
OBJECTS := $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

# Create dependency file paths (.d files corresponding to .o files)
DEPS := $(OBJECTS:.o=.d)

# --- Targets ---

# Phony targets are ones that don't represent actual files
.PHONY: all clean

# Default target: build the executable
all: $(EXECUTABLE)

# Rule to link the executable
$(EXECUTABLE): $(OBJECTS)
	@echo "Linking..."
	$(CC) $(LDFLAGS) $^ -o $@ $(LDLIBS)
	@echo "Build finished: $(EXECUTABLE)"

# Rule to create the object directory if it doesn't exist
# This target is an order-only prerequisite for the compilation rule below.
$(OBJDIR):
	@echo "Ensuring object directory exists: $(OBJDIR)"
	@$(MAKE_DIR) $(subst /,\,$(OBJDIR))

# Define MAKE_DIR based on OS (simple check for Windows)
ifeq ($(OS),Windows_NT)
    # Use Windows 'mkdir' command, suppress error if dir exists
    MAKE_DIR := -mkdir
else
    # Use POSIX 'mkdir -p' for other systems
    MAKE_DIR := mkdir -p
endif

# Rule to compile .c files into .o files in the object directory
# Depends on the source file and has $(OBJDIR) as an order-only prerequisite
$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	@echo "Compiling $< -> $@"
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# Rule to clean up generated files
clean:
	@echo "Cleaning..."
# Use rm command appropriate for the OS
ifeq ($(OS),Windows_NT)
	-if exist $(subst /,\,$(OBJDIR)) rmdir /s /q $(subst /,\,$(OBJDIR))
	-if exist $(EXECUTABLE).exe del $(EXECUTABLE).exe
	-if exist $(EXECUTABLE) del $(EXECUTABLE)
else
	rm -rf $(OBJDIR) $(EXECUTABLE) $(EXECUTABLE).exe
endif
	@echo "Clean complete."

# Include the dependency files generated by the compiler
# The '-' suppresses errors if the files don't exist (e.g., first build or after clean)
-include $(DEPS)