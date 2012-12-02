#!/bin/bash

ncpus=$(grep -c processor /proc/cpuinfo)
memsizekb=$(awk '/^MemTotal/ {print $2;}' /proc/meminfo)

echo -en "Processors $ncpus\n"
echo -en "MemoryKB $memsizekb\n"
