# About 
A repo to share code snippets and and installer script. 

# How to Use

## Clone this repo

```sh
git clone git@github.com:hatch-mobile/CodeSnippets.git
cd CodeSnippets
```

## Usage 

TLDR: If you just want to install the Xcode snippets onto your dev machine:
```
# list snippets
./snippets.sh --ide xcode --mode list

# install snippets
./snippets.sh --ide xcode --mode install 
```

For an understanding of what this tool can do, invoke the `--help` page:

![Code_20240124124216@2x](https://github.com/hatch-mobile/CodeSnippets/assets/2229408/da83562c-2aa2-4e7c-831f-ea050779df5c)

<img src="https://github.com/hatch-mobile/CodeSnippets/assets/2229408/da83562c-2aa2-4e7c-831f-ea050779df5c" width="50%">


```
This script will install/backup code snippets from IDEs (Xcode, VSCode).

Usage:
    ./snippets.sh --mode <list|install|backup> --ide <xcode|vscode> [--debug] [--help]

Mandatory:
    --mode: The mode for the script to operate in (list, install or backup).
        list: Print a list of the snippet files availabel to be installed.
        install: Copies snippets from repo dir to IDE dir. Note: Any exsting snippets will first be copied to a backup folder in the destination directory.
        list: Print a list of the snippet files availabel to be installed.

    --ide: Specifies which IDE to install/backup the snippets to/from.
        xcode: Apple's Xcode in default installation path.
        vscode: Visual Studio Code in default installation path.

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
