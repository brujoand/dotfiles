#!/usr/bin/env bash
# Try to parse jiranr from branch name ie. JIRA-234892_rest_of_branch_name
# and prepend it to commit messages

msg=$(cat "$1")
branch=$(git branch | sed -n 's/* \(.*\)/\1/p')
jira_nr=${branch%%_*}
echo "$jira_nr $msg" > "$1"
