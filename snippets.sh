#!/bin/bash


# -------- BEGIN META NOTES --------

# ## Script argument guidelines:
#
# ## Vocabulary
# Given this script calling example:
# ```
# some_script.sh --pull-request-count 100 --list-authors
# ```
# The *script name*: Is the name of the script. I.E. `some_script.sh`
# An *argument* is anything starting with a `--`. I.E. `--pull-request-count` and `--list-authors`
# A *parameter* is the value that follows an argument. I.E. `3` from `--pull-request-count 100`
# You can think of argument/parameter like a key/value pair
#
# ## Arguments Types:
# * Flags. aka: A lone argument, set or presence type. (The argument is either present or not present.) 
#   * `--list-authors` is a presence arg (Is it present or not?), and has no value associated with it.
# * Key/value pair. aka: argument/parameter, parameterized argument (This key = that value).
#   * EX: `--pull-request-count 100`.
# 
# ## Backing Variables:
# Each argument is paired with an UPPER_CASE backing var. EX:
# * `--pull-request-count` is stored in `$PULL_REQUEST_COUNT`
# * `--list-authors` is stored in `$LIST_AUTHORS`
#
# ## Short vs Long Argument Names
# * Generally in scripting, arguments can either be *short form* (`some_script.sh -h 3 -d`) or *long form* (`some_script.sh --pull-request-count 3 --list-authors`).
# * When writing scripts, only provide *long form* arguments with exception of help. Always support both `-h` and `--help`.
# * When calling other scripts, prefer using *long form* arguments for readablity
#
# ## Optional vs Mandatory vs Default
# * In this example, `--report-type` is required (must be passed in).
# * In this example, `--pull-request-count` is required, but has a default value if not passed in.
# * In this example, `--list-authors` is optional (okay if it's not passed in).
#
# ## Argument Position
# Our scripts should strive to be position agnostic if at all possible. Prefer to be expressive using key/value pairs vs using order precedence. 
#
# ## Ubiquity
# All scripts should support `--help` and `--debug` flags. 
#
# ## Provide a printUsage function
# Always provide a printUsage function and `--help` param
# * TODO:

# -------- END META NOTES --------

# ---- Look for our debug argument first thing (other args processed after bootstrapping).

# unset -v IS_DEBUG
# for i in "$@"; do
#   if [ "$i" == "--debug" ] ; then
#     echo "----- Found"
#     IS_DEBUG="true"
#   fi
# done

# ---- Set up our logging functions

# Writes to stdout always
log() {
  echo "$@";
}

# Writes to stderr always
logStdErr() {
  echo "$@" 1>&2
}

# Writes to stdout if `--debug` param was specified.
logd() {
  if [[ -n "$IS_DEBUG" ]]; then
    log "$@"
  fi
}

# Writes to stderr if `--debug` param was specified.
logdStdErr() {
  if [[ -n "$IS_DEBUG" ]]; then
    logStdErr "$@"
  fi
}

# ---- Set up our printUsage function

# Prints the example usage to stderr
# Call like so: `printUsage`
printUsage () {
  SCRIPT_NAME=./$(basename "$0")
  logStdErr "This script will install/backup code snippets from multiple IDEs."
  logStdErr ""
  logStdErr "Usage:"
  logStdErr "    $SCRIPT_NAME --mode <list|install|backup> --ide <xcode|vscode> [--debug] [--help]"
  logStdErr ""
  logStdErr "Mandatory:"
  logStdErr "    --mode: The mode for the script to operate in (install or backup)."
  logStdErr "    --id: Specifies which IDE to install/backup the snippets to/from."
  logStdErr ""
  logStdErr "Optional:"
  logStdErr "    --debug: Print debug level logs."
  logStdErr "    --help: Print this message"
  logStdErr ""
  logStdErr "EX:"
  logStdErr "    List the Xcode snippets that are available to be installed."
  logStdErr "    \$ $SCRIPT_NAME --mode list --ide xcode"
  logStdErr ""
  logStdErr "    List the VSCode snippets that are available to be installed."
  logStdErr "    \$ $SCRIPT_NAME --mode list --ide vscode"
  logStdErr ""
  logStdErr "    Install Xcode snippets onto your system."
  logStdErr "    \$ $SCRIPT_NAME --mode install --ide xcode"
  logStdErr ""
  logStdErr "    Install VSCode snippets onto your system."
  logStdErr "    \$ $SCRIPT_NAME --mode install --ide vscode"
  logStdErr ""
  logStdErr "    Back up Xcode snippets from your system to this directory (make your own pull request)/"
  logStdErr "    \$ $SCRIPT_NAME --mode backup --ide xcode"
  logStdErr ""
  logStdErr "    Back up VSCode snippets from your system to this directory (make your own pull request)/"
  logStdErr "    \$ $SCRIPT_NAME --mode backup --ide vscode"
  logStdErr ""
}

