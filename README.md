ocaml-crosscompiling
====================

Tests, notes, suggestions for Ocaml cross-compiling.

For now I'll assume as a starting point that you have an [Ocaml Android cross-compiler](https://github.com/cgreenhalgh/ocaml-android) installed plus ocamlfind, with the cross-compiler set up as the `android` ocamlfind toolchain; this is what you will get if you use [opam](http://opam.ocamlpro.com/) to install `ocaml-android` and `android-ocamlfind` from this [opam android repository](https://github.com/cgreenhalgh/opam-android-repository). By the way, that is all based on [Vouillon](https://github.com/vouillon)'s sterling work.

Goals:

* simple building using ocamlbuild with ocamlfind where all outputs are for the target system
* checking with intermediate modules/packages, and syntax extensions
* more complix building using ocamlbuild with ocamlfind where some outputs are for the build system (e.g. intermediate build tools)
* simple building using oasis where all outputs are for the target system
* more complex building using oasis where some outputs are for the build system

See...:
* [general notes on cross-compiling](docs/ocamlcrosscompiling.md)
* [notes on the ocaml-android cross-compiler](docs/ocamlandroid.md)
* [notes on ocamlbuild and cross-compiling](docs/ocamlbuildnotes.md)
* [notes on compiling Mirage for Android](docs/mirageonandroid.md)
* [a proposal for ocamlfind toolchain-based cross-compiling](docs/toolchainproposal.md)

