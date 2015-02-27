#!/bin/bash
if [ -f "/project/run-start" ]
then
	chmod +x /project/run-start
	/project/run-start
fi