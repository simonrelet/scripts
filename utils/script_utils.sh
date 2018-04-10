#! /bin/bash
# @sourcify_start
set -euo pipefail
pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" > /dev/null 2>&1
source chalk.sh
source logger.sh
source git_utils.sh
popd > /dev/null 2>&1
# @sourcify_end

VERSION_REGEXP="^([^.]*)\.([^.]*)\.([^.]*)$"

# Usage: print_version <version>
print_version ()
{
  local version="$1"

  printf "%s\n" "$version"
}

# Usage: get_latest_version <script_url>
get_latest_version ()
{
  local script_url="$1"

  curl -s "$script_url" | sed -n -E 's/^VERSION="(.*)"$/\1/p'
}

extract_from_version ()
{
  local version="$1"
  local part="$2"

  case "$part" in
  major ) part=1 ;;
  minor ) part=2 ;;
  patch ) part=3 ;;
  esac

  printf "%s" "$version" | sed -n -E "s/$VERSION_REGEXP/\\$part/p"
}

# Usage: has_update <current_version> <script_url>
has_update ()
{
  local current_version="$1"
  local script_url="$2"
  local remote_version
  local remote_part
  local current_part

  remote_version=$(get_latest_version "$script_url")

  [[ $? -eq 0 ]] || return 2

  for i in major minor patch
  do
    remote_part="$(extract_from_version "$remote_version" "$i")"
    current_part="$(extract_from_version "$current_version" "$i")"
    [[ "$current_part" -lt "$remote_part" ]] && return 0
    [[ "$current_part" -gt "$remote_part" ]] && return 1
  done

  return 1
}

# Usage: print_request_update
print_request_update ()
{
  print_warning "You are not using the latest version of the script."
  print_warning "Please update it using the $(c_cyan "update") command."
}

# Usage: update <script_name> <script_dir> <current_version> <script_url>
update_unbounded ()
{
  local script_name="$1"
  local script_dir="$2"
  local current_version="$3"
  local script_url="$4"

  print_info "The current version of $(c_cyan "$script_name") is $(c_blue "$current_version")."

  if has_update "$current_version" "$script_url"; then
    local latest
    local new_script
    local install_script_file
    local script_file

    latest=$(get_latest_version "$script_url")
    print_info "The version $(c_green "$latest") is available."
    print_question
    read -p "Do you want to update? (y/n [default]) " res

    [[ "$res" =~ ^(y|Y|yes) ]] || (print_warning "Update canceled by the user." && exit 1)

    print_step 1 2 "Downloading..."
    new_script=$(curl -s --fail "$script_url")
    [[ -n "$new_script" ]] || print_error_and_exit "$script_name" "Could not fetch the new version of the script." "update"

    script_file="$script_dir/$script_name"
    install_script_file="$script_dir/update_$script_name.sh"

    cp "$script_file" "$script_file.tmp"

    printf "%s\n" "$new_script" > "$script_file.tmp"

    cat > "$install_script_file" << EOF
#! /bin/bash
set -euo pipefail
mv "$script_file.tmp" "$script_file"
rm -f "\$0"
printf "%s %s\n" "$(c_green "success")" "New version has been installed."
printf "%s\n" "$(c_bold "Done")"
EOF

    print_step 2 2 "Installing..."
    exec /bin/bash "$install_script_file"
  else
    [[ $? -eq 1 ]] || print_error_and_exit "$script_name" "Cannot access scripts registry." "update"
    print_info "This script is up to date!"
  fi
}

# Usage: update <script_name> <script_dir> <current_version> <script_url>
update ()
{
  local script_name="$1"
  local current_version="$3"
  local script_url="$4"

  script_command_bounded "$script_name" "$script_url" "$current_version" update_unbounded "$@"
}

# Usage: print_no_help_entry <command> <script_name>
print_no_help_entry ()
{
  local command="$1"
  local script_name="$2"

  print_error "There are no help for the $(c_cyan "$command") command yet."
  print_info "Try using $(c_cyan "$script_name help")."
  exit 1
}

# Usage: print_update_help <script_name>
print_update_help ()
{
  local script_name="$1"

  cat << EOF
Usage: $(c_cyan "$script_name update")

Update the script to the latest version. A confirmation will be asked before the
update.
EOF
}

# Usage: print_error_and_exit <script_name> <message> [<command>]
print_error_and_exit ()
{
  local script_name="$1"
  local message="$2"
  local command="${3:-<command>}"

  # make sure $command is not empty
  [[ -n "$command" ]] || command="<command>"

  print_error "$message"
  print_info "Try using $(c_cyan "$script_name help") or $(c_cyan "$script_name help $command")"
  exit 1
}

# Usage: print_script_info <script_name> <script_dir> <version>
print_script_info ()
{
  local script_name="$1"
  local script_dir="$2"
  local version="$3"

  printf "\n%s %s %s\n" "$script_name" "$version" "$(c_grey "$script_dir/$script_name")"
}

# Usage: ensure_git_branch <branch_name> <script_name> <command>
ensure_git_branch ()
{
  local branch_name="$1"
  local script_name="$2"
  local command="$3"

  has_git_branch "$branch_name" || print_error_and_exit "$script_name" "The branch $(c_blue "$branch_name") doesn't exist." "${command:-}"
}

# Usage: ensure_in_git <script_name> <command>
ensure_in_git ()
{
  local script_name="$1"
  local command="$2"

  in_git || print_error_and_exit "$script_name" "You are not in a git repository." "${command:-}"
}

# Usage: script_command <script_url> <version> <command> [<params>]...
script_command ()
{
  local script_url="$1"
  local version="$2"
  local command="$3"
  shift 3

  [[ "$command" == "update_unbounded" ]] || (has_update "$version" "$script_url" && print_request_update) || true
  "$command" "$@"
}

# Usage: print_script_begin <script_name> <version>
print_script_begin ()
{
  local script_name="$1"
  local version="$2"

  printf "%s %s\n" "$(c_bold "$script_name")" "$(c_bold "$version")"
}

print_script_done ()
{
  printf "%s\n" "$(c_bold "Done")"
}

# Usage: script_command_bounded <script_name> <script_url> <version> <command> [<params>]...
script_command_bounded ()
{
  local script_name="$1"
  local script_url="$2"
  local version="$3"
  local command="$4"
  shift 4

  print_script_begin "$script_name" "$version"
  script_command "$script_url" "$version" "$command" "$@"
  print_script_done
}
