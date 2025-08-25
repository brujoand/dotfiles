#!/usr/bin/env bash

export MRG_TEAMS_PATH="$HOME/Documents/mgr"

function _mrg_get_all_employees() { # Get all employee names across all teams
  if [[ ! -d $MRG_TEAMS_PATH ]]; then
    return 1
  fi

  find "$MRG_TEAMS_PATH" -mindepth 2 -maxdepth 2 -type d -printf '%f\n' | sort -u
}

function _mrg_find_employee_path() { # Find the full path for an employee
  local employee_name="$1"
  if [[ -z $employee_name ]]; then
    return 1
  fi

  find "$MRG_TEAMS_PATH" -mindepth 2 -maxdepth 2 -type d -name "$employee_name" | head -1
}

function _mrg_1v1_template() { # Create 1v1 template
  local date="$1"
  local employee="$2"

  cat <<EOF
# ${date} - 1:1 with ${employee}

## How are you doing?
-

## What's going well?
-

## What's challenging?
-

## Goals and development
-

## Action items
- [ ]
- [ ]

## Notes
-

EOF
}

function mrg() { # Management helper
  local mrg_action="$1"
  shift
  local mrg_args="$*"

  case "$mrg_action" in
  "1v1")
    if [[ -n $mrg_args ]]; then
      local employee_name="$mrg_args"
      local employee_path
      employee_path=$(_mrg_find_employee_path "$employee_name")

      if [[ -z $employee_path ]]; then
        echo "Employee '$employee_name' not found in any team"
        return 1
      fi

      local today_date
      today_date=$(date +'%Y.%m.%d')
      local oneonone_dir="${employee_path}/1v1"
      local oneonone_file="${oneonone_dir}/${today_date}.md"

      mkdir -p "$oneonone_dir"

      if [[ ! -f $oneonone_file ]]; then
        _mrg_1v1_template "$today_date" "$employee_name" >"$oneonone_file"
      else
        echo "$oneonone_file already exists"
      fi

      "$EDITOR" "$oneonone_file"
    else
      echo "Usage: mrg 1v1 <employee_name>"
      return 1
    fi
    ;;
  *)
    echo "Available commands:"
    echo "  mrg 1v1 <employee_name>  - Create/edit 1:1 notes for employee"
    ;;
  esac
}

function _mrg() { # Bash completion for mrg
  local cur words
  cur="${COMP_WORDS[COMP_CWORD]}"

  if [[ $COMP_CWORD -lt 2 ]]; then
    words=('1v1')
    COMPREPLY=($(compgen -W "${words[*]}" -- "$cur"))
  elif [[ $COMP_CWORD -eq 2 ]]; then
    case "${COMP_WORDS[1]}" in
    "1v1")
      local employees
      employees=$(_mrg_get_all_employees)
      COMPREPLY=($(compgen -W "$employees" -- "$cur"))
      ;;
    esac
  fi
}

complete -F _mrg mrg
