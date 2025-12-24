include(FetchContent)

# Set default BUILD_FLAVOR to empty if not provided (as a regular variable, not cached)
# If BUILD_FLAVOR is provided via -D, store it as a normal variable to avoid caching issues
# Then unset any cached BUILD_FLAVOR to ensure clean state
if(NOT DEFINED BUILD_FLAVOR)
    set(BUILD_FLAVOR "")
else()
    set(BUILD_FLAVOR "${BUILD_FLAVOR}")
endif()
unset(BUILD_FLAVOR CACHE)

# Determine the build flavor and set up file paths
if(BUILD_FLAVOR STREQUAL "")
    message(STATUS "Using default dependencies.json for imports")
    set(deps_file "${CMAKE_CURRENT_SOURCE_DIR}/dependencies.json")
    set(lock_file "${CMAKE_CURRENT_SOURCE_DIR}/dependencies.lock.json")
else()
    message(STATUS "Using dependencies-${BUILD_FLAVOR}.json for imports")
    set(deps_file "${CMAKE_CURRENT_SOURCE_DIR}/dependencies-${BUILD_FLAVOR}.json")
    set(lock_file "${CMAKE_CURRENT_SOURCE_DIR}/dependencies-${BUILD_FLAVOR}.lock.json")
endif()

# assert that deps_file exists
if(NOT EXISTS ${deps_file})
    message(FATAL_ERROR "Dependencies file not found: ${deps_file}")
endif()

# Define deps.json as a dependency to trigger reconfiguration when it changes
# and read its contents
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${deps_file})
file(READ ${deps_file} deps_content)

# Extract all package keys from the JSON using CMake's JSON support
string(JSON package_count LENGTH ${deps_content})
set(package_names "")
math(EXPR last_index "${package_count} - 1")
foreach(index RANGE ${last_index})
    string(JSON package_name MEMBER ${deps_content} ${index})
    list(APPEND package_names ${package_name})
endforeach()

# Initialize lock file content and dependencies list
set(lock_entries "")
set(IMPORTED_DEPENDENCIES "")

# Helper macro to import a dependency and add it to the lock file
macro(import_dependency package_name)
    # Read package info from JSON
    string(JSON package_url GET ${deps_content} ${package_name} url)
    string(JSON package_ref GET ${deps_content} ${package_name} ref)
    string(JSON package_targets GET ${deps_content} ${package_name} target)
    
    # Fetch the dependency
    FetchContent_Declare(
        ${package_name}
        GIT_REPOSITORY ${package_url}
        GIT_TAG        ${package_ref}
    )
    FetchContent_MakeAvailable(${package_name})
    
    # Get the actual commit hash that was checked out
    FetchContent_GetProperties(${package_name} SOURCE_DIR package_source_dir)
    execute_process(
        COMMAND git rev-parse HEAD
        WORKING_DIRECTORY ${package_source_dir}
        OUTPUT_VARIABLE package_commit_hash
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    message(STATUS "Imported ${package_name}: ${package_url} @ ${package_ref} (commit: ${package_commit_hash})")
    
    # Add to lock file entries
    if(lock_entries)
        string(APPEND lock_entries ",\n")
    endif()
    string(APPEND lock_entries "    \"${package_name}\": {\n")
    string(APPEND lock_entries "        \"url\": \"${package_url}\",\n")
    string(APPEND lock_entries "        \"ref\": \"${package_ref}\",\n")
    string(APPEND lock_entries "        \"commit\": \"${package_commit_hash}\",\n")
    string(APPEND lock_entries "        \"target\": \"${package_targets}\"\n")
    string(APPEND lock_entries "    }")
    
    # Add targets to dependencies list (space-separated targets)
    string(REPLACE " " ";" target_list "${package_targets}")
    list(APPEND IMPORTED_DEPENDENCIES ${target_list})
endmacro()

# Helper macro to dump the lock file content
macro(dump_lock_content)
    set(lock_json "{\n")
    string(APPEND lock_json ${lock_entries})
    string(APPEND lock_json "\n}\n")
    file(WRITE ${lock_file} ${lock_json})
endmacro()

# Import dependencies
foreach(package_name ${package_names})
    import_dependency(${package_name})
endforeach()

# Write lock file
dump_lock_content()

message(STATUS "Lock file written to: ${lock_file}")
message(STATUS "Imported dependencies: ${IMPORTED_DEPENDENCIES}")