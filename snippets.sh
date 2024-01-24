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
  logStdErr "This script will install/backup code snippets from IDEs (Xcode, VSCode)."
  logStdErr ""
  logStdErr "Usage:"
  logStdErr "    $SCRIPT_NAME --mode <list|install|backup> --ide <xcode|vscode> [--debug] [--help]"
  logStdErr ""
  logStdErr "Mandatory:"
  logStdErr "    --mode: The mode for the script to operate in (list, install or backup)."
  logStdErr "        list: Print a list of the snippet files availabel to be installed."
  logStdErr "        install: Copies snippets from repo dir to IDE dir. Note: Any exsting snippets will first be copied to a backup folder in the destination directory."
  logStdErr "        list: Print a list of the snippet files availabel to be installed."
  logStdErr ""
  logStdErr "    --ide: Specifies which IDE to install/backup the snippets to/from."
  logStdErr "        xcode: Apple's Xcode in default installation path."
  logStdErr "        vscode: Visual Studio Code in default installation path."
  logStdErr ""
  logStdErr "Optional:"
  logStdErr "    --debug: Print debug level logs."
  logStdErr "    --help: Print this message"
  logStdErr ""
  logStdErr "EX: (Xcode)"
  logStdErr "    List the Xcode snippets that are available to be installed."
  logStdErr "    \$ $SCRIPT_NAME --mode list --ide xcode"
  logStdErr ""
  logStdErr "    Install Xcode snippets onto your system."
  logStdErr "    \$ $SCRIPT_NAME --mode install --ide xcode"
  logStdErr ""
  logStdErr "    Back up Xcode snippets from your system to this directory (make your own pull request)/"
  logStdErr "    \$ $SCRIPT_NAME --mode backup --ide xcode"
  logStdErr ""
  logStdErr "EX: (VSCode)"
  logStdErr "    List the VSCode snippets that are available to be installed."
  logStdErr "    \$ $SCRIPT_NAME --mode list --ide vscode"
  logStdErr ""
  logStdErr "    Install VSCode snippets onto your system."
  logStdErr "    \$ $SCRIPT_NAME --mode install --ide vscode"
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
unset -v TYPE

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
      MODE=$(parse_key_value_argument "--mode" "${@}")
      shift $?

      if [[ "$MODE" != "list" && "$MODE" != "install" && "$MODE" != "backup" ]]; then
        logStdErr "[ERROR] Invalid value for '$1': '$2'. Options are 'list', 'install', or 'backup'."
        printUsage
        exit 1
      fi
      ;;
    --ide*)
      IDE=$(parse_key_value_argument "--ide" "${@}")
      shift $?

      if [[ "$IDE" != "vscode" && "$IDE" != "xcode" ]]; then
        logStdErr "[ERROR] Invalid value for '$1': '$2'. Options are 'vscode' or 'xcode'."
        printUsage
        exit 1
      fi
      ;;
    *)
      logStdErr "[ERROR] Found unsupported argument: $1"
      printUsage
      exit 1
      ;;
  esac
  shift 1
done

# ---- Validate that required args have been passed in.  

# Writes to stderr including file/line if MODE is not defined

: "${MODE:?[ERROR] An parameter is required for --mode. See --help for details.}"
logd "MODE: $MODE"

: "${IDE:?[ERROR] An parameter is required for --ide. See --help for details.}"
logd "IDE: $IDE"

# ---- Script main work

# Get filename of script
SCRIPT_NAME=$(basename "$0")
logdStdErr "SCRIPT_NAME: $SCRIPT_NAME"

# Get dir of script
SCRIPT_DIR=$(realpath "$(dirname "$0")")
logdStdErr "SCRIPT_DIR: $SCRIPT_DIR"

# Only snippet files with this prefix will be copied. 
TEAM_PREFIX="hatch_"
logdStdErr "TEAM_PREFIX: $TEAM_PREFIX"

# Path to xcode snippets in this repo
XCODE_REPO_DIR="$SCRIPT_DIR/source/xcode"
logdStdErr "XCODE_REPO_DIR: $XCODE_REPO_DIR"

# Path to vscode snippets in this repo
VSCODE_REPO_DIR="$SCRIPT_DIR/source/vscode"
logdStdErr "VSCODE_REPO_DIR: $VSCODE_REPO_DIR"

# Path to xcode snippets on the client machine
XCODE_SNIPPETS_DIR="$HOME/Library/Developer/Xcode/UserData/CodeSnippets"
logdStdErr "XCODE_SNIPPETS_DIR: $XCODE_SNIPPETS_DIR"

