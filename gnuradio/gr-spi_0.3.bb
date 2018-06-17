DESCRIPTION = "SPI source/sink blocks for GNU Radio"
HOMEPAGE = "https://github.com/mhe747/gr-spi"
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://CMakeLists.txt;md5=e84f563988fbb5a8798ffd8f9d28febf"

DEPENDS = "gnuradio"

inherit setuptools cmake

export BUILD_SYS
export HOST_SYS="${MULTIMACH_TARGET_SYS}"

FILES_SOLIBSDEV = ""
FILES_${PN} += "${datadir}/gnuradio/grc/blocks/* ${libdir}/*.so"

PN = "gr-spi"
PV = "0.3"

SRC_URI = "git://github.com/mhe747/gr-spi;branch=master"

S = "${WORKDIR}/git"

SRCREV = "${AUTOREV}"