# ---- Start parsing and checking our arguments & arguments with parameters. 

# Ensure our globals are cleared before populating with args
unset -v IS_DEBUG
unset -v IS_ADMIN
unset -v LIST_AUTHORS
unset -v HATCH_TYPE

# TODO: zakkhoyt. Consider returning a delimited string like echo_ansi's extract_cursor_direction
# Parses script arguments which take the form of:
#   * --key=value
#   * --key value
# return: Additional number of positions to shift the arguments.
# (0 for "key=value", 1 for "key value"). EX:
#
# ```sh
# --type*)
#   TYPE_ARG=$(parse_key_value_argument "--type" "$@")
#   shift $?
# ```
#
# stdout: The parsed argument value if found. Otherwise nil.
parse_key_value_argument() {

  logdStdErr "1: $1"
  logdStdErr "2: $2"
  logdStdErr "3: $3"
  
  # echo "$2" | grep -E "^${1}" 1>&2 /dev/null
  # # echo "--level=4" | grep -E "^--level" 1>&2 /dev/null
  # RVAL=$?
  # logdStdErr "------------------- RVAL: $RVAL"
  # if [[ "$RVAL" -eq 0 ]]; then 
  #   :
  # else
  #   # set -x
  #   logdStdErr "Expected argument: '$2' to begin with '$1', but does not"  
  #   # exit 1
  # fi
  validate_arg "${1}" "${2}"

  local suffix
  suffix=${2//${1}/} # $(echo "${2}" | sed "s/${1}//g")
  logdStdErr "suffix: '$suffix'"
  
  if [[ -n "$suffix" ]]; then
    logdStdErr "Found argument key=value: ${2}. "
    key=$(echo "${2}" | sed -E 's/(.*)(=.*)/\1/g')
    value=$(echo "${2}" | sed -E 's/(.*=)(.*)/\2/g')
    logdStdErr "  key: $key value: $value"
    echo "$value"
    return 0
  else
    logdStdErr "Found argument ${2} arg: ${3}"
    key="${2}"
    value="${3}"
    logdStdErr "Valid ${2} value: ${3}"
    echo "${3}"
    return 1
  fi
}

validate_arg() {
  local match
  match=$(echo "${2}" | grep -E "^${1}")
  # echo "$1" | grep -E "^--report-type" 1>&2 /dev/null
  # echo "--level=4" | grep -E "^--level" 1>&2 /dev/null
  # logdStdErr "------------------- match: $match"
  
  if [[ "$match" != "" ]]; then
    logdStdErr "Acutal: '$2' to begin with '$1', but does not"  
  else
    # set -x
    logdStdErr "Expected argument: '$2' to begin with '$1', but does not"  
    trap 1
    # exit 1
  fi
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      # Looks for presence of -h or --help
      logdStdErr "Found $1 arg"
      printUsage
      exit 1
      ;;
    --debug)
      # Looks for presence of --debug
      # This arg was processed at the top of the script, so not much to do in this case.
      logdStdErr "Found $1 arg"
      IS_DEBUG="$1"
      ;;
    --admin)
      # Looks for presence of --admin
      # This arg was processed at the top of the script, so not much to do in this case.
      logdStdErr "Found $1 arg"
      IS_ADMIN="$1"
      ;;
    --mode*)
      HATCH_MODE=$(parse_key_value_argument "--mode" "${@}")
      shift $?

      if [[ "$HATCH_MODE" != "list" && "$HATCH_MODE" != "install" && "$HATCH_MODE" != "backup" ]]; then
        logStdErr "[ERROR] Invalid value for '$1': '$2'. Options are 'list', 'install', or 'backup'."
        printUsage
        exit 1
      fi
      ;;
    --ide*)
      HATCH_IDE=$(parse_key_value_argument "--ide" "${@}")
      shift $?

      if [[ "$HATCH_IDE" != "vscode" && "$HATCH_IDE" != "xcode" ]]; then
        logStdErr "[ERROR] Invalid value for '$1': '$2'. Options are 'vscode' or 'xcode'."
        printUsage
        exit 1
      fi
      ;;
    *)
      # If begins with a single or double dash
      echo "$1" | grep -E "^-{1,2}" > /dev/null
      RVAL=$?
      if [[ "$RVAL" -eq 0 ]]; then 
        logStdErr "[ERROR] Found unsupported argument: $1"
        hatch_log -c -d "[ERROR] Found unsupported argument: $1"
        logStdErr ""
        # printUsage
      else
        # Unhandled value
        logStdErr "[ERROR] Found unsupported value: $1"
        logStdErr ""
        # printUsage
      fi

      # FIXME: zakkhoyt. Restore this
      # exit 1
      ;;
  esac
  shift 1
