# stash

> Handle Stash API through various commands.

## Install

See the script [installation steps](https://github.com/simonrelet/scripts/tree/master/README.md#install).

## Usage

```
$ stash <command>
```

You can set the environment variable `DEBUG` to display debug information:

```
$ env DEBUG=true stash <command>
```

The output is colored by default but will automatically be turned off in a CI environment (where the `CI` environment variable is set).

Some commands have a help that can be displayed:

```
$ stash help <command>
```

### Configuration files

  * User configurations file: _$HOME/.stashrc_.
  * Repository configurations files: _/path/to/git/repository/**/.stashrc_.

The configurations are ini-formatted files which contains key values pairs that will be read by the commands.
The bellow commands documentation specify the format of all the configuration they require.

## Commands

* `help`: Show helps
* `login`: Save credentials in the user configuration file
* `pr`: Create a pull request
* `update`: Update the script to the latest version
* `version`: Show the version of this script

### stash login

Save credentials of a Stash user in the user configuration file: _$HOME/.stashrc_.

_Usage:_

```
$ stash login
```

**The credentials must never be added in a repository configuration file.**

### stash pr

Create a pull request from the current branch to the a specific branch of a specific repository.
A Stash user must be logged in with the login command.

_Usage:_

```
$ stash pr [options]
```

_Options:_

* `-b`, `--branch=name`: Destination branch
* `-r`, `--reviewer=login`: Login of a reviewer, can be repeated

The options will override the values set in the configuration files, except for the `--reviewer` which will be merged.
Arguments of long options are also required for short options.

_Configuration:_

The repository root configuration file can contain the following variables:

* `branch`: Destination branch, 'master' by default
* `project`: Project name, the current one by default
* `repository`: Repository name, the current one by default
* `reviewer`: Login of a reviewer, can be repeated

Any other configuration file in the repository can contain the following variables:

* `reviewer`: Login of a reviewer, can be repeated

The list of reviewers will be the result of the merge of all the repository configuration files, starting from the current folder and ending at the root of the repository.

Any repository allowing pull requests from forks should set the `project` and `repository` variables.

Example of repository root configuration file:

```
project=ui
repository=web-library
reviewer=srelet
reviewer=pbeitz
```

Also work with private repositories:

```
project=~srelet
repository=dev-scripts
branch=dev
reviewer=srelet
reviewer=pbeitz
```

Any valid Stash login can be used as reviewer, even the current user.
It will simply be ignored by Stash.

This command can be used from any sub-folder of a git repository.
If you are in a submodule, the pull request will be created for the submodule using its own configuration files.

_Example:_

```
# srelet is the login of the current Stash user
$ cd /path/to/git/repository/
$ cat .stashrc
project=~srelet
repository=awesome
reviewer=pbeitz
reviewer=srelet
$ cd /sub/folder/
$ cat .stashrc
reviewer=ftingaud
$ stash pr -r yfomena
# create a pull request with the reviewers: 'ftingaud', 'pbeitz' and
# 'yfomena' for the repository 'awesome' in the '~srelet' project
```

### stash update

Update the script to the latest version.
A confirmation will be asked before the update.

_Usage:_

```
$ stash update
```
