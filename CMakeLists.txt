cmake_minimum_required(VERSION 3.1)

project(NATIVE_CODE)

include_directories(
    ${NATIVE_CODE_SOURCE_DIR}
)

add_library(native_code SHARED
    native_code.c
    generated/csharp/cxx/NativeCodeWrapper.cpp
)

target_link_libraries(native_code
    -Wl, -fpic
)

install(TARGETS native_code
    DESTINATION bin
)
