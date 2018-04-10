#! /bin/bash
set -euo pipefail
# @sourcify_start
pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" > /dev/null 2>&1
source ../utils/chalk.sh
source ../utils/logger.sh
source ../utils/git_utils.sh
source ../utils/script_utils.sh
source constants.sh
source usage.sh
source utils.sh
popd > /dev/null 2>&1
# @sourcify_end

SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")

login ()
{
  local token

  ! is_auth || print_warning "Overriding existing user, type $(c_cyan "CTRL-C") to cancel."

  print_question
  read -p "Stash username: " username
  print_question
  read -s -p "Stash password: " password
  printf "\n"

  token=$(printf "%s:%s" "$username" "$password" | base64)
  set_config_prop "auth" "$token"

  print_success "Your identification token has been saved in $(c_blue "$USER_CONFIG")"
  print_success "You can now use the command $(c_cyan "$SCRIPT_NAME pr")."
  print_warning "Do not share this token."
  print_warning "Do not add it to a repository configuration file."
}

post_request_advanced ()
{
  local data="$1"
  local project="$2"
  local repo="$3"
  local token="$4"
  shift 4

  local res
  res="$(
    curl -s                                   \
         -X POST                              \
         -H 'Content-Type: application/json'  \
         -H "Authorization: Basic $token"     \
         -d "$data"                           \
         "$STASH_API_HOST/projects/$project/repos/$repo/pull-requests/"
  )"

  has_request_errors "$res" && print_request_errors "$res" "$SCRIPT_NAME" || print_request_confirmation "$res"
}

post_request_reduced ()
{
  local data="$1"
  local project="$2"
  local repo="$3"
  local token="$4"
  shift 4

  curl -s -S --fail                         \
       -o /dev/null                         \
       -X POST                              \
       -H 'Content-Type: application/json'  \
       -H "Authorization: Basic $token"     \
       -d "$data"                           \
       "$STASH_API_HOST/projects/$project/repos/$repo/pull-requests/"

 print_success "Pull request created."
}

post_request ()
{
  print_step 2 2 "Creating pull request..."
  has_jq && post_request_advanced "$@" || post_request_reduced "$@"
}

pr ()
{
  ensure_in_git "$SCRIPT_NAME" "pr"
  is_auth || print_error_and_exit "$SCRIPT_NAME" "A stash user must be logged in." "pr"

  has_jq || print_warning "Consider installing jq to display nicer feedback messages ($(c_blue "https://stedolan.github.io/jq/"))"

  local src=""
  local dst=""
  local project_src=""
  local repo_src=""
  local project_dst=""
  local repo_dst=""
  local title=""
  local commits=""
  local token=""
  local reviewers=""
  local json=""

  print_step 1 2 "Resolving repository..."

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --branch=* ) dst="${1#*=}";;
    -b )
      shift
      [[ $# -gt 0 ]] && dst="$1" || print_error_and_exit "$SCRIPT_NAME" "The branch name is missing after the option $(c_cyan "-b")." "pr"
      ;;

    --reviewer=* ) reviewers="${reviewers:+$reviewers,}$(format_user "${1#*=}")";;
    -r )
      shift
      [[ $# -gt 0 ]] && reviewers="${reviewers:+$reviewers,}$(format_user "$1")" || print_error_and_exit "$SCRIPT_NAME" "The login of the reviewer is missing after the option $(c_cyan "-r")." "pr"
      ;;

    * ) print_warning "Unknown option $(c_cyan "$1").";;
    esac
    shift
  done

  src=$(git rev-parse --abbrev-ref HEAD)
  title="$src"
  token=$(get_user_config_prop "auth")

  dst="${dst:-$(get_repo_root_config_prop "branch")}"
  dst="${dst:-master}"

  project_src=$(get_current_project)
  repo_src=$(get_current_repository)

  project_dst=$(get_repo_root_config_prop "project")
  repo_dst=$(get_repo_root_config_prop "repository")

  project_dst=${project_dst:-$project_src}
  repo_dst="${repo_dst:-$repo_src}"

  ensure_git_branch "origin/$dst" "$SCRIPT_NAME" "pr"
  commits="$(git log --pretty="    %s" "$src" --not "origin/$dst")"

  [[ -n "$commits" ]] || print_error_and_exit "$SCRIPT_NAME" "There seem to be no commit between the branch $(c_blue "$src") and $(c_blue "origin/$dst")." "pr"

  print_info "$(cat << EOF
Commits in pull request:
$commits
EOF
  )"

  reviewers="${reviewers:+$reviewers,}$(get_reviewers_from_configs)"

  json="$(cat << EOF
{
  "title": "$title",
  "description": "",
  "state": "OPEN",
  "open": true,
  "closed": false,
  "fromRef": {
    "id": "refs/heads/$src",
    "repository": {
      "slug": "$repo_src",
      "name": null,
      "project": {
        "key": "$project_src"
      }
    }
  },
  "toRef": {
    "id": "refs/heads/$dst",
    "repository": {
      "slug": "$repo_dst",
      "name": null,
      "project": {
        "key": "$project_dst"
      }
    }
  },
  "locked": false,
  "reviewers": [$reviewers]
}
EOF
  )"

  print_debug "Body: $json"

  post_request "$json" "$project_dst" "$repo_dst" "$token"
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

  login )
    script_command_bounded "$SCRIPT_NAME" "$SCRIPT_URL" "$VERSION" login "$@"
    ;;

  pr )
    script_command_bounded "$SCRIPT_NAME" "$SCRIPT_URL" "$VERSION" pr "$@"
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
