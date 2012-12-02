#!/bin/bash

# script to fix issue in stackato cli
# malformed json output when calling 
# stats option


# stackato@stackato-z5xy:~$ stackato stats "env" --json
# env				<<< --- NEED TO REMOVE THIS (FIRST) LINE FROM OUTPUT
# [{
#     "instance" : "0",
#     "state"    : "RUNNING",
#     "stats"    : {
#         "cores"      : "1",
#         "disk_quota" : "2147483648",
#         "fds_quota"  : "256",
#         "host"       : "10.0.0.6",
#         "mem_quota"  : "134217728",
#         "name"       : "env",
#         "port"       : "41749",
#         "uptime"     : "20588.712514111",
#         "uris"       : ["env.stackato-z5xy.local"],
#         "usage"      : {
#             "cpu"  : "0.0",
#             "disk" : "4550656",
#             "mem"  : "4460.0",
#             "time" : "2012-11-29 07:36:39 -0800"
#         }
#     }
# }]

 
# stackato@stackato-gkg8:~/stackato_stats$ sta stats "perlcritic" --json | json_pp
# malformed JSON string, neither array, object, number, string or atom, at character offset 0 (before "perlcritic\n[{\n    ...") at /usr/bin/json_pp line 44


if [ -z $1 ]; then
	echo "ERROR: Require app name"
	echo "Usage: $0 <app>"
	exit
fi

stackato stats $1 --json |grep -vE "^$1$"
exit 0
