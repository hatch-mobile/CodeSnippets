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

# ---- Set up our logging functions

# Writes to stdout always
log() {
  echo -e "$@";
}

# Writes to stderr always
logStdErr() {
  echo -e "$@" 1>&2
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

# FIXME: zakkhoyt. Replace with echo_ansi once deployed
ANSI_BOLD="\033[1m"
ANSI_ITALIC="\033[3m"
ANSI_UNDERLINE="\033[4m"
ANSI_RED="\033[91m"
ANSI_CYAN="\033[96m"
ANSI_ORANGE="\033[38;5;208m"
ANSI_YELLOW="\033[93m"
ANSI_ARGUMENT="${ANSI_ITALIC}${ANSI_BOLD}"
ANSI_COMMAND="${ANSI_BOLD}${ANSI_YELLOW}"
ANSI_FILEPATH="${ANSI_UNDERLINE}${ANSI_CYAN}"
ANSI_DEFAULT="\033[0m"

# ---- Set up our printUsage function

# Prints the example usage to stderr
# Call like so: `printUsage`
printUsage () {

  SCRIPT_NAME=./$(basename "$0")
  logStdErr ""
  logStdErr "Overview: This script can install or backup code snippets from IDEs (Xcode, VSCode)."
  logStdErr ""
  logStdErr "Usage:"
  logStdErr "    $SCRIPT_NAME --mode <list|install|backup> --ide <xcode|vscode> [--debug] [--help]"
  logStdErr ""
  logStdErr "Mandatory:"
  logStdErr "    ${ANSI_BOLD}--ide${ANSI_DEFAULT}: Specifies which IDE to install/backup the snippets to/from."
  logStdErr "        ${ANSI_ARGUMENT}xcode${ANSI_DEFAULT}: Apple's Xcode in default installation path."
  logStdErr "        ${ANSI_ARGUMENT}vscode${ANSI_DEFAULT}: Visual Studio Code in default installation path."
  logStdErr ""
  logStdErr "    ${ANSI_BOLD}--mode${ANSI_DEFAULT}: The mode for the script to operate in (list, install or backup)."
  logStdErr "        ${ANSI_ARGUMENT}list${ANSI_DEFAULT}: Print a list of the snippet files availabel to be installed."
  logStdErr "        ${ANSI_ARGUMENT}install${ANSI_DEFAULT}: Copies snippets from repo dir to IDE dir after copying all to a backup folder."
  logStdErr "        ${ANSI_ARGUMENT}install-clean${ANSI_DEFAULT}: Copies snippets from repo dir to IDE dir after moving all to a backup folder."
  logStdErr "          ${ANSI_ORANGE}Note${ANSI_DEFAULT}: Any exsting snippets will first be copied to a backup folder in the destination directory."
  logStdErr "        ${ANSI_ARGUMENT}backup${ANSI_DEFAULT}: Copies snippets from IDE dir into repo dir."
  logStdErr "          ${ANSI_ORANGE}Note${ANSI_DEFAULT}: Only files that begin with ${ANSI_ORANGE}'hatch_'${ANSI_DEFAULT} will be copied"
  logStdErr "          ${ANSI_ORANGE}Note${ANSI_DEFAULT}: This will result in an ${ANSI_RED}error${ANSI_DEFAULT} if user is still on 'main' git branch"
  logStdErr ""
  logStdErr "Optional:"
  logStdErr "    ${ANSI_BOLD}--debug${ANSI_DEFAULT}: Print debug level logs."
  logStdErr "    ${ANSI_BOLD}--help${ANSI_DEFAULT}: Print this message"
  logStdErr ""
  logStdErr "EX: (Xcode)"
  logStdErr "    List the Xcode snippets that are available to be installed."
  logStdErr "    \$ ${ANSI_COMMAND}$SCRIPT_NAME --ide xcode --mode list${ANSI_DEFAULT}"
  logStdErr ""
  logStdErr "    Install Xcode snippets onto your system."
  logStdErr "    \$ ${ANSI_COMMAND}$SCRIPT_NAME --ide xcode --mode install${ANSI_DEFAULT}"
  logStdErr ""
  logStdErr "    Back up Xcode snippets from your system to this directory (make your own pull request)."
  logStdErr "    \$ ${ANSI_COMMAND}$SCRIPT_NAME --ide xcode --mode backup${ANSI_DEFAULT}"
  logStdErr ""
  logStdErr "EX: (VSCode)"
  logStdErr "    List the VSCode snippets that are available to be installed."
  logStdErr "    \$ ${ANSI_COMMAND}$SCRIPT_NAME --ide vscode --mode list${ANSI_DEFAULT}"
  logStdErr ""
  logStdErr "    Install VSCode snippets onto your system."
  logStdErr "    \$ ${ANSI_COMMAND}$SCRIPT_NAME --ide vscode --mode install${ANSI_DEFAULT}"
  logStdErr ""
  logStdErr "    Back up VSCode snippets from your system to this directory (make your own pull request)."
  logStdErr "    \$ ${ANSI_COMMAND}$SCRIPT_NAME --ide vscode --mode backup${ANSI_DEFAULT}"
  logStdErr ""
}

# ---- Start parsing and checking our arguments & arguments with parameters. 

# Ensure our globals are cleared before populating with args
unset -v IS_DEBUG
unset -v IS_ADMIN
unset -v LIST_AUTHORS
unset -v TYPE

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

      if [[ "$MODE" != "list" && "$MODE" != "install" && "$MODE" != "install-clean" && "$MODE" != "backup" && "$MODE" != "rename" ]]; then
        logStdErr "[ERROR] Invalid value for '$1': '$2'. Options are 'list', 'install', 'install-clean', or 'backup'."
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

if [[ "$MODE" == 'list' ]]; then
  logStdErr "Available snippets: ${ANSI_FILEPATH}${REPO_SNIPPETS_DIR}${ANSI_DEFAULT}"
  logStdErr ""
  find "$REPO_SNIPPETS_DIR" -maxdepth 1  -type f | sed "s|$REPO_SNIPPETS_DIR|.|g" | grep -Ev '^.$' | grep -v 'DS_Store' | sort
  logStdErr ""
  logStdErr "Installed snippets: ${ANSI_FILEPATH}${CLIENT_SNIPPETS_DIR}${ANSI_DEFAULT}"
  logStdErr ""
  find "$CLIENT_SNIPPETS_DIR" -maxdepth 1  -type f | sed "s|$CLIENT_SNIPPETS_DIR|.|g" | grep -Ev '^.$' | grep -v 'DS_Store' | sort
elif [[ "$MODE" == 'rename' ]]; then
  if [[ "$IDE" != 'xcode' ]]; then
    logStdErr "[ERROR] rename mode is not compatible with $IDE."
    exit 10
  fi 

  # Get array of snippet files
  installed=()
  while IFS=  read -r -d $'\0'; do
      installed+=("$REPLY")
  done < <(find "${CLIENT_SNIPPETS_DIR}" -maxdepth 1 -type f -print0)
  
  # ensure that each snippet file is named the same as defined within the file. 
  for (( i=0; i<"${#installed[@]}"; i++)); do
    filename=$(basename "${installed[$i]}")
    snippetname=$(/usr/libexec/PlistBuddy -c "print :IDECodeSnippetTitle" "${installed[$i]}")
    corrected_filename="${snippetname}.codesnippet"

    if [[ "${filename}" != "${corrected_filename}" ]]; then 
      logdStdErr "installed[$i]:"
      logdStdErr "  snippet: ${snippetname}"
      logdStdErr "  filename: ${filename}"
      logdStdErr "  corrected_filename: ${corrected_filename}"
      command="mv \"${installed[$i]}\" \"${CLIENT_SNIPPETS_DIR}/${corrected_filename}\""
      logdStdErr "  command: ${command}"
      eval "$command"
    fi
  done

  logStdErr "Did rename installed ${IDE} snippet files to reflect the defined snippet name."
  # logdStdErr ""
  # logStdErr "Did move existing ${IDE} snippets to backup dir: ${ANSI_FILEPATH}${BACKUP_DIR}${ANSI_DEFAULT}"
elif [[ "$MODE" == 'install' || "$MODE" == 'install-clean' ]]; then
  # Backup all existing snippets before overwriting them. 
  # If dir is empty, no need to back anything up.
  if find "$CLIENT_SNIPPETS_DIR" -mindepth 1 -maxdepth 1 -not -path '*/.*' | read -r; then
    # Backup all existing snippets before overwriting them
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    BACKUP_DIR="${CLIENT_SNIPPETS_DIR}/backup_${TIMESTAMP}"
    logdStdErr "Backing up existing snippets to ${BACKUP_DIR}"
    mkdir "${BACKUP_DIR}"
    if [[ "$MODE" == 'install' ]];then 
      find "${CLIENT_SNIPPETS_DIR}" -maxdepth 1 -type f -print0 | xargs -0 -I {} cp {} "${BACKUP_DIR}"
      logStdErr "Did copy existing ${IDE} snippets to backup dir: ${ANSI_FILEPATH}${BACKUP_DIR}${ANSI_DEFAULT}"
    elif [[ "$MODE" == 'install-clean' ]]; then
      find "${CLIENT_SNIPPETS_DIR}" -maxdepth 1 -type f -print0 | xargs -0 -I {} mv {} "${BACKUP_DIR}"
      logStdErr "Did move existing ${IDE} snippets to backup dir: ${ANSI_FILEPATH}${BACKUP_DIR}${ANSI_DEFAULT}"
    else
      logStdErr "[ERROR] Unhandle value for MODE: ${MODE}"
      exit 1
    fi
  else
    logdStdErr "Skipping backup of existing snippets (dir is empty) ${BACKUP_DIR}"
  fi

  # Install the snippet
  cp "$REPO_SNIPPETS_DIR"/* "$CLIENT_SNIPPETS_DIR"
  logStdErr "Did install ${IDE} snippets to ${ANSI_FILEPATH}${CLIENT_SNIPPETS_DIR}${ANSI_DEFAULT}"

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
    

    if [[ "$IDE" == 'xcode' ]]; then
      # for xcode we want to rename the files as they are being copied

      # Get array of snippet files
      installed=()
      while IFS=  read -r -d $'\0'; do
          installed+=("$REPLY")
      done < <(find "${CLIENT_SNIPPETS_DIR}" -maxdepth 1 -type f -name "${TEAM_PREFIX}*.${SNIPPET_EXTENSION}" -print0)
      
      # logdStdErr "installed: ${installed[@]}"

      # ensure that each snippet file is named the same as defined within the file. 
      for (( i=0; i<"${#installed[@]}"; i++)); do
        filename=$(basename "${installed[$i]}")
        snippetname=$(/usr/libexec/PlistBuddy -c "print :IDECodeSnippetTitle" "${installed[$i]}")
        corrected_filename="${snippetname}.codesnippet"
        command="cp \"${installed[$i]}\" \"${REPO_SNIPPETS_DIR}/${corrected_filename}\""

        if [[ "${filename}" != "${corrected_filename}" ]]; then 
          # logdStdErr "installed[$i]:"
          # logdStdErr "  snippet: ${snippetname}"
          # logdStdErr "  filename: ${filename}"
          # logdStdErr "  corrected_filename: ${corrected_filename}"
          logStdErr "Renaming file: ${filename} to ${corrected_filename}"
        fi
        # logdStdErr "  command: ${command}"
        eval "$command"
      done
    else 
      set -x
      cp "${CLIENT_SNIPPETS_DIR}/${TEAM_PREFIX}"*."${SNIPPET_EXTENSION}" "${REPO_SNIPPETS_DIR}"
      set +x
    fi 




  done

  # TODO: zakkhoyt. For each snippet, update the XML so that the title matches the file name (Xcode only)

  log "Did back up ${IDE} snippets."
else 
  logStdErr "[ERROR] Unhandle value for MODE: ${MODE}"
  exit 1
fi
