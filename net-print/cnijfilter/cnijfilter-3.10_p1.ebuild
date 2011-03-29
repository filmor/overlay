# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools

MY_P="cnijfilter-source-${PV%%_p*}"

DESCRIPTION="PPD and filters for Canon InkJet Printers"
HOMEPAGE="http://de.software.canon-europe.com/software/0033571.asp?model="
SRC_URI="http://files.canon-europe.com/files/soft33571/software/${MY_P}-${PV##*_p}.tar.gz"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="network"

DEPEND="dev-libs/popt
	net-print/cups"
RDEPEND="${DEPEND}
	network? ( net-print/cups-bjnp )"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	sed -i \
		-e '/^AM_CFLAGS/d' \
		libs/paramlist/Makefile.am || die "sed failed"
	sed -i \
		-e 's|-O2 -Wall||' \
		pstocanonij/filter/Makefile.am || die "sed failed"

	for d in libs pstocanonij ; do
		cd "${S}/${d}"
		eautoreconf
	done
}

src_configure() {
	cd "${S}/libs"
	econf

	cd "${S}/pstocanonij"
	econf \
		--enable-progpath="$(cups-config --serverbin)/filter"
}

src_compile() {
	emake -C libs || die "emake -C libs failed"
	emake -C pstocanonij || die "emake -C pstocanonij failed"
}

src_install() {
	emake -C pstocanonij DESTDIR="${D}" install || die "emake install failed"

	dodir "$(cups-config --serverbin)"
	mv "${D}"/usr/lib*/cups/filter "${D}/$(cups-config --serverbin)"
	rm -rf "${D}"/usr/lib{,32,64}

	insinto "$(cups-config --datadir)/model"
	doins ppd/*.ppd
}

pkg_postinst() {
	elog "Currently only 3 PPDs and the pstocanonij tool get installed"
	elog "Other things are either broken or need precompiled and 32-bit only libs."
	elog "Patches extending this ebuild are welcome."
}
