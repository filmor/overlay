# Copyright 1999-2011 Tiziano Müller
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils

DESCRIPTION="CUPS backend for the canon printers using the proprietary USB over IP BJNP protocol."
HOMEPAGE="http://sourceforge.net/projects/cups-bjnp/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2 LPGL-2"
SLOT="0"
KEYWORDS="x86"
IUSE=""

DEPEND=">=net-print/cups-1.4"
RDEPEND="${DEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog NEWS README TODO
}
