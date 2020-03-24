#!/bin/sh

function usage
{
    CMDNAME=`basename $0`
    cat <<- __EOS
Usage: ${CMDNAME} [[-l | --lang] csharp] (required)
                  [[-p | --platform] macos,windows] (required)
                  [-h | --help]
Option:
    -l  --lang      programming language
    -p  --platform  specify the target platform
    -h  --help      view help
__EOS
}

if [ -z $1 ]; then
    usage
    exit 1
fi

USE_CSHARP_FLAG=0
NOT_SET_LANG=0
NOT_SET_PLATFORM=0
PLATFORM_TYPE=""
DLL_IMPORT_NAME=""

while [ "$1" != "" ]; do
    case $1 in
        -l | --lang )       shift
                            if [ "$1" = "csharp" ]; then
                                USE_CSHARP_FLAG=1
                            else
                                NOT_SET_LANG=1
                            fi
                            ;;
        -p | --platform )   shift
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


SCRIPT_DIR=$(cd $(dirname $0) && pwd)
WORKSPACE_DIR=$(cd ${SCRIPT_DIR}/.. && pwd)
GEN_DIR=${WORKSPACE_DIR}/generated

CSHARP_BINDING_DIR=${WORKSPACE_DIR}/swig/csharp
CSHARP_GEN_ROOT_DIR=${GEN_DIR}/csharp
CSHARP_CS_GEN_DIR=${CSHARP_GEN_ROOT_DIR}/cs
CSHARP_CXX_GEN_DIR=${CSHARP_GEN_ROOT_DIR}/cxx


if [ $USE_CSHARP_FLAG = 1 ]; then
    # delete generated folder
    if [ -e ${CSHARP_GEN_ROOT_DIR} ]; then
        echo "delete csharp generated folder..."
        rm -rf ${CSHARP_GEN_ROOT_DIR}
    fi

    # generate csharp bindig
    mkdir -p ${CSHARP_GEN_ROOT_DIR}
    mkdir -p ${CSHARP_CS_GEN_DIR}
    mkdir -p ${CSHARP_CXX_GEN_DIR}

    # generate c++ wrapper and c# using swig
    echo "generate cxx wrapper and csharp using swig..."
    swig -csharp -v \
        -namespace SwigTest \
        -dllimport ${DLL_IMPORT_NAME} \
        -I"${SCRIPT_DIR}" \
        -outdir ${CSHARP_CS_GEN_DIR} \
        -o ${CSHARP_CXX_GEN_DIR}/NativeCodeWrapper.cpp \
        ${CSHARP_BINDING_DIR}/native_code.i
fi
