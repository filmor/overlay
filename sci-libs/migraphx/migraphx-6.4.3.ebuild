# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOCS_BUILDER="doxygen"
DOCS_DIR="docs/doxygen"
DOCS_DEPEND="media-gfx/graphviz"
LLVM_COMPAT=( 20 )
ROCM_VERSION=${PV}
PYTHON_COMPAT=( python3_{10..13} )

inherit cmake docs edo flag-o-matic multiprocessing rocm llvm-r1 python-r1

DESCRIPTION="AMD's graph inference engine"
HOMEPAGE="https://github.com/ROCm/AMDMIGraphX"
SRC_URI="https://github.com/ROCm/AMDMIGraphX/archive/rocm-${PV}.tar.gz -> rocm-${P}.tar.gz"
S="${WORKDIR}/${PN}-rocm-${PV}"

LICENSE="BSD"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"
IUSE="python"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

BDEPEND="
	>=dev-build/rocm-cmake-5.3
"

DEPEND="
	>=dev-cpp/msgpack-cxx-6.0.0
	dev-util/hip:${SLOT}
	dev-util/rocBLAS:${SLOT}
	sci-libs/miopen:${SLOT}
	sci-libs/hipBLASlt:${SLOT}
	dev-libs/half
	dev-libs/nlohmann_json
	dev-libs/sqlite3
	dev-libs/protobuf

	python? (
		dev-python/pybind11[${PYTHON_USEDEP}]
	)
"

PATCHES=(
	# "${FILESDIR}"/${PN}-5.4.2-add-missing-header.patch
	# "${FILESDIR}"/${PN}-5.4.2-link-cblas.patch
	# "${FILESDIR}"/${PN}-6.0.2-expand-isa-compatibility.patch
	# "${FILESDIR}"/${PN}-6.3.0-no-git.patch
	# "${FILESDIR}"/${PN}-6.3.0-find-cblas.patch
)

src_prepare() {
	cmake_src_prepare
	sed -e "s:,-rpath=.*\":\":" -i clients/CMakeLists.txt || die
}

src_configure() {
	llvm_prepend_path "${LLVM_SLOT}"
	rocm_use_clang

	# too many warnings
	append-cxxflags -Wno-explicit-specialization-storage-class -Wno-unused-value

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DBUILD_FILE_REORG_BACKWARD_COMPATIBILITY=OFF
		-DROCM_SYMLINK_LIBS=OFF
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-DCMAKE_INSTALL_INCLUDEDIR="include/migraphx"
		-DMIGRAPHX_ENABLE_PYTHON="$(usex python ON OFF)"
		-DBUILD_CLIENTS_SAMPLES=OFF
		-DBUILD_WITH_PIP=OFF
		-DLINK_BLIS=OFF
		-Wno-dev
	)

	cmake_src_configure
}

src_compile() {
	docs_compile
	cmake_src_compile
}

src_install() {
	cmake_src_install
}
