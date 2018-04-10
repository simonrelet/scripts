#! /bin/bash
# @sourcify_start
set -euo pipefail
# @sourcify_end

# Usage: c_<color_name> <text>
c_red () { [[ -z "${CI:+x}" ]] && printf "\e[31m%s\e[0m" "$1" || printf "%s" "$1"; }
c_green () { [[ -z "${CI:+x}" ]] && printf "\e[32m%s\e[0m" "$1" || printf "%s" "$1"; }
c_yellow () { [[ -z "${CI:+x}" ]] && printf "\e[33m%s\e[0m" "$1" || printf "%s" "$1"; }
c_blue () { [[ -z "${CI:+x}" ]] && printf "\e[34m%s\e[0m" "$1" || printf "%s" "$1"; }
c_cyan () { [[ -z "${CI:+x}" ]] && printf "\e[36m%s\e[0m" "$1" || printf "%s" "$1"; }
c_grey () { [[ -z "${CI:+x}" ]] && printf "\e[90m%s\e[0m" "$1" || printf "%s" "$1"; }
c_underline () { [[ -z "${CI:+x}" ]] && printf "\e[4m%s\e[0m" "$1" || printf "%s" "$1"; }
c_bold () { [[ -z "${CI:+x}" ]] && printf "\e[1m%s\e[0m" "$1" || printf "%s" "$1"; }
