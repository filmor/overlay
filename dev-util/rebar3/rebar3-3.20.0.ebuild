# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

inherit bash-completion-r1

DESCRIPTION="Erlang build tool that makes it easy to compile and test Erlang \
applications and releases"
HOMEPAGE="https://www.rebar3.org"

SRC_URI="https://github.com/erlang/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="bash-completion zsh-completion fish-completion"

RDEPEND="
	${DEPEND}
	fish-completion? ( app-shells/fish )
	zsh-completion? ( app-shells/zsh )
"

DEPEND="
	dev-lang/erlang
"

src_compile() {
	./bootstrap || die "Failed to bootstrap"
}

src_test() {
	./rebar3 eunit || die "Failed running unit tests"
	./rebar3 ct || die "Failed running tests"
}

src_install() {
	dobin rebar3
	dodoc rebar.config.sample README.md

	if use bash-completion; then
		dobashcomp apps/rebar/priv/shell-completion/bash/${PN}
	fi

	if use fish-completion; then
		insinto /usr/share/fish/completions
		doins apps/rebar/priv/shell-completion/fish/${PN}.fish
	fi

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		doins apps/rebar/priv/shell-completion/zsh/_${PN}
	fi
}
