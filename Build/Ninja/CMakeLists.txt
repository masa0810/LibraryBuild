cmake_minimum_required(VERSION 3.8.2)

project(ninja)
string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)

include(ExternalProject)
ExternalProject_Add(
    ${PROJECT_NAME}
    SOURCE_DIR ${NINJA_SRC}
    BUILD_COMMAND ${PYTHON_EXECUTABLE} bootstrap.py --platform msvc
)