#!/bin/sh

function usage
{
    CMDNAME=`basename $0`
    cat <<- __EOS
Usage: ${CMDNAME} [[-l | --lang] csharp] (required)
                  [[-p | --platform] macos,windows] (required)
                  [-g | --generate]
                  [-h | --help]
Option:
    -l  --lang      programming language
    -p  --platform  specify the target platform
    -g  --generate  generate binding layer
    -h  --help      view help
__EOS
}

if [ -z $1 ]; then
    usage
    exit 1
fi

USE_CSHARP_FLAG=0
USE_GENERATE_FLAG=0
NOT_SET_LANG=0
NOT_SET_PLATFORM=0
PLATFORM_TYPE=""
DLL_IMPORT_NAME=""

ARG_LANGUAGE=""
ARG_PLATFORM=""

while [ "$1" != "" ]; do
    case $1 in
        -l | --lang )       shift
                            ARG_LANGUAGE="$1"
                            if [ "$1" = "csharp" ]; then
                                USE_CSHARP_FLAG=1
                            else
                                NOT_SET_LANG=1
                            fi
                            ;;
        -p | --platform )   shift
                            ARG_PLATFORM="$1"
                            if [ "$1" = "macos" ]; then
                                PLATFORM_TYPE="macos"
                                DLL_IMPORT_NAME="libnative_code.dylib"
                            elif [ "$1" = "windows" ]; then
                                PLATFORM_TYPE="windows"
                                DLL_IMPORT_NAME="libnative_code.dll"
                            else
                                NOT_SET_PLATFORM=1
                            fi
                            ;;
        -g | --generate )   shift
                            USE_GENERATE_FLAG=1
                            ;;
        -h | --help )       usage
                            exit
                            ;;
        * )                 usage
                            exit 1
    esac
    shift
done

if [ $NOT_SET_LANG = 1 ]; then
    echo "[Error] Not support lang\n"
    usage
    exit 1
fi

if [ $NOT_SET_PLATFORM = 1 ]; then
    echo "[Error] Not support platform\n"
    usage
    exit 1
fi

# default path
SCRIPT_DIR=$(cd $(dirname $0) && pwd)
WORKSPACE_DIR=$(cd ${SCRIPT_DIR}/.. && pwd)
SAMPLE_DIR=${WORKSPACE_DIR}/sample
BUILD_DIR=${WORKSPACE_DIR}/build
BIN_DIR=${WORKSPACE_DIR}/bin
GEN_DIR=${WORKSPACE_DIR}/generated

# path for csharp
CSHARP_SAMPLE_DIR=${SAMPLE_DIR}/csharp
CSHARP_GEN_ROOT_DIR=${GEN_DIR}/csharp
CSHARP_CS_GEN_DIR=${CSHARP_GEN_ROOT_DIR}/cs

if [ $USE_GENERATE_FLAG = 1 ]; then
    echo "========================================"
    echo "generate binding layer"
    echo "bind language : $ARG_LANGUAGE"
    echo "bind platform : $ARG_PLATFORM"
    echo "========================================"
    sh ${WORKSPACE_DIR}/scripts/gen_binding.sh -l ${ARG_LANGUAGE} -p ${ARG_PLATFORM}
fi

# delete build and bin folder
if [ -e ${BUILD_DIR} ]; then
    echo "delete build folder...."
    rm -rf ${BUILD_DIR}
fi

if [ -e ${BIN_DIR} ]; then
    echo "delete bin folder...."
    rm -rf ${BIN_DIR}
fi

# create build
mkdir -p ${BUILD_DIR}

# csharp build
if [ $USE_CSHARP_FLAG = 1 ]; then
    echo "=============================================="
    echo "Sample build"
    echo "build language : $ARG_LANGUAGE"
    echo "build platform : $ARG_PLATFORM"
    echo "=============================================="
    # native code and wrapper code build using CMake
    cd ${BUILD_DIR}
    cmake -DCMAKE_INSTALL_PREFIX=${WORKSPACE_DIR} ..
    make
    make install
    cd ${WORKSPACE_DIR}

    # csharp sample build
    if [ $PLATFORM_TYPE = "macos" ]; then
        mcs ${CSHARP_CS_GEN_DIR}/*.cs ${CSHARP_SAMPLE_DIR}/*.cs -nologo -debug+ -unsafe -out:${BIN_DIR}/SwigTestSample.exe
    elif [ $PLATFORM_TYPE = "windows" ]; then
        echo "todo: windows build implement..."
    fi
fi
