#!/usr/bin/env bash
#=============================================================================
#     FileName : fzf.bash
#       Author : marslo.jiao@gmail.com
#      Created : 2025-05-08 18:18:10
#   LastChange : 2025-06-23 16:08:41
#=============================================================================

# @credit: https://github.com/ppo/bash-colors
# shellcheck disable=SC2015,SC2059
function c() { [ $# == 0 ] && printf "\e[0m" || printf "$1" | sed 's/\(.\)/\1;/g;s/\([SDIUFNHT]\)/2\1/g;s/\([KRGYBMCW]\)/3\1/g;s/\([krgybmcw]\)/4\1/g;y/SDIUFNHTsdiufnhtKRGYBMCWkrgybmcw/12345789123457890123456701234567/;s/^\(.*\);$/\\e[\1m/g'; }

declare -a subcommands=(show edit rm)
# shellcheck disable=SC2155
declare -r ME="$(basename "${BASH_SOURCE[0]:-$0}" | sed 's/\.[^.]*$//')"
# shellcheck disable=SC2001,SC2155
declare usage="""
USAGE
  $(c Ys)\$ pass ${ME}$(c) $(c 0Wdi)[$(c 0Gi)OPTIONS$(c 0Wdi)] [$(c 0Mi)SUB_COMMAND$(c)$(c 0Wdi)] [$(c 0Bi)QUERY$(c 0Wdi)]$(c)

OPTIONS
  $(c G)-s$(c)           only output selected path $(c 0i)without$(c) run $(c 0Yi)'pass'$(c)
  $(c G)-h$(c), $(c G)--help$(c)   show this help message

EXAMPLES
  $(c Ys)\$ pass ${ME}$(c)                  → $(c Ci)pass -c $(c 0Bi)<selected>$(c)
  $(c Ys)\$ pass ${ME}$(c) $(c Mi)show$(c)             → $(c Ci)pass show $(c 0Bi)<selected>$(c)
  $(c Ys)\$ pass ${ME}$(c) $(c Bi)github$(c)           → fzf search with $(c Bi)'github'$(c), then $(c Ci)pass -c $(c 0Bi)<selected>$(c)
  $(c Ys)\$ pass ${ME}$(c) $(c Mi)-c$(c)               → $(c Ci)pass -c $(c 0Bi)<selected>$(c)
  $(c Ys)\$ pass ${ME}$(c) $(c Mi)edit$(c)             → $(c Ci)pass edit $(c 0Bi)<selected>$(c)
  $(c Ys)\$ pass ${ME}$(c) $(c Gi)-s$(c)               → just print path
  $(c Ys)\$ pass ${ME}$(c) $(c Gi)-s$(c) $(c Bi)github$(c)        → just print path $(c i)(query=$(c 0Bi)'github'$(c 0i))$(c)

NOTE:
  • supported pass sub-commands : $(c Mi)-c$(c)/$(c Mi)--clip$(c), $(printf "$(c Mi)%s$(c), " "${subcommands[@]}" | sed 's/, $//')
  • if no sub-command is given, the default is $(c Mi)-c$(c)/$(c Mi)--clip$(c) (clipboard)
  • environment variables that can be set $(c Gi)PASSWORD_STORE_DIR$(c), $(c Gi)PASSWORD_STORE_CLIP_TIME$(c)
"""

function candidates() {
  PREFIX="${PASSWORD_STORE_DIR:-${HOME}/.password-store}"
  find "${PREFIX}" -name '*.gpg' | sed -e "s:${PREFIX}/::gi" -e 's:.gpg$::gi'
}

function candidate() { query=$1; candidates | fzf -q "${query}"; }
function usage() { echo -e "${usage}"; exit 0; }
function die() { echo -e "$(c Ri)ERROR$(c)$(c i): $*.$(c) $(c Wdi)exit ...$(c)" >&2; exit 1; }

declare -i selectOnly=0
declare -a args=()
declare query=''

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -s          ) selectOnly=1     ; shift ;;
    -h | --help ) usage                     ;;
    --          ) shift             ; break ;;
    -*          ) args+=("$1") ; shift ;;
    *           ) if [[ -z "${query}" && ! " ${subcommands[*]} " =~ ${1} ]]; then
                    query="$1"
                  else
                    args+=("$1")
                  fi
                  shift
                  ;;
  esac
done

# using -c as default sub-command if no sub-command is given
[[ ${#args[@]} -eq 0 ]] && args+=("-c")

if [[ "${#args[@]}" -gt 0 ]]; then
  firstCmd="${args[0]}"
  [[ "${firstCmd}" != -* && ! " ${subcommands[*]} " =~ ${firstCmd} ]] && die "unsupported sub-command '${firstCmd}' with 'pass fzf'"
fi

result=$(candidate "${query}")

if [[ -n "${result}" ]]; then
  if [[ "${selectOnly}" -ne 0 ]]; then
    echo "${result}"; exit 0
  fi
  pass "${args[@]}" "${result}"
else
  exit 1
fi

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
