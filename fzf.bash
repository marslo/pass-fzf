#!/usr/bin/env bash

declare -a pass_subcommands=(show edit rm)

function candidates() {
  PREFIX="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
  find "${PREFIX}" -name '*.gpg' | sed -e "s:$PREFIX/::gi" -e 's:.gpg$::gi'
}

function candidate_selector_fzf() {
  query=$1
  candidates | fzf -q "${query}"
}

function usage() {
    cat <<EOF
USAGE: pass fzf [options] [query]

OPTIONS:
  -s           Only output selected path (don't run 'pass')
  -h, --help   Show this help message

EXAMPLES:
  pass fzf                  → pass show <selected>
  pass fzf show             → pass show <selected>
  pass fzf github           → fzf search with 'github', then pass show <selected>
  pass fzf -c               → pass -c <selected>
  pass fzf edit             → pass edit <selected>
  pass fzf -s               → just print path
  pass fzf -s github        → just print path (query='github')

NOTE:
EOF
printf "  • supported pass sub-commands : -c/--clip,"
IFS=', '
echo "${pass_subcommands[*]}"
  exit 0
}

declare -i select_only=0
declare -a pass_args=()
declare query=''

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -s          ) select_only=1     ; shift ;;
    -h | --help ) usage                     ;;
    --          ) shift             ; break ;;
    -*          ) pass_args+=("$1") ; shift ;;
    *           ) if [[ -z "${query}" && ! " ${pass_subcommands[*]} " =~ ${1} ]]; then
                    query="$1"
                  else
                    pass_args+=("$1")
                  fi
                  shift
                  ;;
  esac
done

if [[ "${#pass_args[@]}" -gt 0 ]]; then
  first_cmd="${pass_args[0]}"
  if [[ "${first_cmd}" != -* && ! " ${pass_subcommands[*]} " =~ ${first_cmd} ]]; then
    echo "Unsupported sub-command '${first_cmd}' with 'pass fzf'" >&2
    exit 2
  fi
fi

res=$(candidate_selector_fzf "${query}")

if [[ -n "${res}" ]]; then
  if [[ "${select_only}" -ne 0 ]]; then
    echo "${res}"
    exit 0
  fi
  pass "${pass_args[@]}" "${res}"
else
  exit 1
fi

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
