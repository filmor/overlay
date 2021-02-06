# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{6,7,8,9} )

inherit meson python-r1

DESCRIPTION="SDK for making video editors and more"
HOMEPAGE="http://wiki.pitivi.org/wiki/GES"
SRC_URI="https://gstreamer.freedesktop.org/src/${PN}/${P}.tar.xz"

LICENSE="LGPL-2+"
SLOT="1.0"
KEYWORDS="amd64 x86"

IUSE="gtk-doc +introspection"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	>=dev-libs/glib-2.40.0:2
	dev-libs/libxml2:2
	>=media-libs/gstreamer-${PV}:1.0[introspection?]
	>=media-libs/gst-plugins-base-${PV}:1.0[introspection?]
	introspection? ( >=dev-libs/gobject-introspection-0.9.6:= )
"
DEPEND="${RDEPEND}
	gtk-doc? ( dev-util/gtk-doc )
"
# XXX: tests do pass but need g-e-s to be installed due to missing
# AM_TEST_ENVIRONMENT setup.
RESTRICT="test"

src_configure() {
	local emesonargs=(
		$(use introspection || echo "-Ddisable_introspection=true")
		$(use gtk-doc || echo "-Ddisable_gtkdoc=true")
		-Dpygi-overrides-dir="/pygobject"
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	# copy pygobject files to each active python target
	# work-around for "py-overrides-dir" only supporting a single target
	install_pygobject_override() {
		PYTHON_GI_OVERRIDESDIR=$("${PYTHON}" -c 'import gi;print(gi._overridesdir)') || die
		einfo "gobject overrides directory: $PYTHON_GI_OVERRIDESDIR"
		mkdir -p "${ED}/$PYTHON_GI_OVERRIDESDIR/"
		cp -r "${D}"/pygobject/* "${ED}/$PYTHON_GI_OVERRIDESDIR/" || die
		python_optimize "${ED}/$PYTHON_GI_OVERRIDESDIR/"
	}
	python_foreach_impl install_pygobject_override
	rm -rf "${D}/pygobject" || die
}
