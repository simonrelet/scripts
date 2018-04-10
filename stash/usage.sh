#! /bin/bash
# @sourcify_start
set -euo pipefail
pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" > /dev/null 2>&1
source ../utils/chalk.sh
source ../utils/script_utils.sh
source constants.sh
popd > /dev/null 2>&1
# @sourcify_end

# Usage: print_usage <cmd> <script_name> [<exit_code>]
print_usage ()
{
  local command="$1"
  local script_name="$2"
  local exit_code="${3:-0}"

  case "$command" in
  global )
    cat << EOF
Usage: $(c_cyan "$script_name <command>")

Handle Stash API through various commands.

Commands:
    $(c_cyan "help")     Show helps
    $(c_cyan "login")    Save credentials in the user configuration file
    $(c_cyan "pr")       Create a pull request
    $(c_cyan "update")   Update the script to the latest version
    $(c_cyan "version")  Show the version of this script

Specify the user configurations in the ini-formatted file:
    $(c_blue "$USER_CONFIG")

And repository configurations in any ini-formatted files:
    $(c_blue "/path/to/git/repository/**/$CONFIG_FILE_NAME")

You can set the environment variable $(c_cyan "DEBUG") to display debug information:
    $(c_cyan "env DEBUG=true $script_name <command>")

The output is colored by default but will automatically be turned off in a CI
environment (where the $(c_cyan "CI") environment variable is set).

Some commands have a help that can be displayed:
    $(c_cyan "$script_name help <command>")
EOF
    ;;

  login )
    cat << EOF
Usage: $(c_cyan "$script_name login")

Save credentials of a Stash user in the user configuration file:
    $(c_blue "$USER_CONFIG")

The credentials must never be added in a repository configuration file.
EOF
    ;;

  pr )
    cat << EOF
Usage: $(c_cyan "$script_name pr [options]")

Create a pull request from the current branch to the a specific branch of a
specific repository. A Stash user must be logged in with the $(c_cyan "login") command.

Options:
    $(c_cyan "-b"), $(c_cyan "--branch=name")     Destination branch
    $(c_cyan "-r"), $(c_cyan "--reviewer=login")  Login of a reviewer, can be repeated

The options will override the values set in the configuration files, except for
the $(c_cyan "--reviewer") which will be merged. Arguments of long options are also required
for short options.

The repository root configuration file can contain the following variables:
    $(c_cyan "branch")      Destination branch, 'master' by default
    $(c_cyan "project")     Project name, the current one by default
    $(c_cyan "repository")  Repository name, the current one by default
    $(c_cyan "reviewer")    Login of a reviewer, can be repeated

Any other configuration file in the repository can contain the following
variables:
    $(c_cyan "reviewer")  Login of a reviewer, can be repeated

The list of reviewers will be the result of the merge of all the repository
configuration files, starting from the current folder and ending at the root
of the repository.

Any repository allowing pull requests from forks should set the $(c_cyan "project") and
$(c_cyan "repository") variables.

Example of repository root configuration file:
    project=ui
    repository=web-library
    reviewer=srelet
    reviewer=pbeitz

Also work with private repositories:
    project=~srelet
    repository=dev-scripts
    branch=dev
    reviewer=srelet
    reviewer=pbeitz

Any valid Stash login can be used as reviewer, even the current user. It will
simply be ignored by Stash.

This command can be used from any sub-folder of a git repository. If you are in
a submodule, the pull request will be created for the submodule using its own
configuration files.

Example:
    $(c_grey "# srelet is the login of the current Stash user")
    \$ $(c_cyan "cd /path/to/git/repository/")
    \$ $(c_cyan "cat $CONFIG_FILE_NAME")
    project=~srelet
    repository=awesome
    reviewer=pbeitz
    reviewer=srelet
    \$ $(c_cyan "cd /sub/folder/")
    \$ $(c_cyan "cat $CONFIG_FILE_NAME")
    reviewer=ftingaud
    \$ $(c_cyan "$script_name pr -r yfomena")
    $(c_grey "# create a pull request with the reviewers: 'ftingaud', 'pbeitz' and")
    $(c_grey "# 'yfomena' for the repository 'awesome' in the '~srelet' project")
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
