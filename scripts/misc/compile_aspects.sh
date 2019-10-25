#!/bin/bash

if [ $# -ne 4 ]; then 
	echo "ERROR: missing arguments. Usage $0 <aspectjrt.jar> <aspects dir> <classpath> <dest jar>"
	exit -1
fi

# Checking Java version 
version=$("java" -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')
if (("$version" > "9")); then       
	echo "Cannot apply aspects since Java version is > 1.9"
	exit 0
fi

ASPECTJ_RT=$1
ASPECTS_DIR=$2
CLASSPATH=$3
DEST_JAR=$4

ajc ${ASPECTS_DIR}/*.aj -cp ${ASPECTJ_RT}:${CLASSPATH} -outxml -outjar ${DEST_JAR}



