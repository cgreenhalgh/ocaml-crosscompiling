# Ocaml cross-compiling

Some general notes/reflections on Ocaml cross-compiling. 

See also:
* [notes on the ocaml-android cross-compiler](ocamlandroid.md)
* [notes on ocamlbuild and cross-compiling](ocamlbuildnotes.md)
* [notes on compiling Mirage for Android](mirageonandroid.md)
* [a proposal for ocamlfind toolchain-based cross-compiling](toolchainproposal.md)

## Thoughts on Cross-compiling

I'll assume: 

* using opam
* using ocamlbuild
* using ocamlfind

I'll consider:

* using oasis
* using ocamlfind toolchains

Goals:

* require no changes to simple packages
* require minimal changes to complex packages
* same package can support multiple targets, including native, not just a single target

General observations/reality checks:

* most projects contain some source to support the build (to run on the build machine) and some source for the target (to run on the target machine), so in general both native toolchain and cross-compiling toolchain must be present.
* legacy packages don't distinguish explicitly which is which
* myocamlbuid.ml will almost always be build only
* syntax extensions will be used on build only and should be bytecode, although they may have dependences on modules that are also target depedencies
* the build tools themselves will need ocaml stublibs (e.g. dllunix.so) for the build platform while building the target executables will expects stublibs for the target platform. 
* in an oasis project some additional inferences can be made, e.g. BuildTools: x implies x runs on build, Executable x install: true may imply x runs on build, but some are unclear, e.g. whether BuildDepends are build and/or target dependencies 
* there are lots of different build approaches around, even in opam packages, including Makefiles, ocamlbuild extensions, oasis, other custom build frameworks, ...

Some options:

* opam switch is intended to manage different compilers, and you need at least the native compiler and the cross-compiler. So why not have one for each? 
* an environment variable, e.g. set by the opam compiler set-up, could indicate to all build processes that this is a cross-compilation. It would make sense for this to be in the cross-compiler.
* access to different compilers could be ocamlfind/findlib configuration. Separate findlib.conf or toolchain?!
* ocamlbuild for the cross-compiler could know how to use/find native tools and libraries for myocamlbuild, e.g. a custom (native) ocamlfind for those, or a native ocamlbuild (since ocamlbuild seems to have default paths built in).
* ocamlbuild _tags could also be used distinguish build-time targets (or specify custom ocamlfind). 
* oasis could be extended to (a) make best guess at setting these tags and (b) include options to specify explicitly in _oasis.

See also [a proposal for ocamlfind toolchain-based cross-compiling](toolchainproposal.md)

### ocaml-android's approach

See [notes on the ocaml-android cross-compiler](ocamlandroid.md)

### Background

There are various examples of building and using Ocaml cross-compilers, but they are generally then hand/custom building applications. So no real emphasis on packaging, or transparently allowing native and (multiple) cross-compiled. 

From [opam git](https://github.com/OCamlPro/opam/blob/master/src/client/opamArg.ml) re `opam config exec`:

	Execute the shell script given in parameter with the correct environment variables. 
        This option can be used to cross-compile between switches using 
        $(b,opam config exec \"CMD ARG1 ... ARGn\" --switch=SWITCH)

### Now using the cross-compiler...

#### ocamlfind

ex. [opam ocamlfid](https://github.com/mirage/opam-repository/blob/master/packages/ocamlfind.1.4.0/opam)

Hmm. Well, it is a build tool, so needs to run on the build platform, so should be compiled with the native toolchain. 

But it also configures itself using information obtained by running some of the ocaml commands, which should therefore be the cross-compiler toolchain.

So (not surprisingly) this will need some special handling. And the build should be cross-compile-aware. As a minimum the build will need to know where to find the native toolchain, e.g. the native install prefix, say `OCAML_NATIVE_BIN`.


