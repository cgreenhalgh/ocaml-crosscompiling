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

## Simple projects with ocamlbuild and ocamlfind

in `simplebuild`... there is just a hello.ml file which prints hello world.

Check it works natively:

	ocamlbuild hello.native
	./hello.native
	# should print: Hello world!
	file _build/hello.native
	# should print something consistent with your build system, e.g.: _build/hello.native: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=0x7d0b59cbc96084258586a1fbe664500df2be6846, not stripped

	ocamlbuild hello.byte
	./hello.byte
	# should print: Hello world!

	ocamlbuild getpid.native -lib unix

	ocamlbuild -use-ocamlfind getpid.native -pkg unix

_tags file with:

	"getpid.native": package(unix)

	ocamlbuild -use-ocamlfind getpid.native

Trivial myocamlbuild.ml:

	open Ocamlbuild_plugin
	let _ = dispatch begin function
	   | _ -> ()
	end

ocamlbuild has some fixed built-in references to ocamlfind, in findlib.ml and in options.ml. The use in options.ml can be over-riden in myocamlbuild.ml (setting ocamlc, etc.), but the one in findlib.ml cannot, so if the packages differ in the native vs toolchain compilers then things will get confused. 

ocamlbuild uses ocamlbuild to make the plugin. This is done with -use-ocamlfind set as per the initial invocation. So we can safely make the plugin using `ocamlbuild -just-plugin` (NB not -use-ocamlfind).

With -use-ocamlfind we can't get it to use the right toolchain when checking package dependencies. So that is no good unless we hack ocamlbuild big time.

We could avoid -use-ocamlfind and work out the dependencies ourselves, e.g. in an old-style ocamlfind plugin. But we can't make the toolchain choice in ocamlbuild dependent on the file, so we can't make build and target things at the same time. But maybe that is OK.

So a minimal change would be allow ocamlbuild's ocamlfind to be over-riden, and/or allow a toolchain to be specified for the current command. Then make sure this is used in findlib.ml as well as on options.ml. 

A next elaboration would be allow a tag to specify toolchain on a per-file basis. But this would require changing all of the core commands. It would also require handling in the Findlib.query at least; not sure how this would play out (e.g. because of the recursive nature of that query vs possible tagging strategies).

