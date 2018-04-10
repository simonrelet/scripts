#! /bin/bash
# @sourcify_start
set -euo pipefail
pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" > /dev/null 2>&1
source ../utils/chalk.sh
source ../utils/script_utils.sh
source constants.sh
popd > /dev/null 2>&1
# @sourcify_end

# Usage: print_usage <name> <script_name> [<exit_code>]
print_usage ()
{
  local command="$1"
  local script_name="$2"
  local exit_code="${3:-0}"

  case "$command" in
  global )
    cat << EOF
Usage $(c_cyan "$script_name <command>")

Handle utility commands for NodeJS.

Commands:
    $(c_cyan "help")     Show helps
    $(c_cyan "ln")       Link packages
    $(c_cyan "update")   Update the script to the latest version
    $(c_cyan "version")  Show the version of this script

The output is colored by default but will automatically be turned off in a CI
environment (where the $(c_cyan "CI") environment variable is set).

Some commands have a help that can be displayed:
    $(c_cyan "$script_name help <command>")
EOF
    ;;

  ln )
    cat << EOF
Usage: $(c_cyan "$script_name ln <package>")

Create a symbolic link from a given package to its corresponding folder under
$(c_blue "node_modules/"). This allows working on both packages without the need
of reinstalling them.

This command will not install the package but simply replace the installed
folder with a symbolic link. It also works with scoped packages.

Example:
    \$ $(c_cyan "pwd")
    /packages/awesome-feature
    \$ $(c_cyan "$script_name ln ../common-package/dist")
    $(c_grey "# now all changes in /packages/common-package/dist will be visible in")
    $(c_grey "# /packages/awesome-feature/node_modules/@murex/common-package")
EOF
    ;;

  update )
    print_update_help "$script_name"
    ;;

  * )
    [[ "$exit_code" -ne 0 ]] || exit_code=1
    print_no_help_entry "$command" "$script_name"
    ;;
  esac

  print_script_info "$script_name" "$SCRIPT_DIR" "$VERSION"
  exit $exit_code
}