done

# ---- Validate that required args have been passed in.  

# Writes to stderr including file/line if HATCH_MODE is not defined

: "${HATCH_MODE:?[ERROR] An parameter is required for --mode. See --help for details.}"
logd "HATCH_MODE: $HATCH_MODE"

: "${HATCH_IDE:?[ERROR] An parameter is required for --ide. See --help for details.}"
logd "HATCH_IDE: $HATCH_IDE"

# ---- Script main work

# Get filename of script
SCRIPT_NAME=$(basename "$0")
logdStdErr "SCRIPT_NAME: $SCRIPT_NAME"

# Get dir of script
SCRIPT_DIR=$(realpath "$(dirname "$0")")
logdStdErr "SCRIPT_DIR: $SCRIPT_DIR"

XCODE_SNIPPETS_DIR="$HOME/Library/Developer/Xcode/UserData/CodeSnippets"
logdStdErr "XCODE_SNIPPETS_DIR: $XCODE_SNIPPETS_DIR"

VSCODE_SNIPPETS_DIR="$HOME/Library/Application Support/Code/User/snippets"
logdStdErr "VSCODE_SNIPPETS_DIR: $VSCODE_SNIPPETS_DIR"

# TODO: zakkhoyt. Check if dirs exist before using them

XCODE_REPO_DIR="$SCRIPT_DIR/snippets/xcode"
logdStdErr "XCODE_REPO_DIR: $XCODE_REPO_DIR"

VSCODE_REPO_DIR="$SCRIPT_DIR/snippets/vscode"
logdStdErr "VSCODE_REPO_DIR: $VSCODE_REPO_DIR"

TEAM_PREFIX="hatch_"
logdStdErr "TEAM_PREFIX: $TEAM_PREFIX"


if [[ "$HATCH_MODE" == 'list' ]]; then
  if [[ "$HATCH_IDE" == 'xcode' ]]; then
    ls -1 "$XCODE_REPO_DIR"
  elif [[ "$HATCH_IDE" == 'vscode' ]]; then  
    ls -1 "$VSCODE_REPO_DIR"
  fi
elif [[ "$HATCH_MODE" == 'install' ]]; then

  
  # TODO: zakkhoyt. Backup any existing 'hatch' files before overwriting them
  if [[ "$HATCH_IDE" == 'xcode' ]]; then
    logdStdErr "Installing xcode snippets..."
    cp "$XCODE_REPO_DIR"/* "$XCODE_SNIPPETS_DIR"
  elif [[ "$HATCH_IDE" == 'vscode' ]]; then  
    logdStdErr "Installing vscode snippets..."
    cp "$VSCODE_REPO_DIR"/* "$VSCODE_SNIPPETS_DIR"
  fi
elif [[ "$HATCH_MODE" == 'backup' ]]; then
  CURRENT_BRANCH=$(git branch | grep -E "^\*" | sed -E 's/\* //g')
  if [[ "$CURRENT_BRANCH" == 'main' ]]; then
    if [[ -n "$IS_ADMIN" ]]; then 
      logStdErr "[WARNING] Backng up to protected branch ('main')"
    else 
      logStdErr "[ERROR] Cannot back up to 'main' branch. Create a working branch then try again."
      exit 2
    fi
  fi
  
  if [[ "$HATCH_IDE" == 'xcode' ]]; then
    # TODO: zakkhoyt. only back up those with prefix "hatch"
    
    logdStdErr "Backing up xcode snippets..."
    cp "${XCODE_SNIPPETS_DIR}/${TEAM_PREFIX}*.codesnippet" "$XCODE_REPO_DIR"
    log "Did back up xcode snippets."
  elif [[ "$HATCH_IDE" == 'vscode' ]]; then  
    logdStdErr "Backing up vscode snippets..."
    cp "$VSCODE_SNIPPETS_DIR"/* "$VSCODE_REPO_DIR"
    log "Did back up vscode snippets."
  fi
else 
  logStdErr "[ERROR] Unhandle value for HATCH_MODE: $HATCH_MODE"
  exit 1
fi
