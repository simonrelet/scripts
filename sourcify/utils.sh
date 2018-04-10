#! /bin/bash
# @sourcify_start
set -euo pipefail
pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" > /dev/null 2>&1
source constants.sh
popd > /dev/null 2>&1
# @sourcify_end

# Usage: abs_dirname <relative_file_path>
abs_dirname ()
{
  local relative_file_path="$1"

  printf "%s" "$(cd "$(dirname "$relative_file_path")"; pwd)"
}

# Usage: file_already_sourced <file_path> <sourced_files>
file_already_sourced ()
{
  local file_path="$1"
  local sourced_files="$2"
  local existing_path=""

  existing_path="$(printf "%s" "$sourced_files" | sed -n -E "s#.*($file_path).*#\1#p")"
  [[ -n "$existing_path" ]] || return 1
  return 0
}
