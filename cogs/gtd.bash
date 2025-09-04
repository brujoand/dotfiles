#! /usr/bin/env bash

export TDY_PATH="$HOME/Documents/tdy"
export NTS_PATH="$HOME/Documents/nts"

function tdy_done() {
  grep -R -i "$1" "$TDY_PATH" | grep -- '^- \[x\]'
}

function tdy() { # The today todo list
  category=${1:-work}
  tdy_folder="${TDY_PATH}/${category}"
  tdy_current_file="${tdy_folder}/$(date +'%Y/%m/%Y.%m.%d').md"
  tdy_current_folder="${tdy_current_file%/*}"
  tdy_previous_file=$(find "$tdy_folder" -type f -exec stat -c "%m %N" {} \; | sort -nr | cut -d "'" -f 2 | head -n 1)

  mkdir -p "${tdy_current_folder}"

  if [[ ! -f $tdy_current_file ]]; then
    printf '%s\n' "# $(date +'%Y.%m.%d')" >>"$tdy_current_file"
    if [[ -f $tdy_previous_file ]]; then
      grep -- '^- \[ \]' "$tdy_previous_file" >>"$tdy_current_file"
    fi
  fi

  if [[ -t 1 ]]; then
    "$EDITOR" "${tdy_current_file}"
  else
    # We're in a pipe, so let's cat this instead
    cat "${tdy_current_file}"
  fi
}

function _nts_open() {
  local search_dir="$NTS_PATH"

  local result
  result=$(find "$search_dir" -type f -maxdepth 4 -name '*.md' -o -name '*.dot' | sed -e "s|${search_dir}\/||g" | fzf --border --height 20)
  local path="${search_dir}/${result}"
  if [[ -n $result ]]; then
    $EDITOR "$path" || return 1
  fi
}

function never_run_nts_build() {
  local search_dir="$NTS_PATH"
  local output_dir="${search_dir}/output"
  local index="${output_dir}/index.html"

  rm "$index"

  for type_dir in "$search_dir"/*; do
    type="${type_dir##*/}"
    [[ $type == 'output' ]] && continue

    mkdir -p "${output_dir}/${type}"

    for source_file in "$type_dir"/*; do
      file="${source_file##*/}"
      nts_name="${file%.*}"
      extention="${file##*.}"
      output_file="${output_dir}/${type}/${nts_name}"
      case "$extention" in
      md)
        output_file="${output_file}.html"
        pandoc -f markdown -t html5 "$source_file" >"$output_file"
        ;;
      dot)
        output_file="${output_file}.png"
        dot -Tpng -o"$output_file" "$source_file"
        ;;
      esac
      echo "<li><a href='${output_file}'> ${nts_name}</a></li>" >>"$index"
      echo "${source_file} -> ${output_file}"
    done
  done

}

function _nts_note_template() {
  shift # ignore the timestamp
  local name="$*"

  cat <<EOF
# ${name}

EOF

}

function _nts_meeting_template() {
  local timestamp=$1
  shift
  local name="$*"

  cat <<EOF
# ${timestamp} - ${name}

## Present
- Name
- Name

## Agenda
- Point
- Point

## Action points
- Action
- Action

EOF

}

function _nts_graph_template() {
  shift
  local name="$*"

  cat <<EOF
digraph ${name} {

}
EOF

}

function _nts_sync_template() {
  local timestamp=$1
  shift
  local name="$*"

  cat <<EOF
# ${timestamp} - Sync with ${name}

## Discussion Points
- Point
- Point

## Action Items
- Action
- Action

## Follow-up
- Item
- Item

EOF

}

function nts() { # The notes helper
  local nts_args timestamp target
  nts_type="$1"
  shift
  nts_args="$*"

  if [[ $nts_type == 'sync' ]]; then
    if [[ -n $nts_args ]]; then
      target="$nts_args"
    else
      # Use fzf to select existing sync targets or allow typing new one
      if [[ -d "${NTS_PATH}/sync" ]]; then
        target=$(find "${NTS_PATH}/sync" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort | fzf --border --height 20 --prompt="Select sync target: " --print-query | tail -1)
      else
        read -rp "Enter sync target: " target
      fi
      [[ -z $target ]] && return 1
    fi

    timestamp=$(date +'%d.%m.%y')
    file_dir="${NTS_PATH}/sync/${target}"
    file_name="${timestamp}.md"
    file_path="${file_dir}/${file_name}"

    mkdir -p "$file_dir"

    if [[ ! -f $file_path ]]; then
      _nts_sync_template "${timestamp}" "$target" >"$file_path"
    else
      echo "$file_path already exists"
    fi

    $EDITOR "$file_path"
    return
  fi

  if [[ -n $nts_args ]]; then
    timestamp=$(date +'%Y.%m.%d')
    file_dir="${NTS_PATH}/${nts_type}/"
    file_extention='md'
    mkdir -p "$file_dir"

    if [[ $nts_type == 'graph' ]]; then
      file_extention='dot'
    fi

    if [[ $nts_type == 'note' || $nts_type == 'graph' ]]; then
      file_name="${nts_args// /_}.${file_extention}"
    else
      file_name="${timestamp}.${nts_args// /_}.${file_extention}"
    fi

    file_path="${file_dir}/${file_name}"

    if [[ ! -f $file_path ]]; then
      "_nts_${nts_type}_template" "${timestamp}" "$nts_args" >"$file_path"
    else
      echo "$file_path already exists"
    fi

    $EDITOR "$file_path"

  else
    _nts_open
  fi
}

_nts() {
  local cur words
  cur="${COMP_WORDS[COMP_CWORD]}"

  if [[ $COMP_CWORD -lt 2 ]]; then
    words=('note' 'meeting' 'graph' 'sync')
  else
    words=()
  fi

  COMPREPLY=($(compgen -W "${words[*]}" -- "$cur"))
}

complete -F _nts nts
