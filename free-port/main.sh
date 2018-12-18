#! /bin/bash
set -euo pipefail
# @sourcify_start
pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" > /dev/null 2>&1
source ../utils/chalk.sh
source ../utils/logger.sh
source ../utils/script_utils.sh
source constants.sh
source usage.sh
popd > /dev/null 2>&1
# @sourcify_end

SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")

# Usage: free_port <port> [options]
free_port ()
{
  local port=":$1"
  local kill_options=""
  shift

  while [[ $# -gt 0 ]]; do
    case "$1" in
    -f|--force ) kill_options="-9";;
    * ) print_warning "Unknown option $(c_cyan "$1").";;
    esac
    shift
  done

  lsof -t -i "$port" | xargs kill "$kill_options"
}

main ()
{
  [[ $# -gt 0 ]] || print_usage "$SCRIPT_NAME" 1

  local cmd="$1"

  case "$cmd" in
  -h|--help|help )
    script_command "$SCRIPT_URL" "$VERSION" print_usage "$SCRIPT_NAME"
    ;;

  -v|--version|version )
    print_version "$VERSION"
    ;;

  update )
    update "$SCRIPT_NAME" "$SCRIPT_DIR" "$VERSION" "$SCRIPT_URL"
    ;;

  * )
    script_command_bounded "$SCRIPT_NAME" "$SCRIPT_URL" "$VERSION" free_port "$@"
    ;;
  esac
}

main "$@"
