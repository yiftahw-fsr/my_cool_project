cmake_minimum_required(VERSION 3.21)

# setup
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
# project definition
project(dummy_project VERSION 0.1 LANGUAGES CXX)

# dependencies
find_package(magic_enum CONFIG REQUIRED)

add_executable(app main.cpp)
target_link_libraries(app PRIVATE magic_enum::magic_enum)
