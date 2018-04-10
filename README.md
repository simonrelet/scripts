# Scripts

> Useful scripts.

## Install

1. Create you working environment:

```sh
mkdir $HOME/bin
# add $HOME/bin to your $PATH
```

2. Download the desired script:

Set or replace `$SCRIPT_NAME` by the name of the script.

```sh
curl -s "https://raw.githubusercontent.com/simonrelet/scripts/$SCRIPT_NAME-latest/bin/$SCRIPT_NAME.sh" > $HOME/bin/$SCRIPT_NAME
chmod +x $HOME/bin/$SCRIPT_NAME
```

Or at a specific version (_use any valid tag_):

```sh
curl -s "https://raw.githubusercontent.com/simonrelet/scripts/$SCRIPT_NAME-v2.0.0/bin/$SCRIPT_NAME.sh" > $HOME/bin/$SCRIPT_NAME
chmod +x $HOME/bin/$SCRIPT_NAME
```

3. Use it:

```sh
$SCRIPT_NAME help
```

## Scripts

* [`stash`](https://github.com/simonrelet/scripts/tree/master/stash/): Handle Stash API through various commands
* [`nutils`](https://github.com/simonrelet/scripts/tree/master/nutils/): Handle utility commands for NodeJS
* [`sourcify`](https://github.com/simonrelet/scripts/tree/master/sourcify/): Resolve and replace `source` and `.` commands by the content of the file

## Contributing

Feel free to contribute by submitting a pull request:

0. Fork this repository
0. Create a new branch based on `master`
0. Push your modifications
0. Create a pull request from your branch to the `master` of this repository.

## Releasing

The scripts are modular and sourcified using [`sourcify`](https://github.com/simonrelet/scripts/tree/master/sourcify/).
The sourcified version are hosted on this repository under _bin/$SCRIPT_NAME.sh_.
A release consist of updating the sourcified scripts and merging them on `master`.
These scripts are updated with the following command:

```sh
sourcify $SCRIPT_NAME/main.sh > bin/$SCRIPT_NAME.sh
# or
# ./sourcify/main.sh $SCRIPT_NAME/main.sh > bin/$SCRIPT_NAME.sh
```
