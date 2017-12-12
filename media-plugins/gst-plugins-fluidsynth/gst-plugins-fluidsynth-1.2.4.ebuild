# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-mad/gst-plugins-mad-1.2.4.ebuild,v 1.1 2014/05/31 14:50:06 pacho Exp $

EAPI=6
GST_ORG_MODULE=gst-plugins-bad

inherit gstreamer

KEYWORDS="amd64"
IUSE=""

RDEPEND="media-sound/fluidsynth"
DEPEND="${RDEPEND}"
