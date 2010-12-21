# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/boost/boost-1.35.0-r2.ebuild,v 1.1 2008/09/01 18:37:20 dev-zero Exp $

inherit toolchain-funcs flag-o-matic


MY_P="${PN}-${PV/_/-}"

S=${WORKDIR}/${MY_P}

DESCRIPTION="C++ library that aids in creating bindings for Lua"
HOMEPAGE="http://www.rasterbar.com/products/luabind.html"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="x86 ppc ~sparc ~x86-macos"
IUSE="debug doc"

# RDEPEND=""

DEPEND=">=dev-lang/lua-5.0
	>=dev-libs/boost-1.34.0
	>=dev-util/boost-build-1.34.0"

generate_options() {
	# Maintainer information:
	# The debug-symbols=none and optimization=none
	# are not official upstream flags but a Gentoo
	# specific patch to make sure that all our
	# CXXFLAGS/LDFLAGS are being respected.
	# Using optimization=off would for example add
	# "-O0" and override "-O2" set by the user.
	# Please take a look at the boost-build ebuild
	# for more infomration.

	OPTIONS="gentoorelease"
	use debug && OPTIONS="gentoodebug"
	

	local mybuild=$(type -p bjam)
	OPTIONS="${OPTIONS} --user-config=${S}/user-config.jam --boost-build=${mybuild%/bin/bjam}/share/boost-build"
}

generate_userconfig() {
	einfo "Writing new user-config.jam"

	local compiler compilerVersion compilerExecutable
	if [[ ${CHOST} == *-darwin* ]] ; then
		compiler=darwin
		compilerVersion=$(gcc-version)
		compilerExecutable=$(tc-getCXX)
		# we need to add the prefix, and in two cases this exceeds, so prepare
		# for the largest possible space allocation
		append-ldflags -Wl,-headerpad_max_install_names
	elif [[ ${CHOST} == *-winnt* ]]; then
		compiler=parity
		compilerVersion=$($(tc-getCXX) -v | sed '1q' \
			| sed -e 's,\([a-z]*\) \([0-9]\.[0-9]\.[0-9][^ \t]*\) .*,\2,')
		compilerExecutable=$(tc-getCXX)
	else
		compiler=gcc
		compilerVersion=$(gcc-version)
		compilerExecutable=$(tc-getCXX)
	fi

	touch "${S}/user-config.jam"

	cat > "${S}/user-config.jam" << __EOF__

variant gentoorelease : release : <optimization>none <debug-symbols>none ;
variant gentoodebug : debug : <optimization>none <debug-symbols>none ;

using ${compiler} : ${compilerVersion} : ${compilerExecutable} : <cxxflags>"${CXXFLAGS}" <linkflags>"${LDFLAGS}" ;

__EOF__

}

src_compile() {

	NUMJOBS=$(sed -e 's/.*\(\-j[ 0-9]\+\) .*/\1/' <<< ${MAKEOPTS})

	generate_userconfig
	generate_options

	elog "Using the following options to build: "
	elog "  ${OPTIONS}"

	export BOOST_ROOT="${ROOT}/usr/include/boost"
	export LUA_PATH="${ROOT}/usr"

	bjam ${NUMJOBS} -q \
		${OPTIONS} \
		link=shared,static \
		--prefix="${D}/usr" \
		--layout=system \
		|| die "building luabind failed"

}

src_install () {
	
	dolib $(find bin -name libluabind.* -print)

	insinto /usr/include/luabind
	doins luabind/*.hpp
	insinto /usr/include/luabind/detail
	doins luabind/detail/*.hpp

	if use doc && false ; then
		find libs -iname "test" -or -iname "src" | xargs rm -rf
		dohtml \
			-A pdf,txt,cpp \
			*.{htm,html,png,css} \
			-r doc more people wiki
		insinto /usr/share/doc/${PF}/html
		doins -r libs
	fi

	cd "${D}/usr/$(get_libdir)"

	# If built with debug enabled, all libraries get a 'd' postfix,
	# this breaks linking other apps against boost (bug #181972)
	if use debug ; then
		for lib in $(ls -1 libluabind*) ; do
			dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-d\././' -e 's/d\././' <<< ${lib})"
		done
	fi

	for lib in $(ls -1 libluabind.*) ; do
		dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-mt//' <<< ${lib})"
	done

	# boost's build system truely sucks for not having a destdir.  Because for
	# this reason we are forced to build with a prefix that includes the
	# DESTROOT, dynamic libraries on Darwin end messed up, referencing the
	# DESTROOT instread of the actual EPREFIX.  There is no way out of here
	# but to do it the dirty way of manually setting the right install_names.
	if [[ ${CHOST} == *-darwin* ]] ; then
		einfo "Working around completely broken build-system(tm)"
		for d in "${D}"usr/lib/*.dylib ; do
			if [[ -f ${d} ]] ; then
				# fix the "soname"
				ebegin "  correcting install_name of ${d#${D}}"
				install_name_tool -id "/${d#${D}}" "${d}"
				eend $?
				# fix references to other libs
				refs=$(otool -XL "${d}" | \
					sed -e '1d' -e 's/^\t//' | \
					grep "^libluabind" | \
					cut -f1 -d' ')
				for r in ${refs} ; do
					ebegin "    correcting reference to ${r}"
					install_name_tool -change \
						"${r}" \
						"${EPREFIX}/usr/lib/${r}" \
						"${d}"
					eend $?
				done
			fi
		done
	fi
}

