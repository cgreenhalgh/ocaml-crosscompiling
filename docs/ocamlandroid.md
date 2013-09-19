# Ocaml-Android

Notes on trying/using/fixing Vouillon's [ocaml-android](https://github.com/vouillon/ocaml-android) cross-compiler with [OPAM](http://opam.ocamlpro.com/) based on Vouillon's [android opam repo](https://github.com/cgreenhalgh/opam-android-repository).

Status: Fixed a few bugs. All seems to work (except for the issues Vouillon noted with running bytecode executables). Slightly clunky having to build target-specific OPAM packages.

Contents: 
* Ocaml on Android
* ocaml-android's approach to cross-compiling
* making a cross-compiler

## Ocaml on Android 

[Keigo](https://sites.google.com/site/keigoattic/ocaml-on-android) seems to be the root of much OCaml on Android work. His patch is Ocaml 3.12.1 (and NDK n7). He also wrote an initial [top-level](https://bitbucket.org/keigoi/ocaml-toplevel-android/src). This includes [vouillon](https://github.com/vouillon/ocaml-android) which was active approx. Feb 2013, and Vernoux's [Ocaml top-level for Android](https://play.google.com/store/apps/details?id=fr.vernoux.ocaml&hl=en). 

Vouillon's version appears to be Ocaml 4.00.1 and include LWT according to [this post](https://sympa.inria.fr/sympa/arc/caml-list/2013-01/msg00173.html). He also has an [Opam respository](https://github.com/vouillon/opam-android-repository/) for this.

OK, here is my [fork of vouillon's android opam repo](https://github.com/cgreenhalgh/opam-android-repository). 

Problems with Vouillon's opam/cross compiler:
* 4.00.1 ocamlbuild does NOT Use ocamlfind for ocamlmklib and does NOT include `-ocamlmklib` override option. Hopefully fixed in [this ocamlbuild patch](https://github.com/cgreenhalgh/ocaml/commit/f617a0fb82421e3da2f7ea849b5d83c3a3c416fa.patch) and applied by my opam compiler spec 4.00.1+mirage-android in [my opam repo](https://github.com/cgreenhalgh/opam-android-repository).  
* One package in Vouillon's opam repository have hard-coded paths, i.e. `https://github.com/vouillon/opam-android-repository/blob/master/packages/android-lwt.2.4.3/opam` has `/home/jerome/.opam/4.00.1/bin/arm-linux-androideabi-ocamlfind`. Edit in ~/.opam/repo/android/packages/android-lwt.2.4.3/opam to `"%{prefix}%/bin/arm-linux-androideabi-ocamlfind"`; fixed in [my opam repo](https://github.com/cgreenhalgh/opam-android-repository). 
* android-ocamlfind doesn't specific an ocamlfind version and should (1.3.3): edit ~/.opam/repo/android/packages/android-ocamlfind.1.3.3/opam. Fixed in [my opam repo](https://github.com/cgreenhalgh/opam-android-repository). 
* Ocaml-android doesn't seem to use toolchain ld in config/Makefile `PARTIALLD` (blows up in mirage-platform). Fixed in [my fork of ocaml-android](https://github.com/cgreenhalgh/ocaml-android) [0.1.10-ld](https://github.com/cgreenhalgh/ocaml-android/archive/0.1.10-ldocaml-android's approach to cross-compiling.tar.gz) and referenced in [my opam repo](https://github.com/cgreenhalgh/opam-android-repository). 
* android-ocamlfind (opam files/Android.conf.in) is missing ldconf(android) from `findlib.conf.d/android.conf` (should be `.../arm-linux-androideabi/lib/ocaml/ld.conf`), so that it mixes up host and target libraries. Fixed in [my opam repo](https://github.com/cgreenhalgh/opam-android-repository).

Build with my fork of opam repo:
* add repo as per github readme: `opam repo add android https://github.com/cgreenhalgh/opam-android-repository.git`
* `opam switch 4.00.1+mirage-android` - includes ocamlbuild patch from [my ocaml fork](https://github.com/cgreenhalgh/ocaml) which should make ocamlbuild use ocamlfind for ocamlmklib for correct toolchain support
* `opam install ocaml-android` - includes my fix for using toolchain ld
* `opam install android-ocamlfind`

To test it out try the instructions under Test on [Keigo's page](https://sites.google.com/site/keigoattic/ocaml-on-android)... but (having used opam) 

	echo 'print_endline "Hello, OCaml-Android!";;' > hello.ml
	ocamlfind -toolchain android ocamlopt hello.ml -o hello
	file hello
	adb push hello /data/local/tmp
	adb shell /data/local/tmp/hello
	> Hello, OCaml-Android!

* "opam install android-lwt" - includes fix for path in opam repo.

Note ocaml-android adds a symlink to camlp4 libraries on the system in `$(ANDROID_PREFIX)/lib/ocaml/camlp4` (since these will be running on the host, not the target). 

Note that (as reported in the [readme](https://github.com/vouillon/ocaml-android)) there is a problem building/running bytecode executables made with ocaml-android.


## ocaml-android's approach to cross-compiling

[Vouillon](https://github.com/vouillon/opam-android-repository/) has created target-specific opam packages which includes custom build configuration, which typically overrides the choice of ocamlfind.

The ocaml cross-compiler is installed within but essentially independently of the current opam switch compiler. The cross-compiler is made available as a custom toolchain in ocamlfind (or by using a target-specific ocamlfind). In practice this is a separate installation (could be a separate findlib.conf) rather a typical toolchain fix, as it specifies its own destdir, stdlib and ldconf, not just the various build tools.

Good points:

* often no build-related changes to package source
* typically small changes to opam build and remove specifications, which are fairly standard for packages using oasis

Bad points:

* Cannot directly use existing opam packages, even for simple cases
* doesn't work with standard `ocamlbuild -use-ocamlfind` because this doesn't have a standard way to override the choice of ocamlfind or specify a toolchain, and if it did uses the same ocamlfind to build both the plugin and other files. A partial work-around is to do `ocamlbuild -just-plugin` first, then set OCAMLFIND_CONF to just use the cross-compiler & libs and ocamlbuild again. In theory `ocamlbuild -byte-plugin` might also work, but when compiling it demands a unix stub DLL for the target but when running requires it for the build platform.

## Making a cross-compiler

This but is just my notes to self, really working through the ocaml-android cross-compiler build process...

[ocaml source](https://github.com/ocaml/ocaml) - [my fork](https://github.com/cgreenhalgh/ocaml).

For native compiler ./configure should work; just specify `-prefix <install-path>`. Standard build is then (something like):

	./configure -prefix ~/android/ocaml-native
	make world
	make install

Or a more restrained build should do:

	./configure -prefix ~/android/ocaml-native
	make OTHERLIBRARIES="unix str num dynlink" BNG_ASM_LEVEL=0 world
	make OTHERLIBRARIES="unix str num dynlink" BNG_ASM_LEVEL=0 install

Perhaps I should then make again but not install for the new prefix (otherwise ocamlbuild is kept and is configured for native prefix!) (this should include camlp4out, not opt/native):

	./configure -prefix ~/android/ocaml-cross
	make OTHERLIBRARIES="unix str num dynlink" BNG_ASM_LEVEL=0 world

The native C toolchain needs to be installed. [ocaml-android](https://github.com/vouillon/ocaml-android/) uses the [Android NDK](http://developer.android.com/tools/sdk/ndk/index.html) which includes pre-built tools and is available for windows, Mac OS X and Linux (each 32 or 64 bit). E.g. [Linux 64 bit NDK](http://dl.google.com/android/ndk/android-ndk-r9-linux-x86_64.tar.bz2). Specific config used are SYSROOT `.../platform/android-14/arch-arm` and ANDROID_PATH `.../toolchains/arm-linux-androideabi-4.7/prebuilt/$(ARCH)-x86/bin`. Note that this eabi is not include by default with NDK r9 (try 4.6 or 4.8). 

Following [ocaml-android](https://github.com/vouillon/ocaml-android/) the next steps are:

* configure for Android by copying in custom config/m.h, config/s.h and config/Makefile, including fixing up the installation and dependency paths in the Makefile
* apply patches (which could have been done earlier) (`patch -p 0 < ...`), which are:
  * memory.patch - byterun/misc.h - header name clash
  * ocamlbuild.patch - ocamlbuild/ocaml_specific.ml - optional removal of shared library rule
  * system.patch - asmrun/signals_osdep.h, otherlibs/unix/getpw.c, otherlibs/unix/termios.c - workaround lack of sys/ucontext.h, lack of pw gecos and tcdrain
* save byterun/ocamlrun
* clean up native build (selective):

	make -C byterun clean
	make -C stdlib clean
	make -C otherlibs/unix clean
	make -C otherlibs/str clean
	make -C otherlibs/num clean
	make -C otherlibs/dynlink clean

* build byterun and keep byterun/ocamlrun:

	make -C byterun all
	mkdir -p ~/android/ocaml-cross/bin
	cp byterun/ocamlrun ~/android/ocaml-cross/bin/ocamlrun.target

* put back the native one:

	cp ~/android/ocaml-native/bin/ocamlrun byterun/

* make the rest (be selective... don't world/coldstart!)

	make coreall opt-core otherlibraries otherlibrariesopt
	make ocamltoolsopt
	make install

Note: can't make camlp4out at this stage because of incompatible dllunix.so

* possibly replace camlp4 stuff - not quite sure why at the moment:

	#rm -rf $(ANDROID_PREFIX)/lib/ocaml/camlp4
	#ln -sf $(STDLIB)/camlp4 $(ANDROID_PREFIX)/lib/ocaml/camlp4


