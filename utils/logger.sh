#! /bin/bash
# @sourcify_start
set -euo pipefail
pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" > /dev/null 2>&1
source chalk.sh
popd > /dev/null 2>&1
# @sourcify_end

# Usage: print_<type> <message>
print_error ()
{
  local message="$1"

  printf "%s %s\n" "$(c_red "error")" "$message" 1>&2
}

print_warning ()
{
  local message="$1"

  printf "%s %s\n" "$(c_yellow "warning")" "$message" 1>&2
}

print_success ()
{
  local message="$1"

  printf "%s %s\n" "$(c_green "success")" "$message"
}

print_info ()
{
  local message="$1"

  printf "%s %s\n" "$(c_blue "info")" "$message"
}

print_debug ()
{
  local message="$1"

  [[ -z "${DEBUG:+x}" ]] || printf "%s %s\n" "$(c_yellow "debug")" "$message"
}

# Usage: print_step <current_step> <step_count> <message>
print_step ()
{
  local current_step="$1"
  local step_count="$2"
  local message="$3"

  printf "%s %s\n" "$(c_grey "[$current_step/$step_count]")" "$message"
}

# Usage: print_question
print_question ()
{
  printf "%s " "$(c_grey "question")"
}
