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

You have to move all your dotfiles to a folder named `dotfiles` (see [my repo][3] for an example) and then the script will do the symbolic links. Doing it this way, you can now push them to your github repo (so you have a backup of them).

You should note that all of these dotfiles (files or folders) will be symlinked in `$HOME`. So, if you want to symlink, for example, something in `/etc`, you have to put it in the `dotfiles/other` folder. Here you have to be careful as they will be installed in `/`. You can see an example [here][2].

So, to run the script:

```bash
sh scripts/bootstrap.sh
```

By default, the script will run with `dialog`. However, the script can use either `dialog` or `whiptail` (`libnewt`) as a way to display dialog boxes, so if you want to use `whiptail`, you must use `-w` as a parameter.

Also, for compatibility reasons, the script will choose not to use `dialog` or `whiptail` if you don't have them installed. You can force this using the `-t` parameter.

Finally, you can run the script with `-l` if you want to print the log to the `sadedot.log` file (it will be created inside the `sadedot` folder).

Note that you can add shell scripts to a folder named `scripts` (see [my repo][3]) if you want to run them when `scripts/bootstrap.sh` is run. By default, it will not run these scripts, so you must use the `-p` flag (they will run at the end).

As an example, I will show [my repo][3] directories in a tree-like format (note that the folder named `sadedot` is this repository as a submodule):
```
.
├── dotfiles
│   └── ...
├── sadedot
│   └── ...
└── scripts
    └── ...
```

## Optional dependencies <a name="optdependencies"></a>

You can install `libnewt` or `dialog` for a better experience, but they are not required.

## Updating <a name="updating"></a>

To keep the submodule up to date, you need to run:

```bash
git submodule foreach git pull
```

## Contributing <a name="contributing"></a>
PRs are welcome.

## License <a name="license"></a>
[MIT](https://raw.githubusercontent.com/santilococo/sadedot/master/LICENSE.md)

[1]: https://github.com/santilococo/cdotfis/fork
[2]: https://github.com/santilococo/cdotfis/tree/master/dotfiles/other
[3]: https://github.com/santilococo/cdotfis
