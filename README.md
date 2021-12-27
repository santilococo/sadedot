# CocoRice

Backup all your dotfiles (and easily deploy them on another machine).

## Table of contents
  - [Installation <a name="installation"></a>](#installation-)
  - [Usage <a name="usage"></a>](#usage-)
  - [Dependencies <a name="dependencies"></a>](#dependencies-)
  - [Contributing <a name="contributing"></a>](#contributing-)
  - [License <a name="license"></a>](#license-)

## Installation <a name="installation"></a>

[Fork][1] this repository.

## Usage <a name="usage"></a>

You have to move all your dotfiles to the dotfiles folder and then the script will do the symbolic links. Doing it this way, you can now upload them to your repository (to have a backup of them). 

You should note that all these dotfiles (files or folders) will be symlinked in `$HOME`. So, if you want to symlink, for example, something in `/etc`, you have to put it in the `dotfiles/other` folder. Here you have to be careful as they will be installed in `/`. You can see an example in this repository.

So, to run the script:

```bash
sh scripts/bootstrap.sh
```

By default the script will run with whiptail (`libnewt`). 

However, the script can use both `dialog` and `whiptail` as a way to display dialog boxes, so if you want to use dialog you have to pass `-d` as a parameter, and if you want to use whiptail `-w`.

For example, you can run

```bash
sh scripts/bootstrap.sh -d
```
to use dialog.

## Dependencies <a name="dependencies"></a>

You must install `libnewt` or `dialog`.

## Contributing <a name="contributing"></a>
PRs are welcome.

## License <a name="license"></a>
[MIT](https://choosealicense.com/licenses/mit/)

[1]: https://github.com/santilococo/CocoRice/fork
