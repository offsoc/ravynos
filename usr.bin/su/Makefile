.include <src.opts.mk>

PROG=	su

LIBADD=	util pam

.if ${MK_AUDIT} != "no"
CFLAGS+= -DUSE_BSM_AUDIT
LIBADD+=	bsm System notify
.endif

BINOWN=	root
BINMODE=4555
PRECIOUSPROG=

.include <bsd.prog.mk>
