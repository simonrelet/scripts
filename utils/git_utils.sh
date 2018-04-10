#! /bin/bash
# @sourcify_start
set -euo pipefail
# @sourcify_end

# Usage: in_git
in_git ()
{
  git rev-parse --is-inside-work-tree > /dev/null 2>&1 || return 1
  return 0
}

# Usage: has_git_branch <branch_name>
has_git_branch ()
{
  local branch_name="$1"

  git rev-parse --verify "$branch_name" > /dev/null 2>&1 || return 1
  return 0
}

# Usage: get_remote_origin_url
# Examples:
#     ssh://git@stash.murex.com:7999/<project>/<repository>.git
#     https://git@stash.murex.com/scm/<project>/<repository>.git
get_remote_origin_url ()
{
  git config --get remote.origin.url
}

# Usage: get_current_project
get_current_project ()
{
  get_remote_origin_url | sed -n -E "s#.*/([^/]*)/[^/]*.git#\1#p"
}

# Usage: get_current_repository
get_current_repository ()
{
  get_remote_origin_url | sed -n -E "s#.*/([^/]*).git#\1#p"
}
