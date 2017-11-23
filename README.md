# OCaml REPL

This package, developed for [Brown CS17](https://cs.brown.edu/courses/csci0170/),
provides an OCaml REPL pane in Atom. It is forked from https://github.com/rndAdn/REPL-Nodejs
so that OCaml specific features can be supported.

## Additional features / Bug fixes

* Error highlighting
* Evaluation with fresh environment
* Automatic CWD change
* History glitches fixed
* Prompt glitches fixed

## Installation

```
apm install ocaml-repl
```

or

Search for `ocaml-repl` within package search in the Settings View.

## Settings
You can set the path to your executable in the package settings.


## Keybindings

* `ctrl-y ctrl-o` Launch an OCaml REPL in a fresh environment
* `ctrl-y ctrl-f` Run the file in a fresh environment
