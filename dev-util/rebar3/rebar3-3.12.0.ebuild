# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

inherit bash-completion-r1

DESCRIPTION="Erlang build tool that makes it easy to compile and test Erlang \
applications and releases"
HOMEPAGE="https://www.rebar3.org"

HEX_DEPS="
	providers-1.8.1
	getopt-1.0.1
	cf-0.2.2
	erlware_commons-1.3.1
	bbmustache-1.6.1
	certifi-2.5.1
	cth_readable-1.4.5
	eunit_formatters-0.5.0
	relx-3.33.0
	ssl_verify_fun-1.1.5
	parse_trans-3.3.0
	meck-0.8.13
"

SRC_URI="
	https://github.com/erlang/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
"

for dep in $HEX_DEPS
do
	SRC_URI+=" https://repo.hex.pm/tarballs/$dep.tar"
done

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


src_unpack() {
	unpack ${P}.tar.gz

	cache_dir=${HOME}/cache

	einfo "Unpacking package index ..."
	mkdir -p ${cache_dir}/hex # /hexpm/packages
	gunzip < ${FILESDIR}/packages.idx.gz > ${cache_dir}/hex/packages.idx \
		|| die "Failed to unpack registry"

	for dep in $HEX_DEPS
	do
		name=${dep%-*}
		out=${S}/_build/default/lib/${name}
		tarfile=${DISTDIR}/${dep}.tar

		mkdir -p ${out}
		einfo "Unpacking Hex package ${dep} ..."
		tar -xOf ${tarfile} contents.tar.gz | tar -xz -C ${out} || die "Failed to unpack ${dep}"
		# cp ${tarfile} ${cache_dir}/hex/hexpm/packages || die "Failed to copy package ${dep}"		
	done
}

src_compile() {
	REBAR_CACHE_DIR=${HOME}/cache \
	./bootstrap \
	|| die "Failed to bootstrap"
}

src_test() {
	./rebar3 eunit || die "Failed running unit tests"
	./rebar3 ct || die "Failed running tests"
}

src_install() {
	dobin rebar3
	dodoc rebar.config.sample README.md

	if use bash-completion; then
		dobashcomp priv/shell-completion/bash/${PN}
	fi

	if use fish-completion; then
		insinto /usr/share/fish/completions
		doins priv/shell-completion/fish/${PN}.fish
	fi

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		doins priv/shell-completions/zsh/_${PN}
	fi
}
