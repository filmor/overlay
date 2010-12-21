EAPI="2"

inherit autotools eutils python flag-o-matic

NAME="Dharma_beta4"

SRC_URI="http://xbmc.svn.sourceforge.net/viewvc/xbmc/tags/${NAME}/?view=tar -> ${PN}-${NAME}.tar.gz"
KEYWORDS="~amd64 ~x86"
S=${WORKDIR}/${NAME}

DESCRIPTION="XBMC is a free and open source media-player and entertainment hub"
HOMEPAGE="http://xbmc.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="aac alsa altivec avahi bluray css debug hal httpd joystick midi profile pulseaudio sse sse2 vdpau xrandr"

RDEPEND="virtual/opengl
	app-arch/bzip2
	app-arch/unrar
	app-arch/unzip
	app-arch/zip
	app-i18n/enca
	dev-libs/boost
	dev-libs/fribidi
	dev-libs/libcdio[-minimal]
	dev-libs/libpcre
	dev-libs/lzo
	>=dev-python/pysqlite-2
	media-libs/a52dec
	media-libs/alsa-lib
	aac? ( media-libs/faac )
	media-libs/faad2
	media-libs/flac
	media-libs/fontconfig
	media-libs/freetype
	media-libs/glew
	media-libs/jasper
	media-libs/jbigkit
	media-libs/jpeg:0
	>=media-libs/libass-0.9.7
	bluray? ( media-libs/libbluray )
	media-libs/libdca
	css? ( media-libs/libdvdcss )
	media-libs/libmad
	media-libs/libmms
	media-libs/libmodplug
	media-libs/libmpeg2
	media-libs/libogg
	media-libs/libsamplerate
	media-libs/libsdl[audio,opengl,video,X]
	alsa? ( media-libs/libsdl[alsa] )
	media-libs/libvorbis
	media-libs/sdl-gfx
	media-libs/sdl-image[gif,jpeg,png]
	media-libs/sdl-mixer
	media-libs/sdl-sound
	media-libs/tiff
	pulseaudio? ( media-sound/pulseaudio )
	media-sound/wavpack
	media-video/ffmpeg
	media-video/rtmpdump
	avahi? ( net-dns/avahi )
	httpd? ( net-libs/libmicrohttpd )
	net-misc/curl
	|| ( >=net-fs/samba-3.4.6[smbclient] <net-fs/samba-3.3 )
	sys-apps/dbus
	hal? ( sys-apps/hal )
	sys-libs/zlib
	virtual/mysql
	x11-apps/xdpyinfo
	x11-apps/mesa-progs
	vdpau? (
		|| ( x11-libs/libvdpau >=x11-drivers/nvidia-drivers-180.51 )
		media-video/ffmpeg[vdpau]
	)
	x11-libs/libXinerama
	xrandr? ( x11-libs/libXrandr )
	x11-libs/libXrender"
DEPEND="${RDEPEND}
	x11-proto/xineramaproto
	dev-util/cmake
	x86? ( dev-lang/nasm )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix IPv6 for webserver (trac.xbmc.org/ticket/9052)
	if use httpd; then
		epatch "${FILESDIR}/xbmc-10.0-httpd_disable-ipv6.patch" || die
	fi

	# Fix case sensitivity
	mv media/Fonts/{a,A}rial.ttf || die
	mv media/{S,s}plash.png || die
}

src_prepare() {
	# some dirs ship generated autotools, some dont
	local d
	for d in . xbmc/cores/dvdplayer/Codecs/libbdnav \
			xbmc/cores/dvdplayer/Codecs/libdvd/libdvdcss \
			lib/cpluff; do
		[[ -d ${d} ]] || continue
		[[ -e ${d}/configure ]] && continue
		pushd ${d} >/dev/null
		einfo "Generating autotools in ${d}"
		eautoreconf
		popd >/dev/null
	done

	local squish #290564
	use altivec && squish="-DSQUISH_USE_ALTIVEC=1 -maltivec"
	use sse && squish="-DSQUISH_USE_SSE=1 -msse"
	use sse2 && squish="-DSQUISH_USE_SSE=2 -msse2"
	sed -i \
		-e '/^CXXFLAGS/{s:-D[^=]*=.::;s:-m[[:alnum:]]*::}' \
		-e "1iCXXFLAGS += ${squish}" \
		xbmc/lib/libsquish/Makefile.in || die

	# Fix XBMC's final version string showing as "exported"
	# instead of the SVN revision number.
	export SVN_REV=33778

	# Avoid lsb-release dependency
	sed -i \
		-e 's:/usr/bin/lsb_release -d:cat /etc/gentoo-release:' \
		xbmc/utils/SystemInfo.cpp

	# Do not use termcap #262822
	sed -i 's:-ltermcap::' xbmc/lib/libPython/Python/configure

	epatch_user #293109

	# Tweak autotool timestamps to avoid regeneration
	find . -type f -print0 | xargs -0 touch -r configure
}

src_configure() {
	# Disable documentation generation
	export ac_cv_path_LATEX=no
	# Avoid help2man
	export HELP2MAN=$(type -P help2man || echo true)

	econf \
		--disable-ccache \
		--disable-optimizations \
		--enable-external-libraries \
		--disable-external-python \
		--enable-goom \
		$(use_enable avahi) \
		$(use_enable bluray libbluray) \
		$(use_enable css dvdcss) \
		$(use_enable debug) \
		$(use_enable aac faac) \
		$(use_enable hal) \
		$(use_enable httpd webserver) \
		$(use_enable joystick) \
		$(use_enable midi mid) \
		$(use_enable profile profiling) \
		$(use_enable pulseaudio pulse) \
		$(use_enable vdpau) \
		$(use_enable xrandr)
}

src_install() {
	einstall || die "Install failed!"

	insinto /usr/share/applications
	doins tools/Linux/xbmc.desktop
	doicon tools/Linux/xbmc-48x48.png

	dodoc {README.linux,LICENSE.GPL,*.txt}

	insinto "$(python_get_sitedir)" #309885
	doins tools/EventClients/lib/python/xbmcclient.py || die
	newbin "tools/EventClients/Clients/XBMC Send/xbmc-send.py" xbmc-send || die

	rm ${D}/usr/share/icons/hicolor/icon-theme.cache
}

pkg_postinst() {
	elog "Visit http://xbmc.org/wiki/?title=XBMC_Online_Manual"
}
