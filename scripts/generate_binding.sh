#!/bin/sh

function usage
{
    CMDNAME=`basename $0`
    cat <<- __EOS
Usage: ${CMDNAME} [[-l | --lang] csharp] (required)
                  [-h | --help]
Option:
    -l  --lang      programming language       
    -h  --help      view help
__EOS
}

if [ -z $1 ]; then
    usage
    exit 1
fi

USE_CSHARP_FLAG=0
NOT_SET_LANG=0

while [ "$1" != "" ]; do
    case $1 in
        -l | --lang )       shift
                            if [ "$1" = "csharp" ]; then
                                USE_CSHARP_FLAG=1
                            else
                                NOT_SET_LANG=1
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

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
WORKSPACE_DIR=$(cd ${SCRIPT_DIR}/.. && pwd)
GEN_DIR=${WORKSPACE_DIR}/generated

CSHARP_BINDING_DIR=${WORKSPACE_DIR}/csharp
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
        -namespace NativeCode \
        -dllimport libnative_code_csharp.dll \
        -I"${SCRIPT_DIR}" \
        -outdir ${CSHARP_CS_GEN_DIR} \
        -o ${CSHARP_CXX_GEN_DIR}/NativeCodeWrapper.cpp \
        ${CSHARP_BINDING_DIR}/native_code.i
fi
