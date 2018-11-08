# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils cmake-utils git-r3

DESCRIPTION="An advanced open-source launcher for Minecraft written in Qt5."
HOMEPAGE="https://multimc.org/"
EGIT_REPO_URI="https://github.com/MultiMC/MultiMC5.git"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE=""

COMMON_DEPEND="
		dev-qt/qtcore:5
		dev-qt/qtconcurrent:5
		dev-qt/qtnetwork:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
		dev-qt/qtx11extras:5
		dev-qt/qtsvg:5
		dev-qt/qtxml:5"
DEPEND="${COMMON_DEPEND}
		virtual/jdk"
RDEPEND="${COMMON_DEPEND}
		sys-libs/zlib
		virtual/jre
		virtual/opengl"

PATCHES=(
		"${FILESDIR}/cmake-patch.diff"
)

CMAKE_IN_SOURCE_BUILD=1

src_prepare() {
	git submodule update --init
	default
}

src_configure() {
	local mycmakeargs=(
			-DCMAKE_INSTALL_PREFIX="/usr/lib/multimc5"
			-DNBT_BUILD_SHARED=OFF
			-DNBT_USE_ZLIB=ON
			-DMultiMC_UPDATER=OFF
	)
	cmake-utils_src_configure
}

src_install() {
	default

	exeinto /usr/lib/multimc5/bin
	doexe "${S}/libMultiMC"*".so"
	doexe "${S}/MultiMC"

	newbin "${FILESDIR}/multimc5.sh" multimc5

	doicon "${S}/application/resources/multimc/scalable/multimc.svg"

	make_desktop_entry \
		multimc5 \
		MultiMC5 \
		multimc5 \
		Application
}
