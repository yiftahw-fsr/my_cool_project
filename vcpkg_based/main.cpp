#include <magic_enum/magic_enum.hpp>
#include <iostream>

enum class Color { Red, Green, Blue };

int main() {
    Color c = Color::Green;

    // Convert enum to string
    std::cout << "Color: " << magic_enum::enum_name(c) << "\n";

    // Convert string to enum
    auto maybe_color = magic_enum::enum_cast<Color>("Red");
    if(maybe_color.has_value()) {
        std::cout << "Parsed enum: " << static_cast<int>(maybe_color.value()) << "\n";
    }
}
