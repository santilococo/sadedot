# CocoRice

[Fork][1] this repository and you will be able to backup all your dotfiles (and easily install them on another machine).

## Table of contents
  - [Installation <a name="installation"></a>](#installation-)
  - [Usage <a name="usage"></a>](#usage-)
  - [Dependencies <a name="dependencies"></a>](#dependencies-)
  - [Contributing <a name="contributing"></a>](#contributing-)
  - [License <a name="license"></a>](#license-)

## Installation <a name="installation"></a>

Fork or clone this repo.

## Usage <a name="usage"></a>

Run

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
