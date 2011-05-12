# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

PYTHON_DEPEND="python? 2:2.6"

inherit cmake-utils eutils multilib java-pkg-opt-2 distutils

DESCRIPTION="A library for real time MIDI input and output"
HOMEPAGE="http://portmedia.sourceforge.net/"
SRC_URI="mirror://sourceforge/portmedia/${PN}-src-${PV}.zip"
#ESVN_REPO_URI="https://portmedia.svn.sourceforge.net/svnroot/portmedia/portmidi/trunk"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug java python testapps"

CDEPEND="media-libs/alsa-lib"
RDEPEND="${CDEPEND}
	java? ( >=virtual/jre-1.6 )"
DEPEND="${CDEPEND}
	java? ( >=virtual/jdk-1.6 )
	python? ( >=dev-python/cython-0.12.1 )
	app-arch/unzip"
# build of docs not working
#	doc? ( app-doc/doxygen
#		   virtual/latex-base )"

S="${WORKDIR}/${PN}"

# seems to be needed
CMAKE_IN_SOURCE_BUILD=1

# seems to be needed, if the default "Gentoo" is used there will be
# problems. f.e. no midi devices in pmdefaults, maybe even no midi devices at
# all.
CMAKE_BUILD_TYPE=$(use debug && echo Debug || echo Release)

src_prepare() {
	# with this patch the java installation directories can be specified and
	# allows java to be enabled/disabled
	epatch "${FILESDIR}/${P}-cmake-libdir-java-opts.patch"

	# find the header and our compiled libs in the distutils setup.py
	epatch "${FILESDIR}/${P}-python-setup.py.patch"

	if use java ; then
		# this stuff fixes up the pmdefaults wrapper for locations where
		# Gentoo prefers to keep jars, it also specifies a library directory
		cat > pm_java/pmdefaults/pmdefaults <<-EOF
		#!/bin/sh
		java -Djava.library.path=/usr/$(get_libdir)/ \\
			-jar "${EPREFIX}/usr/share/${PN}-${SLOT}/lib/pmdefaults.jar"
		EOF
	fi
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use java PORTMIDI_ENABLE_JAVA)

		# this seems to be needed. if not set there will be a sandbox
		# violation. if set to ./ the java parts will not build.
		# one may end up with a blob named Gentoo, Debug or Release. hmmm
		-DCMAKE_CACHEFILE_DIR="${S}/build"
	)

	# java stuff, the portmidi wiki says JAVA_JVM_LIBRARY needs to be specified
	if use java ; then
		# search for libjvm.so is modified from sci-chemistry/tinker ebuild
		local javalib=
		for i in $(java-config -g LDPATH | sed 's|:| |g') ; do
			[[ -f ${i}/libjvm.so ]] && javalib=${i}/libjvm.so
		done

		mycmakeargs+=(-DJAVA_JVM_LIBRARY="${javalib}"
			# tell cmake where to install the jar, this requires the cmake
			# patch, can be a relative path from CMAKE_INSTALL_PREFIX or
			# absolute.
			-DJAR_INSTALL_DIR="${EPREFIX}/usr/share/${PN}-${SLOT}/lib"
		)
	fi

	cmake-utils_src_configure
}

src_compile() {
	# parallel make is broken when java is enabled so force -j1 :(
	cmake-utils_src_compile -j1

	# python modules
	if use python ; then
		pushd pm_python || die "pushd python failed"
		# hack. will error out if these files are not found
		touch CHANGES.txt TODO.txt
		distutils_src_compile
		popd
	fi

	# make the docs (NOT WORKING)
	#if use doc ; then
	#	doxygen || die "doxygen failed"
	#	pushd latex || die "pushd latex failed"
	#		VARTEXFONTS="${T}/fonts" make ${MAKEOPTS} || die "make doc failed"
	#	popd
	#fi
}

src_install() {
	cmake-utils_src_install

	dodoc CHANGELOG.txt README.txt pm_linux/README_LINUX.txt

	# install the python modules
	if use python ; then
		pushd pm_python || die "pushd pm_python failed"
		distutils_src_install
		popd
	fi

	# a desktop entry and icon for the pmdefaults java configuration gui
	if use java ; then
		newdoc pm_java/README.txt README_JAVA.txt
		doicon pm_java/pmdefaults/pmdefaults-icon.png
		make_desktop_entry pmdefaults Pmdefaults pmdefaults-icon \
			"AudioVideo;Audio;Midi;"
	fi

	# some portmidi test apps
	if use testapps ; then
		# maybe a better location can be used
		insinto /usr/$(get_libdir)/${PN}-${SLOT}
		insopts -m0755
		local app
		for app in latency midiclock midithread \
				midithru mm qtest sysex test ; do
			doins "${S}/build/${CMAKE_BUILD_TYPE}/${app}" \
			|| die "doins tests failed"
		done
	fi
}
