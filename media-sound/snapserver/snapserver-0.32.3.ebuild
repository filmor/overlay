# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit edo cmake systemd

DESCRIPTION="Synchronous multi-room audio server"
HOMEPAGE="https://github.com/badaix/snapcast"
SRC_URI="https://github.com/badaix/snapcast/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/snapcast-${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="amd64 arm ppc ppc64 ~riscv x86"
IUSE="+alsa +client +expat +flac jack +opus soxr test tremor +vorbis +zeroconf"
RESTRICT="!test? ( test )"

RDEPEND="
	acct-group/snapserver
	acct-user/snapserver
	dev-libs/boost:=
	dev-libs/openssl:=
	expat? ( dev-libs/expat )
	alsa? ( media-libs/alsa-lib )
	flac? ( media-libs/flac:= )
	jack? ( virtual/jack )
	opus? ( media-libs/opus )
	tremor? ( media-libs/tremor )
	soxr? ( media-libs/soxr )
	vorbis? ( media-libs/libvorbis )
	zeroconf? ( net-dns/avahi[dbus] )
"
DEPEND="
	${RDEPEND}
	>=dev-cpp/asio-1.12.1
	test? ( >=dev-cpp/catch-3:0 )
"

PATCHES=(
)

src_configure() {
	local mycmakeargs=(
		-DBUILD_SERVER=ON
		-DBUILD_CLIENT=OFF
		-DBUILD_WITH_ALSA=$(usex alsa)
		-DBUILD_WITH_EXPAT=$(usex expat)
		-DBUILD_WITH_SOXR=$(usex soxr)
		-DBUILD_WITH_FLAC=$(usex flac)
		-DBUILD_WITH_JACK=$(usex jack)
		-DBUILD_WITH_OPUS=$(usex opus)
		-DBUILD_WITH_TREMOR=$(usex tremor)
		-DBUILD_WITH_VORBIS=$(usex vorbis)
		-DBUILD_WITH_AVAHI=$(usex zeroconf)
		-DBUILD_STATIC_LIBS=no
		-DBUILD_TESTS=$(usex test)
		-DCMAKE_INSTALL_SYSCONFDIR="${EPREFIX}/etc"
	)

	cmake_src_configure
}

src_test() {
	cmake_src_test
	edo "${S}"/bin/snapcast_test
}

src_install() {
	cmake_src_install

	doman "server/${PN}.1"

	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"
}
