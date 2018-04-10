#! /bin/bash
set -euo pipefail
# @sourcify_start
pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" > /dev/null 2>&1
source ../utils/script_utils.sh
source ../utils/chalk.sh
source constants.sh
source usage.sh
source utils.sh
popd > /dev/null 2>&1
# @sourcify_end

SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
SOURCED_FILES=""

# Usage: handle_source <source_line> <current_file_name>
handle_source ()
{
  local source_line="$1"
  local current_file_name="$2"
  local current_file_abs_path=""
  local file_relative_path=""
  local file_basename=""
  local file_dirname=""

  current_file_abs_path="$(pwd)/$current_file_name"
  file_relative_path="$(printf "%s" "$source_line" | cut -d' ' -f2)"
  file_basename="$(basename "$file_relative_path")"
  file_dirname="$(abs_dirname "$file_relative_path")"
  file_abs_path="$file_dirname/$file_basename"

  [[ -f "$file_relative_path" ]] || {
    print_error "In $(c_underline "$current_file_abs_path"):"
    print_error_and_exit "The file $(c_blue "$file_abs_path") doesn't exist."  "$SCRIPT_NAME"
  }

  file_already_sourced "$file_abs_path" "$SOURCED_FILES" || {
    SOURCED_FILES="${SOURCED_FILES:+$SOURCED_FILES }$file_abs_path"

    printf "# @sourcify_start: %s\n" "$file_basename"
    bundle_file "$file_dirname" "$file_basename"
    printf "# @sourcify_end: %s\n" "$file_basename"
  }
}

# Usage: bundle_file <abs_path> <file_name>
bundle_file ()
{
  local abs_path="$1"
  local file_name="$2"
  local in_source_block=false

  pushd "$abs_path" > /dev/null 2>&1

  # `IFS=''`: prevents leading/trailing whitespace from being trimmed
  # `-r`: prevents backslash escapes from being interpreted.
  # `|| [[ -n $line ]]`: prevents the last line from being ignored if it doesn't
  # end with a `\n` (since `read` returns a non-zero exit code when it
  # encounters EOF).
  while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ "$in_source_block" = true ]]; then
      case "$line" in
      .*|source* )
        handle_source "$line" "$file_name"
        ;;

      "# @sourcify_end" )
        in_source_block=false
        ;;

      * )
        # don't print it
        ;;
      esac
    else
      case "$line" in
      "# @sourcify_start" )
        in_source_block=true
        ;;

      .*|source* )
        handle_source "$line" "$file_name"
        ;;

      \#!* )
        [[ $# -eq 2 ]] || printf "%s\n%s\n\n" "$line" "$WARNING_COMMENT"
        ;;

      * )
        printf "%s\n" "$line"
        ;;
      esac
    fi
  done < "$file_name"

  popd > /dev/null 2>&1
}

# Usage: sourcify <relative_file_path>
sourcify ()
{
  local relative_file_path="$1"
  local res=""

  [[ -f "$relative_file_path" ]] || print_error_and_exit "$SCRIPT_NAME" "The file $(c_blue "$relative_file_path") doesn't exists or isn't a file."

  res="$(bundle_file "$(abs_dirname "$relative_file_path")" "$(basename "$relative_file_path")" true)"
  printf "%s\n" "$res"
}

main ()
{
  [[ $# -gt 0 ]] || print_usage "global" "$SCRIPT_NAME" 1

  local cmd="$1"
  shift

  case "$cmd" in
  -h|--help|help )
    script_command "$SCRIPT_URL" "$VERSION" print_usage "${1:-global}" "$SCRIPT_NAME"
    ;;

  -v|--version|version )
    print_version "$VERSION"
    ;;

  update )
    update "$SCRIPT_NAME" "$SCRIPT_DIR" "$VERSION" "$SCRIPT_URL"
    ;;

  * )
    sourcify "$cmd"
    ;;
  esac
}

main "$@"
