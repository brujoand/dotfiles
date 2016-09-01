#! /usr/bin/env bash

AWS_CONFIG_FILE=${AWS_CONFIG_FILE:-${HOME}/.aws/config}

function _aws_get_profiles() {
  if [[ ! -f "$AWS_CONFIG_FILE" ]]; then
    echo "Could not find an aws config file at $AWS_CONFIG_FILE"
    return 1
  fi
  sed -n 's/.* \(.*\)]/\1/p' "$AWS_CONFIG_FILE"
}

function _aws_get_active_profile() {
  if [[ -n "$AWS_DEFAULT_PROFILE" ]]; then
    echo "$AWS_DEFAULT_PROFILE"
  elif grep -q '[default]' "$AWS_CONFIG_FILE" 2>/dev/null; then
    echo 'default'
  else
    echo "No profile could be found"
  fi
}

function _aws_show_active_profile() {
  AWS_DEFAULT_PROFILE=$AWS_DEFAULT_PROFILE
  AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
  AWS_DEFAULT_OUTPUT=$AWS_DEFAULT_REGION
  AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
  AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
}

function _aws_set_active_profile() {
  local target_profile=$1
  if [[ -z "$target_profile" ]]; then
    echo "No target profile provided as arg 1"
    return 1
  fi

  if ! type aws &>/dev/null; then
    echo "Aws cli is not on path, please fix"
    return 1
  fi

  if grep -q ^"$target_profile"$ <<< "$(_aws_get_profiles)"; then
    set -a # Export the following variables
    AWS_DEFAULT_PROFILE="$target_profile"
    AWS_DEFAULT_REGION="$(aws configure --profile "${target_profile}" get region)"
    AWS_DEFAULT_OUTPUT="$(aws configure --profile "${target_profile}" get output)"
    AWS_ACCESS_KEY_ID="$(aws configure --profile "${target_profile}" get aws_access_key_id)"
    AWS_SECRET_ACCESS_KEY="$(aws configure --profile "${target_profile}" get aws_secret_access_key)"
    AWS_SESSION_TOKEN="$(aws configure --profile "${target_profile}" get aws_session_token)"
    set +a
  fi
}

function _aws_profile() {
  local cur
  _get_comp_words_by_ref cur

  if [[ -z "$cur" ]]; then
    COMPREPLY=( $( compgen -W "$(_aws_get_profiles)" ) )
  else
    COMPREPLY=( $( _aws_get_profiles | grep ^"$cur") )
  fi
}

alias aws_profile='_aws_set_active_profile' # Set the currently active profile
complete -o nospace -F _aws_profile aws_profile
