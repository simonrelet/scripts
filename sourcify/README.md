# sourcify

> Resolve and replace `source` and `.` commands by the content of the file.

## Install

See the script [installation steps](https://github.com/simonrelet/scripts/tree/master/README.md#install).

## Usage

```
$ sourcify <file>
$ sourcify <command>
```

This allows to modularize scripts in order to simplify their development and to still release them in a single file.
Each file will only be sourced once.

When a `<file>` is given, the sourcified result will be printed on the standard output.

Sourcify blocks can be used to remove all non `source` commands inside it.
This allows to execute instructions that are only relevent when the script is still modularized.
The block starts by the comments `# @sourcify_start` and ends at `# @sourcify_end` or at the end of the file.
These comments must be on their own line.
Do not use variables declared in the sourcify block, they will also be removed.

Only the shebang of the main script will be kept, all other will be ignored.

The paths are relative to the sourcing file and must be static.

_Example:_

```sh
$ cat utils.sh
#! /bin/bash
greetings () { printf "Hello!\n"; }
$ cat main.sh
#! /bin/bash
# @sourcify_start
# ensure we source utils.sh relatively to the current script folder
pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" > /dev/null 2>&1
source utils.sh
popd > /dev/null 2>&1
# @sourcify_end
greetings
$ sourcify main.sh
#! /bin/bash
# [...]
# @sourcify_start: utils.sh
greetings () { printf "Hello!\n"; }
# @sourcify_end: utils.sh
greetings
```

The output is colored by default but will automatically be turned off in a CI environment (where the `CI` environment variable is set).

Some commands have a help that can be displayed:

```
$ sourcify help <command>
```

## Commands

  * `help`: Show helps
  * `update`: Update the script to the latest version
  * `version`: Show the version of this script

### sourcify update

Update the script to the latest version.
A confirmation will be asked before the update.

_Usage:_

```
$ sourcify update
```
