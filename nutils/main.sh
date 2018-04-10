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

# Usage: get_from_pkg <package_file> <field_name>
get_from_pkg ()
{
  local package_file="$1"
  local field_name="$2"

  cat "$package_file" | sed -n -E "s/.*\"$field_name\".*:.*\"(.*)\".*/\1/p"
}

# Usage: link_package <other_package>
link_package ()
{
  [[ $# -eq 1 ]] || print_error_and_exit "$SCRIPT_NAME" "The path of the package to link is missing." "ln"

  local other_package_dir="${1%/package.json}"
  other_package_dir="${other_package_dir%/}"
  local other_package_file="$other_package_dir/package.json"
  local other_package_abs_dir
  local other_package_abs_file
  local other_package_name
  local other_package_version
  local other_package_scope
  local dst_dir="node_modules"

  print_step 1 2 "Resolving packages..."

  [[ -f "$(pwd)/package.json" ]] || print_error_and_exit "$SCRIPT_NAME" "You are not in a node package." "ln"
  [[ -f "$other_package_file" ]] || print_error_and_exit "$SCRIPT_NAME" "The file $(c_blue "$other_package_file") doesn't exist." "ln"

  other_package_abs_dir="$(cd "$other_package_dir" && pwd)"
  other_package_abs_file="$other_package_abs_dir/package.json"

  other_package_name="$(get_from_pkg "$other_package_abs_file" name)"
  other_package_version="$(get_from_pkg "$other_package_abs_file" version)"
  [[ -n "$other_package_name" ]] || print_error_and_exit "$SCRIPT_NAME" "Make sure that $(c_blue "$other_package_file") contains a $(c_cyan "name") field." "ln"
  [[ -n "$other_package_version" ]] || print_error_and_exit "$SCRIPT_NAME" "Make sure that $(c_blue "$other_package_file") contains a $(c_cyan "version") field." "ln"

  print_debug "Found node package $(c_cyan "$other_package_name@$other_package_version")"

  rm -rf "node_modules/$other_package_name"
  other_package_scope="$(dirname "$other_package_name")"
  dst_dir="${other_package_scope:+$dst_dir/$other_package_scope}"

  print_step 2 2 "Linking packages..."

  [[ -d "$dst_dir" ]] || mkdir "$dst_dir"
  ln -s "$other_package_abs_dir" "$(pwd)/node_modules/$other_package_name"

  print_success "Package $(c_cyan "$other_package_name@$other_package_version") has been linked."
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

  ln )
    script_command_bounded "$SCRIPT_NAME" "$SCRIPT_URL" "$VERSION" link_package "$@"
    ;;

  update )
    update "$SCRIPT_NAME" "$SCRIPT_DIR" "$VERSION" "$SCRIPT_URL"
    ;;

  * )
    print_error_and_exit "$SCRIPT_NAME" "Unknown command $(c_cyan "$cmd")."
    ;;
  esac
}

main "$@"
