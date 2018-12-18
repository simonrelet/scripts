#! /bin/bash
# @sourcify_start
set -euo pipefail
pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" > /dev/null 2>&1
source ../utils/chalk.sh
source ../utils/script_utils.sh
source constants.sh
popd > /dev/null 2>&1
# @sourcify_end

# Usage: print_usage <script_name> [<exit_code>]
print_usage ()
{
  local script_name="$1"
  local exit_code="${2:-0}"

  cat << EOF
Usage $(c_cyan "$script_name <port> [options]")

Free the port by killing all processes using it.

Options:
    $(c_cyan "-f"), $(c_cyan "--force")  Force kill
EOF

  print_script_info "$script_name" "$SCRIPT_DIR" "$VERSION"
  exit $exit_code
}
