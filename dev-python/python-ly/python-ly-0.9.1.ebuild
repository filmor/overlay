# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/six/six-1.9.0.ebuild,v 1.3 2015/04/04 19:56:22 vapier Exp $

EAPI=5
PYTHON_COMPAT=( python{2_7,3_3,3_4} pypy pypy3 )

inherit distutils-r1

DESCRIPTION="Tool and library for manipulating LilyPond files"
HOMEPAGE="https://github.com/wbsoft/python-ly http://pypi.python.org/pypi/python-ly"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris"
IUSE="doc"

DEPEND="doc? ( dev-python/sphinx )"

python_compile_all() {
	use doc && emake -C doc html
}

python_install_all() {
	use doc && local HTML_DOCS=( doc/_build/html/ )
	distutils-r1_python_install_all
}
