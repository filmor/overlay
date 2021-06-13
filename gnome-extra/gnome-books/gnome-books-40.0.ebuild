# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome.org gnome2-utils meson xdg

DESCRIPTION="An e-book manager application for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Books"

LICENSE="GPL-2+"
SLOT="0"
IUSE=""
KEYWORDS="amd64 x86"

COMMON_DEPEND="
	>=app-text/evince-3.13.3[introspection]
	app-misc/tracker:0/2.0
	>=dev-libs/gjs-1.48.0
	>=dev-libs/glib-2.39.3:2
	gnome-base/gnome-desktop:3=[introspection]
	>=dev-libs/gobject-introspection-1.31.6:=
	>=x11-libs/gtk+-3.22.15:3[introspection]
	>=net-libs/webkit-gtk-2.6:4[introspection]

	>=app-text/libgepub-0.6
	x11-libs/gdk-pixbuf:2[introspection]
"
RDEPEND="${COMMON_DEPEND}
	>=app-misc/tracker-miners-2
	sys-apps/dbus
	x11-themes/adwaita-icon-theme
"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xsl-stylesheets
	dev-libs/appstream-glib
	dev-libs/libxslt
	dev-util/glib-utils
	>=sys-devel/gettext-0.19.8
	dev-util/itstool
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		-Ddocumentation=true #manpage
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
