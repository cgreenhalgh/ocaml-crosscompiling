# A Proposal for Ocaml cross-compiling based on Ocamlfind toolchains

See also: 
* [general notes on cross-compiling](ocamlcrosscompiling.md)
* [notes on the ocaml-android cross-compiler](ocamlandroid.md)
* [notes on ocamlbuild and cross-compiling](ocamlbuildnotes.md)
* [notes on compiling Mirage for Android](mirageonandroid.md)

Ocamlfind's -toolchain option provides a way for multiple toolchains to exist within (nominally) a single ocaml installation. This is used in the [ocaml-android cross-compiler](ocamlandroid.md) to effectively have a separate findlib.conf with its own toolchain and libraries for the target (in that case Android) platform.

In the general case a cross-platform build may include some elements that must be built for the build system (build-time tools, ocamlbuild plugins, syntax extensions and their dependencies) and some that must be built for the target system (final applications, packages to be used in final applications, tests to be run on the target system, their dependencies). So in general the build system must allow these to be distinguished within the overall build process.

Proposal: use the option `-toolchain XX` as a general way of specifying target vs build.

Specifically:

Change ocamlfind/findlib to support optional toolchains, e.g. `_build`, `_target`, `_default` (perhaps anything starting `_`) which emit an informational (`using default for optional toolchain _XX`) rather than a warning. 

Reason: a cross-compiler-compatible package can then safely refer to `_build` and `_target` toolchains in the build process to distinguish between built-time and run-time elements, and by default will just compile natively as normal.

Extend findlib to support toolchain aliases in findlib.conf, e.g. `toolchain(_target)="android"`. 

Reason: simplifies specification of _target and _build toolchains in a general way.

Add a `-toolchain XX` option to ocamlbuild, which if specified is passed to all built-in uses of ocamlfind, i.e. in findlib.ml (checking package dependencies) as well as in the selection of ocamlc, etc. in options.ml. 

Reason: simple way of specifying basic target vs build in ocamlbuild-based projects.

Add a `-toolchain XX` option to all the standard ocaml tools (ocamlc, ocamlopt, etc.) which, if present, causes them to exec `ocamlfind -toolchain XX YY ARGS` where YY is the tool run and ARGS is the original args minus the -toolchain XX option. 

Reason: simple way of specifying target vs build in non-ocamlbuild projects; also simplifies ocamlbuild extension to file-specific toolchain support.

Add support for a `toolchain(XX)` tag in ocamlbuild, which would be used by the standard build rules to specify `-toolchain XX` option to the standard tools. If -use-ocamlfind then the corresponding package query should also use the specific toolchain. 

Reason: allow specification of toolchain in _tags (e.g. hand specified, or from oasis or plugin), and allow per-file specification so that build and target files can be built in the same run of ocamlbuild.

The above should be enough for syntax extensions that are bytecode only with no native library dependencies. But in the more general case syntax extensions (and dependencies) will need to be built and installed in the _build toolchain, and an extra command line option (or careful definition/use of '-toolchain XX' will be needed to point the pre-processor at the _build toolchain packages and libraries.

