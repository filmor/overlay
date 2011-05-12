EAPI='3'

inherit eutils

DESCRIPTION="Dropbox Daemon (precompiled, without gnome deps)."
HOMEPAGE="http://dropbox.com/"
SRC_URI="x86? ( http://www.getdropbox.com/download?plat=lnx.x86 -> dropbox-lnx.x86-${PV}.tar.gz )
	amd64? ( http://www.getdropbox.com/download?plat=lnx.x86_64 -> dropbox-lnx.x86_64-${PV}.tar.gz )"

LICENSE="EULA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror strip"

QA_EXECSTACK_x86="opt/dropbox/_ctypes.so"
QA_EXECSTACK_amd64="opt/dropbox/_ctypes.so"

RDEPEND="net-misc/wget
	x11-libs/libnotify
	x11-libs/libXinerama"

DEPEND="${RDEPEND}"

src_unpack() {
	unpack "${A}"
	mv "${WORKDIR}/.dropbox-dist" "${S}" || die
}

src_install() {
	local targetdir="/opt/dropbox"

	insinto "${targetdir}" || die
	doins -r * || die

	fperms a+x "${targetdir}/dropboxd" || die
	fperms a+x "${targetdir}/dropbox" || die
	dosym "${targetdir}/dropboxd" "/opt/bin/dropbox" || die
	make_desktop_entry dropbox "Dropbox Daemon" package
	insinto /etc/xdg/autostart
	doins /usr/share/applications/dropbox-dropbox.desktop
}
