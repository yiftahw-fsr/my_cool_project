# my_cool_project

## Dependency Management

This project uses a custom CMake-based dependency management system via `import_dependencies.cmake`. This system provides declarative, version-controlled dependency management with automatic lock file generation for build reproducibility.

### Features

#### 1. JSON-Based Dependency Declaration

Dependencies are declared in `dependencies.json` with a simple structure:

```json
{
    "my_cool_package": {
        "url": "https://github.com/yiftahw-fsr/my_cool_package.git",
        "ref": "v1.0.0",
        "target": "my_cool_package"
    },
    "magic_enum": {
        "url": "https://github.com/Neargye/magic_enum.git",
        "ref": "v0.9.3",
        "target": "magic_enum::magic_enum"
    },
    "fmt": {
        "url": "https://github.com/fmtlib/fmt.git",
        "ref": "10.2.1",
        "target": "fmt::fmt"
    }
}
```

**Fields:**
- `url`: Git repository URL
- `ref`: Git tag, branch, or commit to fetch
- `target`: CMake target(s) to link against (space-separated for multiple targets from one repo)
```

**The system is completely agnostic to the actual set of packages** - it automatically discovers all packages from the JSON file and imports them without any manual configuration in CMake files.

#### 2. Automatic Lock File Generation

During CMake configuration, `import_dependencies.cmake` generates a lock file (e.g., `dependencies-lock.json`) that captures:
- The exact commit hash checked out for each dependency
- The URL and ref that were specified
- A complete bill of materials for reproducibility

**Lock files should be checked into version control** for traceability and to ensure reproducible builds across different environments and time periods.

Example lock file:
```json
{
    "my_cool_package": {
        "url": "https://github.com/yiftahw-fsr/my_cool_package.git",
        "ref": "v1.0.0",
        "commit": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0",
        "target": "my_cool_package"
    },
    "magic_enum": {
        "url": "https://github.com/Neargye/magic_enum.git",
        "ref": "v0.9.3",
        "commit": "9a8b7c6d5e4f3g2h1i0j9k8l7m6n5o4p3q2r1s0",
        "target": "magic_enum::magic_enum"
    }
}
```

#### 3. Build Flavor Support

The system supports multiple build flavors for different dependency configurations (e.g., stable vs. nightly builds):

```bash
# Use default dependencies.json
cmake -S . -B build

# Use dependencies-nightly.json and generate dependencies-nightly-lock.json
cmake -S . -B build -DBUILD_FLAVOR=nightly
```

The `BUILD_FLAVOR` variable is intentionally **not cached**, so you can switch between flavors cleanly without cache pollution.

#### 4. Under the Hood

The system uses CMake's `FetchContent` module to fetch and make dependencies available. For each package in your JSON file, the following happens:

```cmake
# What import_dependencies.cmake does for each package:

# 1. Declare the dependency
FetchContent_Declare(
    my_cool_package
    GIT_REPOSITORY https://github.com/yiftahw-fsr/my_cool_package.git
    GIT_TAG v1.0.0
)

# 2. Make it available (fetches and adds to build)
FetchContent_MakeAvailable(my_cool_package)

# 3. Capture the actual commit hash for the lock file
execute_process(
    COMMAND git rev-parse HEAD
    WORKING_DIRECTORY ${my_cool_package_SOURCE_DIR}
    OUTPUT_VARIABLE commit_hash
)
```

All fetched dependencies are automatically linked via the `IMPORTED_DEPENDENCIES` variable.

### Usage

Simply include `import_dependencies.cmake` in your `CMakeLists.txt`:

```cmake
include(import_dependencies.cmake)

add_executable(my_cool_project main.cpp)
target_link_libraries(my_cool_project PRIVATE ${IMPORTED_DEPENDENCIES})
```

### Adding New Dependencies

1. Add the package to `dependencies.json`
2. Run CMake configuration
3. Commit both `dependencies.json` and the updated `dependencies-lock.json`

That's it! No need to modify CMake files.