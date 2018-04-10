#! /bin/bash
# @sourcify_start
set -euo pipefail
pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" > /dev/null 2>&1
source ../utils/script_utils.sh
source constants.sh
popd > /dev/null 2>&1
# @sourcify_end

# Usage: get_repo_config_files
get_repo_config_files ()
{
  local current_dir
  local repo_root

  current_dir="$(pwd)"
  repo_root="$(git rev-parse --show-toplevel)"

  while : ; do
    current_config="$current_dir/$CONFIG_FILE_NAME"
    [[ ! -f "$current_config" ]] || {
      printf "%s\n" "$current_config"
    }

    [[ "$current_dir" != "$repo_root" ]] || break
    current_dir="$(dirname "$current_dir")"
  done
}

# Usage: get_repo_root_config_file
get_repo_root_config_file ()
{
  printf "%s" "$(git rev-parse --show-toplevel)/$CONFIG_FILE_NAME"
}

# Usage: get_config_prop <config_file> <prop_name>
get_config_prop ()
{
  local config_file="$1"
  local prop_name="$2"

  [[ -f "$config_file" ]] && sed -n -E "s/^$prop_name=(.*)$/\1/p" "$config_file" || printf ""
}

# Usage: get_user_config_prop <prop_name>
get_user_config_prop ()
{
  local prop_name="$1"

  get_config_prop "$USER_CONFIG" "$prop_name"
}

# Usage: get_repo_root_config_prop <prop_name>
get_repo_root_config_prop ()
{
  local prop_name="$1"

  get_config_prop "$(get_repo_root_config_file)" "$prop_name"
}

# Usage: get_repo_reviewers
get_repo_reviewers ()
{
  for repo_config_file in $(get_repo_config_files)
  do
    get_config_prop "$repo_config_file" "reviewer"
  done
}

# Usage: set_config_prop <prop_name> <prop_value>
set_config_prop ()
{
  local prop_name="$1"
  local prop_value="$2"
  local without=""

  [[ -f "$USER_CONFIG" ]] && without=$(sed -n "/^$prop_name=/!p" "$USER_CONFIG")
  printf "%s%s=%s\n" "${without:+without\n}" "$prop_name" "$prop_value" > "$USER_CONFIG"
}

# Usaget_: reviewers_from_configs
get_reviewers_from_configs ()
{
  local reviewers=""

  for rev in $(get_repo_reviewers)
  do
    reviewers="${reviewers:+$reviewers,}$(format_user $rev)"
  done

  printf "%s" "$reviewers"
}

# Usage: is_auth
is_auth ()
{
  local auth
  auth=$(get_user_config_prop "auth")

  [[ -z "$auth" ]] || return 0
  return 1
}

# Usage: has_jq
has_jq ()
{
  jq --version > /dev/null 2>&1 || return 1
  return 0
}

# Usage: format_user <stash_login>
format_user ()
{
  local stash_login="$1"

  printf '{ "user": { "name": "%s" }}' "$stash_login"
}

# Usage: has_request_errors <json_result>
has_request_errors ()
{
  local json_result="$1"

  [[ "$(printf "%s" "$json_result" | jq -M .errors)" == "null" ]] || return 0
  return 1
}

# Usage: clean_message
clean_message ()
{
  sed -n -E "s/^\"(.*)\"$/\1/p" | sed -E "s/\\\\\"/\"/g"
}

# Usage: print_request_errors <json_result> <script_name>
print_request_errors ()
{
  local json_result="$1"
  local script_name="$2"
  local messages

  messages="$(printf "%s" "$json_result" | jq -M '.errors[].message' | clean_message | sed -n -E "s/^(.*)/    \1/p")"

  print_error_and_exit "$script_name" "$(cat << EOF
Pull request creation failed:
$messages
EOF
  )" "pr"
}

# Usage: print_request_confirmation <json_result>
print_request_confirmation ()
{
  local json_result="$1"
  local url

  url="$(printf "%s" "$json_result" | jq -M .links.self[0].href | clean_message)"

  print_success "$(cat << EOF
Pull request created:
    $(c_blue "$url")
EOF
  )"
}
