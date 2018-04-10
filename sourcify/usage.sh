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
Usage: $(c_cyan "$script_name <file>")
       $(c_cyan "$script_name <command>")

Resolve and replace $(c_cyan "source") and $(c_cyan ".") commands by the content of the file.

This allows to modularize scripts in order to simplify their development and
to still release them in a single file. Each file will only be sourced once.

When a $(c_cyan "<file>") is given, the sourcified result will be printed on the standard
output.

Sourcify blocks can be used to remove all non $(c_cyan "source") commands inside it. This
allows to execute instructions that are only relevent when the script is still
modularized. The block starts by the comments $(c_grey "# @sourcify_start") and ends at
$(c_grey "# @sourcify_end") or at the end of the file. These comments must be on
their own line. Do not use variables declared in the sourcify block, they will
also be removed.

Only the shebang of the main script will be kept, all other will be ignored.

The paths are relative to the sourcing file and must be static.

Example:
    $ $(c_cyan "cat utils.sh")
    #! /bin/bash
    greetings () { printf "Hello!\n"; }
    $ $(c_cyan "cat main.sh")
    #! /bin/bash
    # @sourcify_start
    # ensure we source utils.sh relatively to the current script folder
    pushd "\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)" > /dev/null 2>&1
    source utils.sh
    popd > /dev/null 2>&1
    # @sourcify_end
    greetings
    $ $(c_cyan "$script_name main.sh")
    #! /bin/bash
    # [...]
    # @sourcify_start: utils.sh
    greetings () { printf "Hello!\n"; }
    # @sourcify_end: utils.sh
    greetings

Commands:
    $(c_cyan "help")     Show this help
    $(c_cyan "update")   Update the script to the latest version
    $(c_cyan "version")  Show the version of this script

The output is colored by default but will automatically be turned off in a CI
environment (where the $(c_cyan "CI") environment variable is set).

Some commands have a help that can be displayed:
    $(c_cyan "$script_name help <command>")
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
