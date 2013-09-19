# Mirage on Android

Trying to get [Mirage](http://openmirage.org) running on Android...

Status: work in progress (2013-09-17) - Ocaml 4.00.1 cross-compiler working; Mirage pre-reqs building with opam; Mirage basic and website_static examples working on Android as native unix/direct applications. Mirari not (yet) used.

Contents:

* Introduction
* Mirage on Unix (general)
* Notes on Building Mirage (general)
* Package specific build details

## Introduction

[Mirage](http://openmirage.org/) is an experimental "unikernel" project using Ocaml, i.e. compiles applications to bootable VM images suitable for Xen (or to a Unix process for testing/development).

It might be a useful way to create services in Ocaml that are safe, optimised and reasonably portable, at least to Unix and Xen.

## Mirage on Unix

More Mirage on the Xen Wiki: [Mirage architecture](http://wiki.xenproject.org/wiki/Mirage_architecture), including links to other docs including [Compile Mirage](http://wiki.xenproject.org/wiki/Compile_Mirage), which in turn points to [OPAM install](http://opam.ocamlpro.com/doc/Quick_Install.html) which has Ubuntu-specific instructions. This gives ocaml-4.00.1 and opam 1.0.0 as of 2013-09-12. 

A few notes on getting started with Mirage on Unix as of 2013-09-12:

* Right now, this seems to be the most complete/up-to-data [install guide](http://openmirage.org/wiki/install)
* it wasn't obvious from the introductory documentation on the Xen wiki that you can't opam install mirage-xen and mirage-unix at the same time, so if you have installed for one target (or mirari has done for you) then you need to "opam switch ..." (and/or "opem remove ..." it) before you can install/build for the other target.
* mirari 0.9.7 seems to require --socket as an explicit argument whereas some documentation suggests it was the default before (now defaults to direct?!).
* mirage 0.9.6 doesn't seem to print console output; had to use Mort's version, https://github.com/mor1/mirage
* mirage is a kind of virtual package in opam, and the actual building is done by mirage-unix (or mirage-xen); consequently you have to opam pin mirage-unix as well or instead of mirage to get that version
* most of the [mirage-skeleton examples](https://github.com/mirage/mirage-skeleton) compile and run, including basic and the simple web server, but some don't (I've only tried the UNIX socket targets).

## Ocaml on Android 

See [ocaml android](ocamlandroid.md)

The rest assumes you have used [my opam repo](https://github.com/cgreenhalgh/opam-android-repository) to build/install ocaml-android, android-ocamlfind and android-lwt.

## Notes on Building Mirage

The Mirage release (currently 0.9.6) is via the standard opam repository. There is also a [mirage project fork of the opam repository](https://github.com/mirage/opam-repository).

Opam packages and dependencies as of mirage 0.9.6:

* mirage-net-socket 0.9.4 requires mirage >= 0.9.5 & ocamlfind
* mirage 0.9.6 requires mirage-unix 0.9.6 OR mirage-xen 0.9.6
* mirage-unix 0.9.6 requires cstruct >= 0.7.1 & ocamlfind & lwt >= 2.4.0 & shared-memory-ring >= 0.4.1 & tuntap >= 0.6 & ipaddr >= 0.2.2 & fd-send-recv
* [cstruct](https://github.com/mirage/ocaml-cstruct) >= 0.7.1 requires ocamlfind & ocplib-endian, optionally async | lwt
* ocamlfind has no dependencies
* [ocplib-endian](https://github.com/OCamlPro/ocplib-endian) requires ocamlfind, optcomp
* optcomp requires ocamlfind
* lwt >= 2.4.0 depends on ocamlfind, optionally base-threads (installed by default) | base-unix (installed by default) | conf-libev (not installed) | ssl (not installed) | react (not installed) | lablgtk (not installed) | ocaml-text (not installed)
* shared-memory-ring >= 0.4.1 depends on cstruct >= 0.6.0 & lwt & ocamlfind & ounit
* ounit depends on ocamlfind
* tuntap >= 0.6 depends on ocamlfind & ipaddr >= 0.2.2
* [ipaddr](https://github.com/mirage/ocaml-ipaddr) >= 0.2.2 depends on ocamlfind
* fd-send-recv depends on ocamlfind

optional:

* [async](https://github.com/janestreet/async) (optional) - dependencies not shown here

Additionally required for mirage-skeleton static_website:

* re (currently 1.2.1), requires ocamlfind.
* uri (currently 1.3.8), requires ocamlfind, re, optional ounit >1.0.2
* cohttp.mirage (cohttp.0.9.10 ?), requires "ocamlfind" "re" "uri" {>="1.3.2"} "ounit" "cstruct", optionally "async" {>="109.15.00"} "lwt" {>="2.4.3"} "mirage-net" {>="0.5.0"}  

Mirage applications are build using [mirari](https://github.com/mirage/mirari), currently release 0.9.7. This requires cmdliner & tuntap >= 0.5 & fd-send-recv.

Mirari uses a *.conf file to work out what to do. This includes:

* depends - a list of ocamlfind libraries
* packages - a list a opam packages that provide the depends libraries
* compiler - an opam compiler (i.e. argument for opam switch)

"mirari configure --socket" sets up the build environment for the application, including using opam to install the listed packages. The github readme is not completely consistent with mirari 0.9.7. In particular, mirari configure createss:

* backend.ml - for Unix, anyway, which provides a runtime interface for mirari to talk to the application
* main.ml - a standard main, which depends on the type of application, i.e. main-http = Cohttp callback, main-ip = with Netmanager (called with args net mgr, interface, ip), main-noip = without networking (called with no args) 
* Makefile - a pretty standard makefile which has targets to clean and to build using ocamlbuild configured to use ocamlfind  
* myocamlbuild.ml - a standard ocamlbuild, which I'm not clear exactly why it is needed at the moment as options look fairly standard

For Unix, mirari build just calls "make build" and links the native executable to mir-NAME. 

I haven't tried to use/fix mirari for cross-compilation - just trying to build directly.

## Package specific build details

Hopefully in build/dependency order...

Fixes should be migrated into [my opam repo](https://github.com/cgreenhalgh/opam-android-repository).

### fd-send-recv

In [my opam repo](https://github.com/cgreenhalgh/opam-android-repository) as `opam install android-fd-send-recv`.

See [variant archive](https://github.com/cgreenhalgh/ocaml-fd-send-recv/tree/ocaml-fd-send-recv-1.0.1-nostatvfs) where I have removed include of statvfs.h. 

#### Working notes:

[archive]("https://github.com/xen-org/ocaml-fd-send-recv/archive/ocaml-fd-send-recv-1.0.1.tar.gz")

Implements `send_fd`, `recv_fd`, `fd_of_int` and `int_of_fd`. Includes native C library which uses sendmsg and recvmsg. I'm not sure that this is strictly required for the UNIX socket version. 

Opam build:
* make
* make install

Includes Makefile, plus myocamlbuild.ml and setup.ml generated by oasis. Includes `_oasis` and `_tags`.

Initially: `lib/fd_send_recv_stubs.c:24:25: fatal error: sys/statvfs.h: No such file or directory`
It doesn't actually look like it needs this include anyway! 

See [git fork](https://github.com/cgreenhalgh/ocaml-fd-send-recv/tree/ocaml-fd-send-recv-1.0.1-nostatvfs) where I have removed it. Check this out and...

	oasis setup
	ocaml setup.ml -configure --override ocamlfind `opam config var prefix`/bin/arm-linux-androideabi/ocamlfind
	ocaml setup.ml -build
	ocaml setup.ml -install

### optcomp

In [my opam repo](https://github.com/cgreenhalgh/opam-android-repository) as `opam install android-optcomp`.

#### Working notes:

[archive](https://forge.ocamlcore.org/frs/download.php/1011/optcomp-1.4.tar.gz)

Version 1.4. Required by ocplib-endian. 

Has `_oasis`. No native files. 
Opam build: `"./configure" "--prefix" "%{prefix}%"; make; make "install"`

Requires camlp4, camlp4.lib & camlp4.quotations.o.

This is actually a compile-time tool so in is the host version that is required, not the target version. So I think we need to fool the android toolchain into reporting that it has it. 

	opam install optcomp

Now try and make the android toolchain think it has it too - let's try the following and see...

	ln -s `opam config var prefix`/lib/optcomp `opam config var prefix`/arm-linux-androideabi/lib/

### ocplib-endian

In [my opam repo](https://github.com/cgreenhalgh/opam-android-repository) as `opam install android-ocplib-endian`.

#### Working notes

[ocplib-endian](https://github.com/OCamlPro/ocplib-endian 
[archive](https://github.com/OCamlPro/ocplib-endian/archive/0.4.tar.gz)

Required by cstruct. No native code. Has `_oasis`.

Requires package optcomp.

Trying...

	oasis setup
	ocaml setup.ml -configure --override ocamlfind `opam config var prefix`/bin/arm-linux-androideabi/ocamlfind --disable-debug
	ocaml setup.ml -build
	ocaml setup.ml -install

Seemed to work.

### cstruct

In [my opam repo](https://github.com/cgreenhalgh/opam-android-repository) as `opam install android-cstruct`.

#### Working notes

[cstruct](https://github.com/mirage/ocaml-cstruct)
[archive](https://github.com/mirage/ocaml-cstruct/archive/ocaml-cstruct-0.7.1.tar.gz)

Configured using Oasis. Includes native cstruct_stubs.c - portable memory copying only.
Has extra Makefile configuration to check if lwt and async installed, and if target is Xen (disable unix).

Hmm. But probably has both compiler syntax extensions and target support code. Former is Library `cstruct-syntax`; latter are `cstruct`, `lwt_cstruct` and `unix_cstruct`.

Try host build first: `opam install cstruct`  (requires host `opam install lwt`; `opam install ocplib-endian`)

Now target...

	oasis setup
	ocaml setup.ml -configure --enable-lwt --enable-unix --override ocamlfind `opam config var prefix`/bin/arm-linux-androideabi/ocamlfind
	ocaml setup.ml -build
	ocaml setup.ml -install

### lwt

Already installed when setting up compiler (above).

##### Working notes

This seems to also use oasis.

An android-lwt opam module has been created by Vouillon; this has patches and opam commands which include some overrides for the oasis-defined build to use the arm-android compilers, which may be a useful model for the above (note, I have removed the fixed path below):
 
	build: [
	  ["oasis" "setup"]
	  ["ocaml" "setup.ml" "-configure"
	      "--override" "ocamlfind"
	         "%{prefix}%/bin/arm-linux-androideabi-ocamlfind"
	      "--override" "android_target" "true"
	      "--enable-ssl"]
	  ["ocaml" "setup.ml" "-build"]
	  ["ocaml" "setup.ml" "-install"]
	]

### ocamlfind

A patched version plus android toolchain configuration is part of Vouillon's repository, installed above.

#### Working notes

build-time only. There is a version (1.3.3.1, with a patch) in the ocaml-android repository, so that's what I'm using by default.
It was built for android-lwt by default in this build sequence.

### base-threads

Part of core system built by ocaml-android (?!)

### base-unix

Part of core system built by ocaml-android (?!)

### ounit

In [my opam repo](https://github.com/cgreenhalgh/opam-android-repository) as `opam install android-shared-memory-ring`, including small patch for building test executable.

#### Working notes

[archive](http://forge.ocamlcore.org/frs/download.php/886/ounit-1.1.2.tar.gz)

Build: make build; make install

Has `_oasis`. Makefile accepts BUILDFLAGS and INSTALLFLAGS. No native code.

Default build includes a test executable, defaulting to bytecode; this will fail with current ocaml-android compiler (as per [readme](https://github.com/vouillon/ocaml-android) problems). So one option is to edit `_oasis` and add the CompiledObject bit to the test build info:

	Executable test
	  Path:   test
	  MainIs: test.ml
	  BuildDepends: oUnit
	  Install: false
	  CompiledObject: native
  
Oasis build for target...

	oasis setup
	ocaml setup.ml -configure --override ocamlfind `opam config var prefix`/bin/arm-linux-androideabi/ocamlfind
	ocaml setup.ml -build
	ocaml setup.ml -install

Otherwise test fails...

	+ /home/pszcmg/.opam/4.00.1.android/bin/arm-linux-androideabi/ocamlfind ocamlc -g -linkpkg -package unix src/oUnit.cma test/test.cmo -o test/test.byte
	File "_none_", line 1:
	Error: Error on dynamically loaded library: /home/pszcmg/.opam/4.00.1.android/arm-linux-androideabi/lib/ocaml/stublibs/dllunix.so: /home/pszcmg/.opam/4.00.1.android/arm-linux-androideabi/lib/ocaml/stublibs/dllunix.so: cannot open shared object file: No such file or directory
	Command exited with code 2.

### shared-memory-ring

In [my opam repo](https://github.com/cgreenhalgh/opam-android-repository) as "opam install android-shared-memory-ring", including patch for (lack of) dmb.

#### Working notes

[archive](https://github.com/mirage/shared-memory-ring/archive/shared-memory-ring-0.4.1.tar.gz)
[git](https://github.com/mirage/shared-memory-ring.git)

Build: make all; make install.

Has '_oasis'. Has native code, including architecture-dependent `__asm__` - checks for defined `__i386__` `__x86_64__` `__arm__` ...

Initially:

	+ /home/pszcmg/.opam/4.00.1.android/bin/arm-linux-androideabi/ocamlfind ocamlc -c lib/barrier_stubs.c
	/tmp/ccwwXn9Q.s: Assembler messages:
	/tmp/ccwwXn9Q.s:23: Error: selected processor does not support ARM mode `dmb'

What processor?? Time to look in ocaml-android, I suppose... 
[Apparently](http://www.raspberrypi.org/phpBB3/viewtopic.php?t=23616&p=322295) dmb is Armv7, build is using NDK platform 14.
Allegedly, this is a portable alternative (Linux  `__kuser_memory_barrier`)...

	mov r2, #0xffff0fa0
	blx r2

According to [this](https://wiki.edubuntu.org/ARM/Thumb2PortingHowto) `__sync_synchronize` is available from GCC 4.4.3 and Linux 2.6.19.
[Some notes](https://android.googlesource.com/platform/ndk/+/ics-mr0/docs/STANDALONE-TOOLCHAIN.html) on cflags for specifying v7 support (which I don't actually want at the moment).
Compiler defines for ARM, seem to include  `defined(__ARM_ARCH_7__) || defined(__ARM_ARCH_7A__) || defined(__ARM_ARCH_7M__) || defined(__ARM_ARCH_7R__) || defined(__ARM_ARCH_7S__)`
Maybe do this in lib/barrier.h:

	#elif defined(__arm__)
	#if defined(__ARM_ARCH_7__) \
		|| defined(__ARM_ARCH_7A__) \
		|| defined(__ARM_ARCH_7M__) \
		|| defined(__ARM_ARCH_7R__) \
		|| defined(__ARM_ARCH_7S__)
	#define xen_mb()   asm volatile ("dmb" : : : "memory")
	#define xen_rmb()  asm volatile ("dmb" : : : "memory")
	#define xen_wmb()  asm volatile ("dmb" : : : "memory")
	#else
	/* gcc since 4.4.3?! */
	#define xen_mb()   __sync_synchronize()
	#define xen_rmb()   __sync_synchronize()
	#define xen_wmb()   __sync_synchronize()
	#endif
 
See [this fork](https://github.com/cgreenhalgh/shared-memory-ring.git) or [this patch](https://github.com/cgreenhalgh/shared-memory-ring/commit/72352b35ef7b309886e965e4e85acd3048eaf819.patch)

Oasis build for target...

	oasis setup
	ocaml setup.ml -configure --override ocamlfind `opam config var prefix`/bin/arm-linux-androideabi/ocamlfind
	ocaml setup.ml -build
	ocaml setup.ml -install

### ipaddr

In [my opam repo](https://github.com/cgreenhalgh/opam-android-repository) as `opam install android-ipaddr`.

#### Working notes

(ipaddr)[https://github.com/mirage/ocaml-ipaddr] 

[archive](https://github.com/mirage/ocaml-ipaddr/archive/0.2.2.tar.gz)

Build: `"ocaml" "setup.ml" "-configure" "--prefix" "%{prefix}%"; make "build"; make "install"`

Has `_oasis`. No native code. Tests don't use configuration or library (just build/run on host).

Oasis build for target...

	oasis setup
	ocaml setup.ml -configure --override ocamlfind `opam config var prefix`/bin/arm-linux-androideabi/ocamlfind
	ocaml setup.ml -build
	ocaml setup.ml -install

### tuntap

In [my opam repo](https://github.com/cgreenhalgh/opam-android-repository) as "opam install android-tuntap" based on my [git fork](https://github.com/cgreenhalgh/ocaml-tuntap) with implementation of getifaddrs from  [getifaddrs for android](https://github.com/kmackay/android-ifaddrs).

#### Working notes

[archive](https://github.com/mirage/ocaml-tuntap/archive/0.6.tar.gz)
[git](https://github.com/mirage/ocaml-tuntap/)

Build: make "PREFIX=%{prefix}%"; make "PREFIX=%{prefix}%" "install"

Has `_oasis`.

	lib/tuntap_stubs.c:30:21: fatal error: ifaddrs.h: No such file or directory

This defines getifaddrs and freeifaddrs
Seems to be known - this might fix it [getifaddrs for android](https://github.com/kmackay/android-ifaddrs)
Not sure how to set up conditional compilation at the moment though, or to get compiler to add lib/ to C-compiler include path...

[git fork](https://github.com/cgreenhalgh/ocaml-tuntap), in particular [0.6.android](https://github.com/cgreenhalgh/ocaml-tuntap/archive/0.6.android.tar.gz).
Note, no TUNSETGROUP, as well as replacement for getifaddrs and tweak for broadcast.

Oasis build for target...

	# needs setup
	oasis setup
	ocaml setup.ml -configure --override ocamlfind `opam config var prefix`/bin/arm-linux-androideabi/ocamlfind
	ocaml setup.ml -build
	ocaml setup.ml -install


### mirage-unix

[archive](https://github.com/mirage/mirage-platform/archive/v0.9.6.tar.gz).

Opam build:

	make "unix-build"
	make "unix-install" "PREFIX=%{prefix}%"

Makefile calls relevant sub-dir make, i.e. unix/ ...

Has configure.os script which does (host)OS-specific C-flag setting and selects `tap_stubs_linux.c` or `tab_stubs_macosx.c`.
Makefile uses cmd. Configure -> "configure unix".  

Has `_vars` and uses cmd to create `_config/` used by ocamlbuild. Has myocamlbuild.ml. Has _tags.

Requires (ocamlfind) cstruct cstruct.syntax lwt lwt.syntax lwt.unix tuntap ipaddr.

Has native files; one checksum speedup; other `tap_stubs_linux` which just emits an error if `pcap_opendev` called! Apparently this functionality was replaced by ocaml tuntap. 

perhaps we can compile myocamlbuild.ml first ourselves...

Also try ocamlbuild -byte-plugin; ocamlbuild -ocamlfind `opam config var prefix`/bin/arm-linux-androideabi/ocamlfind

	make clean
	ocamlbuild -just-plugin

try..

	cat `opam config var prefix`/lib/findlib.conf.d/android.conf  | sed -e 's/(android)//g' > ~/android.conf
	export  OCAMLFIND_CONF=~/android.conf 

	make build
	make install

If you get the following then you are missing the LD fix in ocaml-android (above):

	+ touch lib/oS.mli  ; if  /home/pszcmg/.opam/4.00.1.android/bin/ocamlfind ocamlopt -pack -I lib lib/env.cmx lib/io_page.cmx lib/clock.cmx lib/time.cmx lib/console.cmx lib/main.cmx lib/devices.cmx lib/netif.cmx -o lib/oS.cmx  ; then  rm -f lib/oS.mli  ; else  rm -f lib/oS.mli  ; exit 1; fi
	ld: /tmp/camlOS__d5a98e.o: Relocations in generic ELF (EM: 40)
	/tmp/camlOS__d5a98e.o: could not read symbols: File in wrong format
	File "lib/oS.cmx", line 1:
	Error: Error during partial linking

This is bad (causes final app not to find lib unixrun:

	cc -I/home/pszcmg/mirage/mirage-platform-0.9.6/unix/lib -c -Wall -O3 -fPIC -I/home/pszcmg/.opam/4.00.1.android/lib/ocaml -o lib/checksum_stubs.o lib/checksum_stubs.c
	cc -I/home/pszcmg/mirage/mirage-platform-0.9.6/unix/lib -c -Wall -O3 -fPIC -I/home/pszcmg/.opam/4.00.1.android/lib/ocaml -o lib/tap_stubs_os.o lib/tap_stubs_os.c
	/home/pszcmg/.opam/4.00.1.android/bin/ocamlmklib -o lib/unixrun lib/checksum_stubs.o lib/tap_stubs_os.o

THis is caused by myocamlbuild.ml rules for directly invoking cc and ar; WHY??
Just take them out... (also needs fixes for ocamlbuild/ocamlmklib - see compiler stuff above)

If you get the following similar error then you are missing the ocamlmklib fix in ocamlbuild (above):

	+ /home/pszcmg/.opam/4.00.1.android/bin/ocamlmklib -o lib/unixrun lib/checksum_stubs.o lib/tap_stubs_os.o
	/usr/bin/ld: lib/checksum_stubs.o: Relocations in generic ELF (EM: 40)
	lib/checksum_stubs.o: could not read symbols: File in wrong format


### mirage

No-op

### mirage-net-socket

0.9.4. [archive](https://github.com/mirage/mirage-net/archive/v0.9.4.tar.gz)

Has custom myocamlbuild.ml, which includes at least some Xen-specific stuff. 

Has fairly standard Makefile choosing directory to build: Expects env MIRAGE_NET to be set to "socket" or "direct" for default build.

Has cmd script but unclear if used/needed.

Socket sub-directory has Makefile which uses cmd (duplicate of top-level) to configure/build/install. Optionally set PREFIX. Has META.in (conjecture: used by cmd), `_tags` and `_vars`. Has duplicate myocamlbuild.ml. Socket has no native code (relies on standard Unix module). 

Direct sub-directory ditto.


Has native code, tuntap_stubs.c. Has branches for __linux__ and __APPLE__/__MACH__. 

Hopefully just getting the cross-compiler used will set this correctly?!

	cd socket
	unset OCAMLFIND_CONF
	make clean
	ocamlbuild -just-plugin

try..

	export  OCAMLFIND_CONF=~/android.conf 

	make build
	make install

### Mirage-skeleton basic


backend.ml includes:

	 let sockaddr = Unix.ADDR_UNIX (Printf.sprintf "/tmp/mir-%d.sock" (Unix.getpid ())) in
	 let sock = Lwt_unix.(socket PF_UNIX SOCK_STREAM 0) in
 
But tmp on Android is typically /data/local/tmp. Its a bit fiddly to add a link from /tmp as the root filesystem is readonly by default. CHange it in backend.ml...

	let sockaddr = Unix.ADDR_UNIX (Printf.sprintf "/data/local/tmp/mir-%d.sock" (Unix.getpid ())) in
	...

Now build it:

	unset OCAMLFIND_CONF
	make clean
	ocamlbuild -just-plugin

	export  OCAMLFIND_CONF=~/android.conf 

make build insists on rebuiding myocamlbuild.ml, so just using the ocamlbuild from the Makefile directly:

	ocamlbuild -classic-display -use-ocamlfind -lflag -linkpkg  -pkgs lwt.syntax,fd-send-recv,mirage -tags "syntax(camlp4o)" main.native


Without fixing ocamlbuild/ld you might get:

	/home/pszcmg/.opam/4.00.1.android/lib/android-ndk-linux/toolchains/arm-linux-androideabi-4.7/prebuilt/linux-x86/bin/../lib/gcc/arm-linux-androideabi/4.7/../../../../arm-linux-androideabi/bin/ld: error: cannot find -lunixrun
	...

Without fixing the sockaddr path you might get (when run on Android):

	Fatal error: exception Unix.Unix_error(20, "bind", "")
Error 20 = no such directory, see `opam config var prefix`/lib/android-ndk-linux/platforms/android-14/arch-arm/usr/include/sys/_errdefs.h

If you get no output on Android then could be a buffered output problem. After using [Mort's fix](https://github.com/mor1/mirage/commit/fec9133cdabce8553659d4d474ce3874a4ab6799) for mirage-unix I get...

	adb push _build/main.native /data/local/tmp
	adb shell
	shell@android:/ $ cd /data/local/tmp
	shell@android:/data/local/tmp $ ./main.native                                  
	hello
	world
	hello
	...

### re

In [my opam repo](https://github.com/cgreenhalgh/opam-android-repository) as `opam install android-re`

#### Working notes

[archive](https://github.com/ocaml/ocaml-re/archive/ocaml-re-1.2.1.tar.gz). 

Configured using `_oasis`. Standard repo version includes an extra re.config file with explicit include paths.

It defines syntax extensions. Note sure if that will upset the build process. 

I seem to have to rename (opam) files/re.config.in to files/android-re.config.in. Also tweaked paths (perhaps incorrectly) for toolchain lib. 

### uri

In [my opam repo](https://github.com/cgreenhalgh/opam-android-repository) as `opam install android-uri`

#### Working notes

[archive](https://github.com/mirage/ocaml-uri/archive/ocaml-uri-1.3.8.tar.gz).

Uses oasis.

Not checked in more detail.

### cohttp

In [my opam repo](https://github.com/cgreenhalgh/opam-android-repository) as `opam install android-cohttp`

Note: require mirage & mirage-net to be installed first (not integrated with repo yet).

#### Working notes

Including cohttp.mirage

Uses oasis. Default build does not build cohttp.mirage. Added to config flags in opam. 
Mirage-net required, but left optional in opam as I haven't sorted out opam for it yet.
So will blow up if mirage-net not build/installed before attempting opam install

[archive](https://github.com/mirage/ocaml-cohttp/archive/ocaml-cohttp-0.9.10.tar.gz)

### Mirage skeleton static website

This depends on packages cohttp.mirage, uri and re in addition to those required for the basic app.

On we go...

Fix for backend.ml /tmp -> /data/local/tmp as per basic example.

	cd src
	ocamlbuild -just-plugin

Steal the ocamlbuild line from the Makefile:

	ocamlbuild -classic-display -use-ocamlfind -lflag -linkpkg  -pkgs lwt.syntax,fd-send-recv,cohttp.mirage,uri,re -tags "syntax(camlp4o)" main.native

Install on android and run; Doesn't print much:

	shell@android:/data/local/tmp $ ./static_website                               
	Devices: [static] provider start
	Devices: [static:static] provider plug
	Devices: [static:static] no waiters

If you close browser:

	EXN: Channel.Make(Flow).Closed

BUt does serve a page on http://localhost:8080/ :-)

