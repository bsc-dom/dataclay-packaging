#!/bin/sh
if [ -f "/dataclay-initializer/state.txt" ]; then
	if [ "$(cat /dataclay-initializer/state.txt)" = "READY" ]; then
		echo "HEALTHY"
		exit 0
	else
		echo "UNHEALTHY"
		exit 1
	fi
else 
	exit 1
fi