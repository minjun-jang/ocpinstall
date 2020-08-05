#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

rm -rf ${ABSOLUTE_PATH}/client/*
rm -rf ${ABSOLUTE_PATH}/install/*
rm -rf ${ABSOLUTE_PATH}/rhcos/*
#rm -rf ${ABSOLUTE_PATH}/repos/rhel*
rm -rf ${ABSOLUTE_PATH}/*.out
