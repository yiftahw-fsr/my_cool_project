cmake_minimum_required(VERSION 3.19)
# version 3.19 is required for JSON capabilities

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

project(my_cool_project VERSION 1.0 LANGUAGES CXX)

include(import_dependencies.cmake)

add_executable(my_cool_project main.cpp)

# Link against your target
target_link_libraries(my_cool_project PRIVATE ${IMPORTED_DEPENDENCIES})
