# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit waf-utils

DESCRIPTION="Thunar Dropbox plugin"
HOMEPAGE="http://www.softwarebakery.com/maato/thunar-dropbox.html"
SRC_URI="http://www.softwarebakery.com/maato/files/thunar-dropbox/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=dev-python/thunarx-python-0.2
		net-misc/dropbox"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/${PN}-provider.patch" \
		   "${FILESDIR}/${PN}-wscript.patch"
}

