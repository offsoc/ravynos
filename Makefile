
MACHINE!=	uname -m
MACHINE_ARCH!=	uname -p
TARGET?=	${MACHINE}.${MACHINE_ARCH}
TARGET_ARCH?=	${MACHINE_ARCH}
.export MACHINE MACHINE_CPUARCH TARGET TARGET_ARCH

SRCTOP=		   ${.CURDIR}
MACTOP=		   ${SRCTOP}/_distribution-macOS
BSDTOP=		   ${SRCTOP}/_FreeBSD
OBJTOP?=	   /usr/obj/ravynOS/${TARGET}
BUILDROOT=	   ${OBJTOP}/release/dist/ravynOS
RAVYNOS_VERSION!=  sed -e '1q;d' ${SRCTOP}/version.txt
RAVYNOS_CODENAME!= sed -e '2q;d' ${SRCTOP}/version.txt
.ifndef CORES
CORES!=		   sysctl -n hw.ncpu
.endif
DESTDIR=
.export DESTDIR SRCTOP OBJTOP BUILDROOT RAVYNOS_VERSION RAVYNOS_CODENAME CORES

MK_WERROR=      no
WARNS=          1
BMAKE?=		bmake
GMAKE?=		gmake

.include <rvn.common.mk>

buildworld: _bootstrap

_BOOTSTRAP_OBJDIRS=	${OBJTOP}/_bootstrap/llvmCore \
			${OBJTOP}/tmp/obj-tools

${_BOOTSTRAP_OBJDIRS}:
.for d in ${.TARGET}
	mkdir -p ${d}
.endfor

${OBJTOP}/_bootstrap/llvmCore/Makefile:
	cd ${.TARGET:H}; ${MACTOP}/llvmCore/configure \
		--prefix=/usr --sysconfdir=/etc --localstatedir=/var \
		--target=${MACHINE}-apple-darwin \
		--enable-optimized --disable-assertions --disable-docs

_bootstrap-llvmCore: ${OBJTOP}/${.TARGET:S/-/\//}/Makefile
	cd ${OBJTOP}/${.TARGET:S/-/\//}; \
		PYTHONPATH=${MACTOP}/llvmCore/utils/llvm-build/llvmbuild \
		MAKEFLAGS="" MAKE=${GMAKE} \
		${GMAKE}
	cd ${OBJTOP}/${.TARGET:S/-/\//}; MAKEFLAGS="" MAKE="${GMAKE}" \
		${GMAKE} install DESTDIR=${OBJTOP}/tmp/obj-tools

_bootstrap: ${_BOOTSTRAP_OBJDIRS} .WAIT _bootstrap-llvmCore
