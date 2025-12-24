include(FetchContent)

# define `deps.json` as a dependency to trigger reconfiguration when it changes
# and read its contents
set(deps_file "${CMAKE_CURRENT_SOURCE_DIR}/dependencies.json")
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${deps_file})
file(READ ${deps_file} deps_content)


# Galil API
string(JSON my_cool_package_url GET ${deps_content} my_cool_package url)
string(JSON my_cool_package_ref GET ${deps_content} my_cool_package ref)

FetchContent_Declare(
  my_cool_package
  GIT_REPOSITORY ${my_cool_package_url}
  GIT_TAG        ${my_cool_package_ref}
)
FetchContent_MakeAvailable(my_cool_package)

set(IMPORTED_DEPENDENCIES my_cool_package)