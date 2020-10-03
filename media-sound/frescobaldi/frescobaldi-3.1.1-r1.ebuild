# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
inherit distutils-r1 xdg-utils

DESCRIPTION="A LilyPond sheet music text editor"
HOMEPAGE="https://www.frescobaldi.org/"
SRC_URI="https://github.com/wbsoft/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="portmidi"

DEPEND="
	dev-python/PyQt5[gui,network,printsupport,widgets,${PYTHON_USEDEP}]
	>=dev-python/python-ly-0.9.4[${PYTHON_USEDEP}]
	dev-python/python-poppler-qt5[${PYTHON_USEDEP}]
	>=media-sound/lilypond-2.14.2
	portmidi? ( >=media-libs/portmidi-217-r3[${PYTHON_USEDEP}] )
"
RDEPEND="${DEPEND}
	x11-themes/tango-icon-theme
"

PATCHES=(
	"${FILESDIR}/no-svg.patch"
)

python_prepare_all() {
	rm -r frescobaldi_app/icons/Tango || die "failed to remove tango icon theme"
	distutils-r1_python_prepare_all
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}