# Path to vscode snippets on the client machine
VSCODE_SNIPPETS_DIR="$HOME/Library/Application Support/Code/User/snippets"
logdStdErr "VSCODE_SNIPPETS_DIR: $VSCODE_SNIPPETS_DIR"


unset -v CLIENT_SNIPPETS_DIR
unset -v REPO_SNIPPETS_DIR
declare -a SNIPPET_EXTENSIONS
if [[ "$IDE" == 'xcode' ]]; then
  REPO_SNIPPETS_DIR="$XCODE_REPO_DIR"
  CLIENT_SNIPPETS_DIR="$XCODE_SNIPPETS_DIR"
  SNIPPET_EXTENSIONS=("codesnippet")
elif [[ "$IDE" == 'vscode' ]]; then  
  REPO_SNIPPETS_DIR="$VSCODE_REPO_DIR"
  CLIENT_SNIPPETS_DIR="$VSCODE_SNIPPETS_DIR"
  TEAM_PREFIX=""
  SNIPPET_EXTENSIONS=("code-snippets" "json")
fi

# Check if dirs exist before using them
if [[ -d "$REPO_SNIPPETS_DIR" ]]; then 
  logdStdErr "  REPO_SNIPPETS_DIR was located: $REPO_SNIPPETS_DIR"
else
  logdStdErr "  [ERROR] REPO_SNIPPETS_DIR was not found: $REPO_SNIPPETS_DIR"
  exit 10
fi
if [[ -d "$CLIENT_SNIPPETS_DIR" ]]; then 
  logdStdErr "  CLIENT_SNIPPETS_DIR was located: $CLIENT_SNIPPETS_DIR"
else
  logdStdErr "  [ERROR] CLIENT_SNIPPETS_DIR was not found: $CLIENT_SNIPPETS_DIR"
  exit 11
fi
# TODO: zakkhoyt. Sync the snippet filename and name IN the file (for xcode)

if [[ "$MODE" == 'list' ]]; then
  logStdErr "Available snippets: ($REPO_SNIPPETS_DIR)"
  logStdErr ""
  find "$REPO_SNIPPETS_DIR" | sed "s|$REPO_SNIPPETS_DIR|.|g" | grep -Ev '^.$' | grep -v 'DS_Store'
  logStdErr ""
  logStdErr "Installed snippets: ($CLIENT_SNIPPETS_DIR)"
  logStdErr ""
  find "$CLIENT_SNIPPETS_DIR" | sed "s|$CLIENT_SNIPPETS_DIR|.|g" | grep -Ev '^.$' | grep -v 'DS_Store'
elif [[ "$MODE" == 'install' ]]; then
  # Backup all existing snippets before overwriting them
  TIMESTAMP=$(date +%Y%m%d%H%M%S)
  BACKUP_DIR="${CLIENT_SNIPPETS_DIR}/backup_${TIMESTAMP}"
  logdStdErr "Backing up existing snippets to ${BACKUP_DIR}"
  mkdir "${BACKUP_DIR}"
  cp "${CLIENT_SNIPPETS_DIR}"/* "${BACKUP_DIR}"

  cp "$REPO_SNIPPETS_DIR"/* "$CLIENT_SNIPPETS_DIR"
  logdStdErr "Did install ${IDE} snippets"
elif [[ "$MODE" == 'backup' ]]; then
  # If user is on `main` branch, error out (or warn depending on flags)
  CURRENT_BRANCH=$(git branch | grep -E "^\*" | sed -E 's/\* //g')
  if [[ "$CURRENT_BRANCH" == 'main' ]]; then
    if [[ -n "$IS_ADMIN" ]]; then 
      logStdErr "[WARNING] Backng up to protected branch ('main')"
    else 
      logStdErr "[ERROR] Cannot back up to 'main' branch. Create a working branch then try again."
      exit 2
    fi
  fi

  # copy snippets from client machine into repo
  for SNIPPET_EXTENSION in "${SNIPPET_EXTENSIONS[@]}"; do
    logdStdErr "Backing up ${IDE} snippets with prefix '${TEAM_PREFIX}' and extension '${SNIPPET_EXTENSION}'..."
    set -x
    cp "${CLIENT_SNIPPETS_DIR}/${TEAM_PREFIX}"*."${SNIPPET_EXTENSION}" "${REPO_SNIPPETS_DIR}"
    set +x
  done
  log "Did back up ${IDE} snippets."
else 
  logStdErr "[ERROR] Unhandle value for MODE: ${MODE}"
  exit 1
fi
