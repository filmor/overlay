# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg-utils

EXEC_NAME=X-AIR-Edit
DESCRIPTION="Editor for X-Air and M-Air mixers"
HOMEPAGE="https://www.music-group.com"
BASE_URI="https://cdn.mediavalet.com/aunsw/musictribe/VX4UkGFjQ0a1DH2Q8zg3sg/_KJ6tGIG7kGVqPxP-OsnLQ/Original/"
SRC_URI="amd64? ( ${BASE_URI}/X-AIR-Edit_LINUX_X64_V${PV}.tar.gz )
	x86? ( ${BASE_URI}/X-AIR-Edit_LINUX_V${PV}.tar.gz )"
RESTRICT="mirror strip bindist"

LICENSE="EULA"
KEYWORDS="x86 amd64"
IUSE=""
SLOT="0"
S="${WORKDIR}"

DEPEND=""

RDEPEND="${DEPEND}
app-arch/bzip2
dev-libs/expat
dev-libs/libbsd
media-libs/alsa-lib
media-libs/freetype
media-libs/libpng:0
media-libs/mesa
sys-libs/zlib
x11-libs/libX11
x11-libs/libXau
x11-libs/libXdamage
x11-libs/libXdmcp
x11-libs/libXext
x11-libs/libXfixes
x11-libs/libXxf86vm
x11-libs/libxcb
x11-libs/libxshmfence
"

QA_PRESTRIPPED="${EXEC_NAME}"
QA_PREBUILT="${EXEC_NAME}"

src_install() {
	dobin ${EXEC_NAME}
	newicon -s 512 "${FILESDIR}/icon.png" "${PN}.png"
	make_desktop_entry "${EXEC_NAME}" "X AIR Edit" "${PN}"
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}
