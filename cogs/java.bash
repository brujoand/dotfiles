#!/usr/bin/env bash

function set_active_jdk() { # set the active jdk with param eg 1.8
  if [ $# -ne 1 ]; then
   JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
   PATH=$JAVA_HOME/bin:$PATH
  else
   JAVA_HOME=$(/usr/libexec/java_home -v "$1")
   PATH=$JAVA_HOME/bin:$PATH
  fi
  export JAVA_HOME
  export PATH
}

