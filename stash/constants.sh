#! /bin/bash
# @sourcify_start
set -euo pipefail
# @sourcify_end

VERSION="5.0.2"
CONFIG_FILE_NAME=".stashrc"
USER_CONFIG="$HOME/$CONFIG_FILE_NAME"
STASH_API_HOST="https://git@stash.murex.com/rest/api/1.0"
SCRIPT_URL="https://raw.githubusercontent.com/simonrelet/scripts/stash-latest/bin/stash.sh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
