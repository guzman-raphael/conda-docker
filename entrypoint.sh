#!/usr/bin/env sh

#Fix UID/GID
/startup $(id -u) $(id -g)

#Command
# sh -l $@
# eval "$(/opt/conda/bin/conda shell.bash hook)"
# export PATH=/usr/local/bin:/home/dja/.local/bin:$PATH
. /etc/profile.d/shell_intercept.sh
"$@"