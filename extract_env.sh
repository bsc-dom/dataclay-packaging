#! /bin/bash
# Script to extract env variables from Dockerfiles (needed for Singularity)
# Syntax for specifying environment variables needed at runtime:
#   #beginENVruntime
#   .... dockerfile commands ...
#   ENV var0=aaa
#   .... dockerfile commands ...
#   ENV var1=bbb
#   .... dockerfile commands ...
#   #endENVruntime

if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
	echo 'Usage: ./$0 <Dockerfile_path>'
else
	sed -n '/#beginENVruntime/,/#endENVruntime/p' $1 | grep ^ENV
fi
