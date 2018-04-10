# nutils

> Handle utility commands for NodeJS.

## Install

See the script [installation steps](https://github.com/simonrelet/scripts/tree/master/README.md#install).

## Usage

```
$ nutils <command>
```

The output is colored by default but will automatically be turned off in a CI environment (where the `CI` environment variable is set).

Some commands have a help that can be displayed:

```
$ nutils help <command>
```

## Commands

  * `help`: Show helps
  * `ln`: Link packages
  * `update`: Update the script to the latest version
  * `version`: Show the version of this script

### nutils ln

Create a symbolic link from a given package to its corresponding folder under _node_modules/_.
This allows working on both packages without the need of reinstalling them.

_Usage:_

```
$ nutils ln <package>
```

This command will not install the package but simply replace the installed folder with a symbolic link.
It also works with scoped packages.

Example:
```
$ pwd
/packages/awesome-feature
$ nutils.sh ln ../common-package/dist
success Package @murex/common-package@1.0.0 has been linked.
# now all changes in /packages/common-package/dist will be visible in
# /packages/awesome-feature/node_modules/@murex/common-package
```

### nutils update

Update the script to the latest version.
A confirmation will be asked before the update.

_Usage:_

```
$ nutils update
```
