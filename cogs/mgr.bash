#!/usr/bin/env bash

# Set default MRG_TEAMS_PATH if not already set
export MRG_TEAMS_PATH="${MRG_TEAMS_PATH:-$HOME/Documents/mgr}"

function _mrg_get_all_employees() { # Get all employee names across all teams
  if [[ ! -d $MRG_TEAMS_PATH ]]; then
    return 1
  fi

  # Use portable find command that works on all systems
  # Look for directories that are 2 levels deep (team/employee structure)
  # Extract the basename (last directory) which should be the full employee name
  find "$MRG_TEAMS_PATH" -mindepth 2 -maxdepth 2 -type d 2>/dev/null | while read -r path; do
    basename "$path"
  done | sort -u
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

## What is on your mind
-

## Comments from me
-

## Career progression
-

## Action items
- [ ]
- [ ]

## Notes
-

EOF
}

function _mrg_ladder_template() { # Create competency ladder YAML template
  local employee="$1"
  local current_date
  current_date=$(date +'%Y-%m-%d')

  cat <<EOF
# Values: junior, mid, senior, staff, principal

employee: "${employee}"
last_updated: "${current_date}"

competencies:
  scope: ""
  autonomy: ""
  code_quality: ""
  debugging: ""
  system_design: ""
  impact: ""
  mentorship: ""
  leadership: ""
  collaboration: ""
  vision_strategy: ""

EOF
}

function mgr() { # Management helper
  local mrg_action="$1"
  shift
  local mrg_args="$*"

  case "$mrg_action" in
  "debug")
    echo "MRG_TEAMS_PATH: $MRG_TEAMS_PATH"
    echo "Directory exists: $(test -d "$MRG_TEAMS_PATH" && echo "yes" || echo "no")"
    echo "Employees found:"
    _mrg_get_all_employees || echo "No employees found"
    return 0
    ;;
  "1v1")
    local employee_name
    if [[ -n $mrg_args ]]; then
      employee_name="$mrg_args"
    else
      # Use FZF to select employee
      employee_name=$(_mgr_select_employee)
      if [[ -z $employee_name ]]; then
        echo "No employee selected"
        return 1
      fi
    fi

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
    ;;
  "ladder")
    local employee_name
    if [[ -n $mrg_args ]]; then
      employee_name="$mrg_args"
    else
      # Use FZF to select employee
      employee_name=$(_mgr_select_employee)
      if [[ -z $employee_name ]]; then
        echo "No employee selected"
        return 1
      fi
    fi

    local employee_path
    employee_path=$(_mrg_find_employee_path "$employee_name")

    if [[ -z $employee_path ]]; then
      echo "Employee '$employee_name' not found in any team"
      return 1
    fi

    local today_date
    today_date=$(date +'%Y.%m.%d')
    local ladder_dir="${employee_path}/ladder"
    local ladder_file="${ladder_dir}/${today_date}.yaml"
    local previous_ladder_file

    # Find the most recent ladder file
    previous_ladder_file=$(find "$ladder_dir" -name "*.yaml" -type f -exec stat -c "%m %N" {} \; 2>/dev/null | sort -nr | cut -d "'" -f 2 | head -n 1)

    mkdir -p "$ladder_dir"

    if [[ ! -f $ladder_file ]]; then
      if [[ -f $previous_ladder_file ]]; then
        # Use the previous ladder as base, but update the date
        sed "s/last_updated: \"[^\"]*\"/last_updated: \"$(date +'%Y-%m-%d')\"/" "$previous_ladder_file" >"$ladder_file"
      else
        # Create new ladder from template
        _mrg_ladder_template "$employee_name" >"$ladder_file"
      fi
    else
      echo "$ladder_file already exists"
    fi

    "$EDITOR" "$ladder_file"
    ;;
  *)
    echo "Available commands:"
    echo "  mgr 1v1 [employee_name]     - Create/edit 1:1 notes (uses FZF if no name provided)"
    echo "  mgr ladder [employee_name]  - Create/edit competency ladder (uses FZF if no name provided)"
    echo "  mgr debug                   - Debug employee discovery and paths"
    ;;
  esac
}

function _mgr_select_employee() { # Use FZF to select an employee
  local employees
  employees=$(_mrg_get_all_employees 2>/dev/null)

  if [[ -z $employees ]]; then
    echo "No employees found in $MRG_TEAMS_PATH" >&2
    return 1
  fi

  echo "$employees" | fzf --prompt="Select employee: " --height=10 --border
}

function _mgr() { # Simple bash completion for mgr commands only
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"

  if [[ $COMP_CWORD -eq 1 ]]; then
    # Complete the command names
    local commands=('1v1' 'ladder' 'debug')
    COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
  else
    # No completion for employee names - user will use FZF instead
    COMPREPLY=()
  fi
}

complete -F _mgr mgr
