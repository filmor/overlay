# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
VALA_USE_DEPEND="vapigen"
VALA_MIN_API_VERSION="0.40"

inherit gnome.org gnome2-utils linux-info meson readme.gentoo-r1 vala xdg

DESCRIPTION="Simple GNOME application to access remote systems"
HOMEPAGE="https://wiki.gnome.org/Apps/Connections"

LICENSE="LGPL-2+ CC-BY-2.0"
SLOT="0"

IUSE=""
KEYWORDS="amd64"

# FIXME: qemu probably needs to depend on spice[smartcard] directly with USE=spice
# FIXME: Check over libvirt USE=libvirtd,qemu and the smartcard/usbredir requirements
# Technically vala itself still ships a libsoup vapi, but that may change, and it should be better to use the .vapi from the same libsoup version
# gtk-vnc raised due to missing vala bindings in earlier ebuilds
DEPEND="
	>=app-arch/libarchive-3.0.0:=
	>=dev-libs/glib-2.52:2
	>=x11-libs/gtk+-3.24.1:3
	>=net-libs/gtk-vnc-0.8.0-r1[gtk3(+)]
	>=dev-libs/libxml2-2.7.8:2
	>=gui-libs/libhandy-1.0.0:1=

	>=dev-libs/gobject-introspection-1.56:=
	>=net-misc/freerdp-2.0.0:=
" # gobject-introspection needed for libovf subproject (and gtk-frdp subproject with USE=rdp)

# gtk-frdp generates gir and needs gtk+ introspection for it
# This is only needed for creating the .vapi file, but connections needs it
BDEPEND="
	$(vala_depend)
	net-libs/gtk-vnc[vala]
	x11-libs/vte:2.91[vala]
	dev-libs/appstream-glib
	x11-libs/gtk+:3[introspection]
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

DISABLE_AUTOFORMATTING="yes"

src_prepare() {
	xdg_src_prepare
	vala_src_prepare
}

src_configure() {
	local emesonargs=(
		-Ddistributor_name=Gentoo
		-Ddistributor_version=${PVR}
		-Dinstalled_tests=false
		-Dflatpak=false
		-Dprofile=default
	)
	meson_src_configure
}

src_install() {
	meson_src_install
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
