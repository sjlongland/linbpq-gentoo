# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_REPO_URI="https://github.com/sjlongland/linbpq.git"
inherit git-r3 user

DESCRIPTION="LinBPQ AX.25 and Net/ROM stack for Linux"
HOMEPAGE="http://www.cantab.net/users/john.wiseman/Documents/index.html"
SRC_URI=""
LICENSE="GPL-3+"
SLOT="0"

KEYWORDS="~amd64 ~arm ~x86"

IUSE="i2c"

DEPEND=">=dev-libs/libconfig-1.5
	>=net-libs/libpcap-1.8.1"
RDEPEND="${DEPEND}"

src_compile() {
	if use i2c
	then
		emake PREFIX="/usr"
	else
		emake I2C=n PREFIX="/usr"
	fi
}

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" install
	mkdir -p "${D}/etc/env.d"
	echo 'CONFIG_PROTECT="/var/lib/linbpq"' > "${D}/etc/env.d/99linbpq"
}

pkg_preinst() {
	# Create a group for LinBPQ:
	enewgroup linbpq
	# Create a user for LinBPQ:
	# - does not have a shell
	# - lives in /var/lib/linbpq
	# - belongs to the `uucp` group so it can access serial TNCs.
	enewuser linbpq -1 -1 /var/lib/linbpq linbpq uucp
	# Create a log directory for the linbpq user
	keepdir /var/log/linbpq
	# Change the ownership and permissions on the log directory to the
	# linbpq user so it can write there.
	fowners -R linbpq:linbpq /var/log/linbpq
	fperms -R 0775 /var/log/linbpq
}
