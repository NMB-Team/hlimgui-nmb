cmake_minimum_required(VERSION 3.10)

set(TARGET_NAME hlimgui)
set(TARGET_EXT .hdll)

project(${TARGET_NAME})

set(HASHLINK_ROOT_CANDIDATES "")
foreach(HASHLINK_ENV_NAME HASHLINK_BIN HASHLINK_PATH HASHLINKPATH)
    if(DEFINED ENV{${HASHLINK_ENV_NAME}} AND NOT "$ENV{${HASHLINK_ENV_NAME}}" STREQUAL "")
        list(APPEND HASHLINK_ROOT_CANDIDATES "$ENV{${HASHLINK_ENV_NAME}}")
    endif()
endforeach()

list(APPEND HASHLINK_ROOT_CANDIDATES
    "C:/HaxeToolkit/hashlink"
    "C:/HashLink"
    "/usr/local"
    "/opt/homebrew"
    "/opt/hashlink"
)

find_program(HASHLINK_EXECUTABLE
    NAMES hl hl.exe
    HINTS ${HASHLINK_ROOT_CANDIDATES}
    PATH_SUFFIXES "" bin
)

if(HASHLINK_EXECUTABLE)
    get_filename_component(HASHLINK_EXECUTABLE_DIR "${HASHLINK_EXECUTABLE}" DIRECTORY)
    get_filename_component(HASHLINK_EXECUTABLE_PARENT "${HASHLINK_EXECUTABLE_DIR}" DIRECTORY)
    list(APPEND HASHLINK_ROOT_CANDIDATES "${HASHLINK_EXECUTABLE_DIR}" "${HASHLINK_EXECUTABLE_PARENT}")
endif()

find_path(HASHLINK_INCLUDE_DIR
    NAMES hl.h
    HINTS ${HASHLINK_ROOT_CANDIDATES}
    PATH_SUFFIXES include
)

find_library(HASHLINK_LIBRARY
    NAMES libhl hl
    HINTS ${HASHLINK_ROOT_CANDIDATES}
    PATH_SUFFIXES "" lib
)

if(NOT HASHLINK_INCLUDE_DIR OR NOT HASHLINK_LIBRARY)
    message(FATAL_ERROR "Could not locate HashLink. Set HASHLINK_BIN, HASHLINK_PATH, HASHLINKPATH, or make hl available in PATH.")
endif()

message(STATUS "Using HashLink include: ${HASHLINK_INCLUDE_DIR}")
message(STATUS "Using HashLink library: ${HASHLINK_LIBRARY}")

option(NODE_EDITOR "Include imgui-node-editor (required to use NodeEditor.hx)" ON)
option(NEO_SEQUENCER "Include imgui-neo_sequencer (required to use NeoSequencer.hx). DEPRECATED." OFF)
option(MARKDOWN "Include markdown support (required to use Imgui.TextMarkdown)" ON)

if( NODE_EDITOR )
    set(IMGUI_NODE_EDITOR_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib/imgui-node-editor")
    set(IMGUI_NODE_EDITOR_PATCH "${CMAKE_CURRENT_SOURCE_DIR}/patches/imgui-node-editor-imgui-1.92.patch")
    find_package(Git QUIET)

    if(NOT GIT_FOUND)
        message(FATAL_ERROR "Git is required to apply the imgui-node-editor compatibility patch.")
    endif()

    execute_process(
        COMMAND ${GIT_EXECUTABLE} apply --check --ignore-whitespace "${IMGUI_NODE_EDITOR_PATCH}"
        WORKING_DIRECTORY "${IMGUI_NODE_EDITOR_DIR}"
        RESULT_VARIABLE IMGUI_NODE_EDITOR_PATCH_CHECK
        OUTPUT_QUIET
        ERROR_QUIET
    )
    if(IMGUI_NODE_EDITOR_PATCH_CHECK EQUAL 0)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} apply --ignore-whitespace "${IMGUI_NODE_EDITOR_PATCH}"
            WORKING_DIRECTORY "${IMGUI_NODE_EDITOR_DIR}"
            RESULT_VARIABLE IMGUI_NODE_EDITOR_PATCH_APPLY
        )
        if(NOT IMGUI_NODE_EDITOR_PATCH_APPLY EQUAL 0)
            message(FATAL_ERROR "Failed to apply imgui-node-editor compatibility patch.")
        endif()
    else()
        execute_process(
            COMMAND ${GIT_EXECUTABLE} apply --reverse --check --ignore-whitespace "${IMGUI_NODE_EDITOR_PATCH}"
            WORKING_DIRECTORY "${IMGUI_NODE_EDITOR_DIR}"
            RESULT_VARIABLE IMGUI_NODE_EDITOR_PATCH_REVERSE_CHECK
            OUTPUT_QUIET
            ERROR_QUIET
        )
        if(NOT IMGUI_NODE_EDITOR_PATCH_REVERSE_CHECK EQUAL 0)
            message(FATAL_ERROR "imgui-node-editor compatibility patch is neither applicable nor already applied.")
        endif()
    endif()
endif()

file(GLOB SOURCES "*.cpp")
file(GLOB IMGUI_SOURCES "lib/imgui/*.cpp")

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if( NODE_EDITOR )
    file(GLOB IMGUI_NODE_EDITOR_EXTENSION_SOURCES "addons/node_editor/*.cpp")
    file(GLOB IMGUI_NODE_EDITOR_SOURCES "lib/imgui-node-editor/*.cpp")

    list(APPEND SOURCES ${IMGUI_NODE_EDITOR_EXTENSION_SOURCES})
    list(APPEND IMGUI_SOURCES ${IMGUI_NODE_EDITOR_SOURCES})
endif()

if( NEO_SEQUENCER )
    file(GLOB IMGUI_NEO_SEQUENCER_EXTENSION_SOURCES "addons/neo_sequencer/*.cpp")
    file(GLOB IMGUI_NEO_SEQUENCER_SOURCES "lib/neo_sequencer/*.cpp")

    list(APPEND SOURCES ${IMGUI_NEO_SEQUENCER_EXTENSION_SOURCES})
    list(APPEND IMGUI_SOURCES ${IMGUI_NEO_SEQUENCER_SOURCES})
endif()

if( MARKDOWN )
    file(GLOB IMGUI_MARKDOWN_EXTENSION_SOURCES "addons/markdown/*.cpp")
    list(APPEND SOURCES ${IMGUI_MARKDOWN_EXTENSION_SOURCES})
endif()


add_library(${TARGET_NAME}${TARGET_EXT} SHARED ${SOURCES} ${IMGUI_SOURCES})

add_compile_definitions(IMGUI_USER_CONFIG="../../imgui_config.h")

set_target_properties(${TARGET_NAME}${TARGET_EXT}
    PROPERTIES
    PREFIX ""
    OUTPUT_NAME ${TARGET_NAME}
    SUFFIX ${TARGET_EXT}
)

target_include_directories(${TARGET_NAME}${TARGET_EXT} PUBLIC ${HASHLINK_INCLUDE_DIR} lib/imgui/ )
target_link_libraries(${TARGET_NAME}${TARGET_EXT} ${HASHLINK_LIBRARY})

IF (APPLE)
find_library(APPLICATION_SERVICES_FRAMEWORK ApplicationServices REQUIRED)
target_link_libraries(${TARGET_NAME}${TARGET_EXT} ${APPLICATION_SERVICES_FRAMEWORK})
ENDIF()

add_custom_command(TARGET ${TARGET_NAME}${TARGET_EXT} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${TARGET_NAME}${TARGET_EXT}> ../..
)
