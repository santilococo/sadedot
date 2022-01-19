# sadedot

Backup all your dotfiles (and easily deploy them on another machine).

## Table of contents
  - [Installation <a name="installation"></a>](#installation-)
  - [Usage <a name="usage"></a>](#usage-)
  - [Optional dependencies <a name="optdependencies"></a>](#optdependencies-)
  - [Updating <a name="updating"></a>](#updating-)
  - [Contributing <a name="contributing"></a>](#contributing-)
  - [License <a name="license"></a>](#license-)

## Installation <a name="installation"></a>

This repo is supposed to be used as a submodule. So, if you already have a git repo with your dotfiles:

```bash
git submodule add git@github.com:santilococo/sadedot.git
git submodule update --init
```

And if you don't, you can [fork][1] my dotfiles repo on github.

## Usage <a name="usage"></a>

You have to move all your dotfiles to the dotfiles folder and then the script will do the symbolic links. Doing it this way, you can now upload them to your repository (to have a backup of them).

You should note that all these dotfiles (files or folders) will be symlinked in `$HOME`. So, if you want to symlink, for example, something in `/etc`, you have to put it in the `dotfiles/other` folder. Here you have to be careful as they will be installed in `/`. You can see an example [here][2].

So, to run the script:

```bash
sh scripts/bootstrap.sh
```

By default the script will run with whiptail (`libnewt`).

However, the script can use both `dialog` and `whiptail` as a way to display dialog boxes, so if you want to use dialog you have to pass `-d` as a parameter.

For example, you can run

```bash
sh scripts/bootstrap.sh -d
```
to use dialog. 

Also, for compatibility reasons, the script will choose not to use the `dialog` or `whiptail` if you don't have them installed. You can force this using the `-t` parameter.

Finally, you can run the script with `-l` if you want to print the log in the `sadedot.log` file.

Note that you can modify the `scripts/install.sh` if you want to install some programs on your machine when this script is run. By default, `scripts/bootstrap.sh` will not run this script, so you will need to use the `-p` flag if you want it to run `scripts/install.sh` (it will run at the end of the `scripts/bootstrap.sh` script).

## Optional dependencies <a name="optdependencies"></a>

You can install `libnewt` or `dialog` for a better experience, but they are not required.

## Updating <a name="updating"></a>

To keep the submodule up to date, you need to run

```bash
git submodule foreach git pull
```

## Contributing <a name="contributing"></a>
PRs are welcome.

## License <a name="license"></a>
[MIT](https://raw.githubusercontent.com/santilococo/sadedot/master/LICENSE.md)

[1]: https://github.com/santilococo/dotfiles/fork
[2]: https://github.com/santilococo/dotfiles/tree/master/dotfiles/other
