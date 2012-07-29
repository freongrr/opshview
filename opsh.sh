#!/bin/bash

### Constants ###

OPSVIEW_BASE_PATH=`dirname $0`
OPSVIEW_PERL_PATH="$OPSVIEW_BASE_PATH/OpsView.pl"
OPSVIEW_RC_FILE="/tmp/opshview.rc"
OPSVIEW_COMMANDS=`perl $OPSVIEW_PERL_PATH commands`

### Variables ###

opsViewUsername="";
opsViewToken="";
opsViewDestination="";

# The destination is set to "http://opsview" in the perl script
# But it can be overridden by passing "-d URL" here as well
if [[ "$1" == "--destination" || "$1" == "-d" ]] ; then
  opsViewDestination="$1 \"$2\""
  shift ; shift
fi

### Functions ###

function opsview_login() {
  local username=`whoami` password token

  # read the username
  echo -n "Username [$username]: "
  read
  if [[ "$REPLY" != "" ]] ; then
    username="$REPLY"
  fi

  # read the password
  echo -n "Password: "
  # TODO : how do we catch Ctrl-C?
  stty -echo
  read password
  stty echo
  echo ""

  token=`perl $OPSVIEW_PERL_PATH -u "$username" -p "$password" $opsViewDestination token`

  # set up the environment
  if [ "$token" == "" ] ; then
    exit 1
  else
    opsViewUsername="$username"
    opsViewToken="$token"
  fi
}

function _opsView_command() {
  perl $OPSVIEW_PERL_PATH -u "$opsViewUsername" -t "$opsViewToken" $*
}

### Completion ###

export HOST_CACHE=""
function _opsView_complete_host() {
  local cur="$2" prev="$3"
  if [ "$HOST_CACHE" == "" ] ; then
    HOST_CACHE=`opsview_hostlist`
  fi
  COMPREPLY=( $( compgen -W "$HOST_CACHE" -- "$cur" ) )
  return 0
}

export VIEW_CACHE=""
function _opsView_complete_view() {
  local cur="$2" prev="$3"
  if [ "$VIEW_CACHE" == "" ] ; then
    VIEW_CACHE=`opsview_viewport | tail -n +2 | cut -d' ' -f2`
  fi
  COMPREPLY=( $( compgen -W "$VIEW_CACHE" -- "$cur" ) )
  return 0
}

### Login ###

if ! opsview_login ; then
  echo "Failed to login"
  exit 1
fi

### Exports ###

export OPSVIEW_PERL_PATH
export opsViewUsername
export opsViewToken

export -f opsview_login
export -f _opsView_command
export -f _opsView_complete_host
export -f _opsView_complete_view

### Generate the resource file ###

echo -n > $OPSVIEW_RC_FILE

for cmd in $OPSVIEW_COMMANDS ; do
  echo "function opsview_$cmd() {" >> $OPSVIEW_RC_FILE
  echo "  _opsView_command \"$cmd\" \$*" >> $OPSVIEW_RC_FILE
  echo "}" >> $OPSVIEW_RC_FILE
done

echo "complete -F _opsView_complete_host opsview_services" >> $OPSVIEW_RC_FILE
echo "complete -F _opsView_complete_view opsview_viewport" >> $OPSVIEW_RC_FILE

echo "PS1=\"[opshview ($opsViewUsername)] > \"" >> $OPSVIEW_RC_FILE

### Spawn the subshell ###

$SHELL --rcfile $OPSVIEW_RC_FILE
#rm $OPSVIEW_RC_FILE 2> /dev/null
