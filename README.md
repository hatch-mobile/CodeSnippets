# About 
A repo to share code snippets and and installer script. 

# How to Use

## Clone this repo

```sh
git clone git@github.com:hatch-mobile/CodeSnippets.git
cd CodeSnippets
```

## Usage 
```sh
$ ./snippets.sh --help
This script will install/backup code snippets from IDEs (Xcode, VSCode).

Usage:
    ./snippets.sh --mode <list|install|backup> --ide <xcode|vscode> [--debug] [--help]

Mandatory:
    --mode: The mode for the script to operate in (install or backup).
    --id: Specifies which IDE to install/backup the snippets to/from.

Optional:
    --debug: Print debug level logs.
    --help: Print this message

EX: (Xcode)
    List the Xcode snippets that are available to be installed.
    $ ./snippets.sh --mode list --ide xcode

    Install Xcode snippets onto your system.
    $ ./snippets.sh --mode install --ide xcode

    Back up Xcode snippets from your system to this directory (make your own pull request)/
    $ ./snippets.sh --mode backup --ide xcode

EX: (VSCode)

    List the VSCode snippets that are available to be installed.
    $ ./snippets.sh --mode list --ide vscode

    Install VSCode snippets onto your system.
    $ ./snippets.sh --mode install --ide vscode

    Back up VSCode snippets from your system to this directory (make your own pull request)/
    $ ./snippets.sh --mode backup --ide vscode
```
