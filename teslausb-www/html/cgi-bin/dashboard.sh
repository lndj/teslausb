#!/bin/bash

# Get some dashboard data
# Includes:
#   1. Vedio numbers & size
#   2. Latest sync info
#   3. Sync times in history
#   4. Current system info: wifi / Music / Sync status etc.
#   5. And more ...

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/env.sh"
source "$SHELL_FOLDER/util.sh"

# 