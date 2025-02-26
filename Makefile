# Copyright (c) 2014-2019 Franco Fichtner <franco@opnsense.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

all:
	@cat ${.CURDIR}/README.md | ${PAGER}

.include "Mk/defaults.mk"

CORE_COMMIT!=	${.CURDIR}/Scripts/version.sh

CORE_VERSION?=	${CORE_COMMIT:[1]}
CORE_REVISION?=	${CORE_COMMIT:[2]}
CORE_HASH?=	${CORE_COMMIT:[3]}

.if "${CORE_REVISION}" != "" && "${CORE_REVISION}" != "0"
CORE_PKGVERSION=	${CORE_VERSION}_${CORE_REVISION}
.else
CORE_PKGVERSION=	${CORE_VERSION}
.endif

CORE_ABI?=	19.1
CORE_ARCH?=	${ARCH}
CORE_FLAVOUR=	${FLAVOUR}
CORE_OPENVPN?=	# empty
CORE_PHP?=	72
CORE_PYTHON2?=	27
CORE_PYTHON?=	37
CORE_RADVD?=	1
CORE_SQUID?=	# empty
CORE_SURICATA?=	# empty

_FLAVOUR!=	if [ -f ${OPENSSL} ]; then ${OPENSSL} version; fi
FLAVOUR?=	${_FLAVOUR:[1]}

.if "${FLAVOUR}" == OpenSSL || "${FLAVOUR}" == ""
CORE_REPOSITORY?=	${CORE_ABI}/latest
.elif "${FLAVOUR}" == LibreSSL
CORE_REPOSITORY?=	${CORE_ABI}/libressl
.else
CORE_REPOSITORY?=	${FLAVOUR}
.endif

CORE_MESSAGE?=		Carry on my wayward son
CORE_NAME?=		opnsense-devel
CORE_TYPE?=		development

CORE_COMMENT?=		${CORE_PRODUCT} ${CORE_TYPE} package
CORE_MAINTAINER?=	project@opnsense.org
CORE_ORIGIN?=		opnsense/${CORE_NAME}
CORE_PACKAGESITE?=	https://pkg.opnsense.org
CORE_PRODUCT?=		OPNsense
CORE_WWW?=		https://opnsense.org/

CORE_COPYRIGHT_HOLDER?=	Deciso B.V.
CORE_COPYRIGHT_WWW?=	https://www.deciso.com/
CORE_COPYRIGHT_YEARS?=	2014-2019

CORE_DEPENDS_amd64?=	beep bsdinstaller
CORE_DEPENDS_i386?=	${CORE_DEPENDS_amd64}

CORE_DEPENDS?=		${CORE_DEPENDS_${CORE_ARCH}} \
			ca_root_nss \
			choparp \
			cpustats \
			dhcp6c \
			dhcpleases \
			dnsmasq \
			dpinger \
			expiretable \
			filterlog \
			ifinfo \
			flock \
			flowd \
			hostapd \
			isc-dhcp44-relay \
			isc-dhcp44-server \
			lighttpd \
			monit \
			mpd5 \
			ntp \
			openssh-portable \
			openvpn${CORE_OPENVPN} \
			opnsense-lang \
			opnsense-update \
			pam_opnsense \
			pftop \
			php${CORE_PHP}-ctype \
			php${CORE_PHP}-curl \
			php${CORE_PHP}-dom \
			php${CORE_PHP}-filter \
			php${CORE_PHP}-gettext \
			php${CORE_PHP}-hash \
			php${CORE_PHP}-json \
			php${CORE_PHP}-ldap \
			php${CORE_PHP}-openssl \
			php${CORE_PHP}-pdo \
			php${CORE_PHP}-pecl-radius \
			php${CORE_PHP}-phalcon \
			php${CORE_PHP}-phpseclib \
			php${CORE_PHP}-session \
			php${CORE_PHP}-simplexml \
			php${CORE_PHP}-sockets \
			php${CORE_PHP}-sqlite3 \
			php${CORE_PHP}-xml \
			php${CORE_PHP}-zlib \
			py${CORE_PYTHON2}-Jinja2 \
			py${CORE_PYTHON2}-dnspython \
			py${CORE_PYTHON2}-ipaddress \
			py${CORE_PYTHON2}-netaddr \
			py${CORE_PYTHON2}-requests \
			py${CORE_PYTHON2}-sqlite3 \
			py${CORE_PYTHON2}-ujson \
			py${CORE_PYTHON}-Jinja2 \
			py${CORE_PYTHON}-dnspython \
			py${CORE_PYTHON}-netaddr \
			py${CORE_PYTHON}-requests \
			py${CORE_PYTHON}-sqlite3 \
			py${CORE_PYTHON}-ujson \
			radvd${CORE_RADVD} \
			rate \
			rrdtool \
			samplicator \
			squid${CORE_SQUID} \
			sshlockout_pf \
			strongswan \
			sudo \
			suricata${CORE_SURICATA} \
			syslog-ng \
			syslogd \
			unbound \
			wpa_supplicant \
			zip

WRKDIR?=${.CURDIR}/work
WRKSRC?=${WRKDIR}/src
PKGDIR?=${WRKDIR}/pkg
MFCDIR?=${WRKDIR}/mfc

WANTS=		p5-File-Slurp php${CORE_PHP}-pear-PHP_CodeSniffer \
		phpunit7-php${CORE_PHP} py${CORE_PYTHON}-pycodestyle

.for WANT in ${WANTS}
want-${WANT}:
	@${PKG} info ${WANT} > /dev/null
.endfor

mount:
	@if [ ! -f ${WRKDIR}/.mount_done ]; then \
	    echo -n "Enabling core.git live mount..."; \
	    sed ${SED_REPLACE} ${.CURDIR}/src/opnsense/version/core.in > \
	        ${.CURDIR}/src/opnsense/version/core; \
	    mount_unionfs ${.CURDIR}/src ${LOCALBASE}; \
	    touch ${WRKDIR}/.mount_done; \
	    echo "done"; \
	    service configd restart; \
	fi

umount:
	@if [ -f ${WRKDIR}/.mount_done ]; then \
	    echo -n "Disabling core.git live mount..."; \
	    umount -f "<above>:${.CURDIR}/src"; \
	    rm ${WRKDIR}/.mount_done; \
	    echo "done"; \
	    service configd restart; \
	fi

manifest:
	@echo "name: \"${CORE_NAME}\""
	@echo "version: \"${CORE_PKGVERSION}\""
	@echo "origin: \"${CORE_ORIGIN}\""
	@echo "comment: \"${CORE_COMMENT}\""
	@echo "desc: \"${CORE_HASH}\""
	@echo "maintainer: \"${CORE_MAINTAINER}\""
	@echo "www: \"${CORE_WWW}\""
	@echo "message: \"${CORE_MESSAGE}\""
	@echo "categories: [ \"sysutils\", \"www\" ]"
	@echo "licenselogic: \"single\""
	@echo "licenses: [ \"BSD2CLAUSE\" ]"
	@echo "prefix: ${LOCALBASE}"
	@echo "vital: true"
	@echo "deps: {"
	@for CORE_DEPEND in ${CORE_DEPENDS}; do \
		if ! ${PKG} query '  %n: { version: "%v", origin: "%o" }' \
		    $${CORE_DEPEND}; then \
			echo ">>> Missing dependency: $${CORE_DEPEND}" >&2; \
			exit 1; \
		fi; \
	done
	@echo "}"

name:
	@echo ${CORE_NAME}

depends:
	@echo ${CORE_DEPENDS}

.if ${.TARGETS:Mupgrade}
PKG_FORMAT?=	tar
.else
PKG_FORMAT?=	txz
.endif

PKG_SCRIPTS=	+PRE_INSTALL +POST_INSTALL \
		+PRE_UPGRADE +POST_UPGRADE \
		+PRE_DEINSTALL +POST_DEINSTALL

scripts:
.for PKG_SCRIPT in ${PKG_SCRIPTS}
	@if [ -f ${.CURDIR}/${PKG_SCRIPT} ]; then \
		cp -- ${.CURDIR}/${PKG_SCRIPT} ${DESTDIR}/; \
	fi
.endfor

install:
	@${MAKE} -C ${.CURDIR}/contrib install DESTDIR=${DESTDIR}
	@${MAKE} -C ${.CURDIR}/src install DESTDIR=${DESTDIR} ${MAKE_REPLACE}

collect:
	@(cd ${.CURDIR}/src; find * -type f) | while read FILE; do \
		if [ -f ${DESTDIR}${LOCALBASE}/$${FILE} ]; then \
			tar -C ${DESTDIR}${LOCALBASE} -cpf - $${FILE} | \
			    tar -C ${.CURDIR}/src -xpf -; \
		fi; \
	done

bootstrap:
	@${MAKE} -C ${.CURDIR}/src install-bootstrap DESTDIR=${DESTDIR} \
	    NO_SAMPLE=please ${MAKE_REPLACE}

plist:
	@(${MAKE} -C ${.CURDIR}/contrib plist && \
	    ${MAKE} -C ${.CURDIR}/src plist) | sort

plist-fix:
	@${MAKE} DESTDIR=${DESTDIR} plist > ${.CURDIR}/plist

plist-check:
	@mkdir -p ${WRKDIR}
	@${MAKE} DESTDIR=${DESTDIR} plist > ${WRKDIR}/plist.new
	@cat ${.CURDIR}/plist > ${WRKDIR}/plist.old
	@if ! diff -uq ${WRKDIR}/plist.old ${WRKDIR}/plist.new > /dev/null ; then \
		diff -u ${WRKDIR}/plist.old ${WRKDIR}/plist.new || true; \
		echo ">>> Package file lists do not match.  Please run 'make plist-fix'." >&2; \
		rm ${WRKDIR}/plist.*; \
		exit 1; \
	fi
	@rm ${WRKDIR}/plist.*

metadata:
	@mkdir -p ${DESTDIR}
	@${MAKE} DESTDIR=${DESTDIR} scripts
	@${MAKE} DESTDIR=${DESTDIR} manifest > ${DESTDIR}/+MANIFEST
	@${MAKE} DESTDIR=${DESTDIR} plist > ${DESTDIR}/plist

package-check:
	@if [ -f ${WRKDIR}/.mount_done ]; then \
		echo ">>> Cannot continue with live mount.  Please run 'make umount'." >&2; \
		exit 1; \
	fi

package: plist-check package-check clean-wrksrc
.for CORE_DEPEND in ${CORE_DEPENDS}
	@if ! ${PKG} info ${CORE_DEPEND} > /dev/null; then ${PKG} install -yfA ${CORE_DEPEND}; fi
.endfor
	@echo -n ">>> Generating metadata for ${CORE_NAME}-${CORE_PKGVERSION}..."
	@${MAKE} DESTDIR=${WRKSRC} FLAVOUR=${FLAVOUR} metadata
	@echo " done"
	@echo -n ">>> Staging files for ${CORE_NAME}-${CORE_PKGVERSION}..."
	@${MAKE} DESTDIR=${WRKSRC} FLAVOUR=${FLAVOUR} install
	@echo " done"
	@echo ">>> Packaging files for ${CORE_NAME}-${CORE_PKGVERSION}:"
	@PORTSDIR=${.CURDIR} ${PKG} create -f ${PKG_FORMAT} -v -m ${WRKSRC} \
	    -r ${WRKSRC} -p ${WRKSRC}/plist -o ${PKGDIR}

upgrade-check:
	@if ! ${PKG} info ${CORE_NAME} > /dev/null; then \
		echo ">>> Cannot find package.  Please run 'opnsense-update -t ${CORE_NAME}'" >&2; \
		exit 1; \
	fi

upgrade: upgrade-check clean-pkgdir package
	@${PKG} delete -fy ${CORE_NAME} || true
	@${PKG} add ${PKGDIR}/*.${PKG_FORMAT}
	@touch ${LOCALBASE}/opnsense/www/index.php
	@pluginctl webgui

lint-shell:
	@find ${.CURDIR}/src ${.CURDIR}/Scripts \
	    -name "*.sh" -type f -print0 | xargs -0 -n1 sh -n

lint-xml:
	@find ${.CURDIR}/src ${.CURDIR}/Scripts \
	    -name "*.xml*" -type f -print0 | xargs -0 -n1 xmllint --noout

SCRIPTDIRS!=	find ${.CURDIR}/src/opnsense/scripts -type d -depth 1

lint-exec:
.for DIR in ${.CURDIR}/src/etc/rc.d ${SCRIPTDIRS}
.if exists(${DIR})
	@find ${DIR} -path '**/htdocs_default' -prune -o -type f \
	    ! -name "*.xml" ! -name "*.csv" ! -name "*.sql" -print0 | \
	    xargs -0 -t -n1 test -x || \
	    (echo "Missing executable permission in ${DIR}"; exit 1)
.endif
.endfor

lint-php:
	@find ${.CURDIR}/src \
	    ! -name "*.xml" ! -name "*.xml.sample" ! -name "*.eot" \
	    ! -name "*.svg" ! -name "*.woff" ! -name "*.woff2" \
	    ! -name "*.otf" ! -name "*.png" ! -name "*.js" \
	    ! -name "*.scss" ! -name "*.py" ! -name "*.ttf" \
	    ! -name "*.tgz" ! -name "*.xml.dist" ! -name "*.tgb" \
	    -type f -print0 | xargs -0 -n1 php -l

lint: plist-check lint-shell lint-xml lint-exec lint-php

sweep:
	find ${.CURDIR}/src -type f -name "*.map" -print0 | \
	    xargs -0 -n1 rm
	if grep -nr sourceMappingURL= ${.CURDIR}/src; then \
		echo "Mentions of sourceMappingURL must be removed"; \
		exit 1; \
	fi
	find ${.CURDIR}/src ! -name "*.min.*" ! -name "*.svg" \
	    ! -name "*.ser" -type f -print0 | \
	    xargs -0 -n1 ${.CURDIR}/Scripts/cleanfile
	find ${.CURDIR}/Scripts ${.CURDIR}/.github -type f -print0 | \
	    xargs -0 -n1 ${.CURDIR}/Scripts/cleanfile
	find ${.CURDIR} -type f -depth 1 -print0 | \
	    xargs -0 -n1 ${.CURDIR}/Scripts/cleanfile

STYLEDIRS?=	src/etc/inc src/opnsense

style-python: want-py${CORE_PYTHON}-pycodestyle
	@pycodestyle --ignore=E501 ${.CURDIR}/src || true

style-php: want-php${CORE_PHP}-pear-PHP_CodeSniffer
	@: > ${WRKDIR}/style.out
.for STYLEDIR in ${STYLEDIRS}
	@(phpcs --standard=ruleset.xml ${.CURDIR}/${STYLEDIR} \
	    || true) >> ${WRKDIR}/style.out
.endfor
	@echo -n "Total number of style warnings: "
	@grep '| WARNING' ${WRKDIR}/style.out | wc -l
	@echo -n "Total number of style errors:   "
	@grep '| ERROR' ${WRKDIR}/style.out | wc -l
	@cat ${WRKDIR}/style.out | ${PAGER}
	@rm ${WRKDIR}/style.out

style-fix: want-php${CORE_PHP}-pear-PHP_CodeSniffer
.for STYLEDIR in ${STYLEDIRS}
	phpcbf --standard=ruleset.xml ${.CURDIR}/${STYLEDIR} || true
.endfor

style: style-python style-php

license: want-p5-File-Slurp
	@${.CURDIR}/Scripts/license > ${.CURDIR}/LICENSE

dhparam:
.for BITS in 1024 2048 4096
	${OPENSSL} dhparam -out \
	    ${.CURDIR}/src/etc/dh-parameters.${BITS}.sample ${BITS}
.endfor

ARGS=	diff mfc

# handle argument expansion for required targets
.for TARGET in ${.TARGETS}
_TARGET=		${TARGET:C/\-.*//}
.if ${_TARGET} != ${TARGET}
.for ARGUMENT in ${ARGS}
.if ${_TARGET} == ${ARGUMENT}
${_TARGET}_ARGS+=	${TARGET:C/^[^\-]*(\-|\$)//:S/,/ /g}
${TARGET}: ${_TARGET}
.endif
.endfor
${_TARGET}_ARG=		${${_TARGET}_ARGS:[0]}
.endif
.endfor

diff:
	@git diff --stat -p stable/${CORE_ABI} ${.CURDIR}/${diff_ARGS:[1]}

mfc: clean-mfcdir
.for MFC in ${mfc_ARGS}
.if exists(${MFC})
	@cp -r ${MFC} ${MFCDIR}
	@git checkout stable/${CORE_ABI}
	@rm -r ${MFC}
	@mv ${MFCDIR}/$$(basename ${MFC}) ${MFC}
	@git add .
	@if ! git diff --quiet HEAD; then \
		git commit -m "${MFC}: sync with master"; \
	fi
.else
	@git checkout stable/${CORE_ABI}
	@git cherry-pick -x ${MFC}
.endif
	@git checkout master
.endfor

test: want-phpunit7-php${CORE_PHP}
	@if [ "$$(${PKG} query %n-%v ${CORE_NAME})" != "${CORE_NAME}-${CORE_PKGVERSION}" ]; then \
		echo "Installed version does not match, expected ${CORE_NAME}-${CORE_PKGVERSION}"; \
		exit 1; \
	fi
	@cd ${.CURDIR}/src/opnsense/mvc/tests && \
	    phpunit --configuration PHPunit.xml

checkout:
	@${GIT} reset -q ${.CURDIR}/src && \
	    ${GIT} checkout -f ${.CURDIR}/src && \
	    ${GIT} clean -xdqf ${.CURDIR}/src

clean-pkgdir:
	@rm -rf ${PKGDIR}
	@mkdir -p ${PKGDIR}

clean-mfcdir:
	@rm -rf ${MFCDIR}
	@mkdir -p ${MFCDIR}

clean-wrksrc:
	@rm -rf ${WRKSRC}
	@mkdir -p ${WRKSRC}

clean: clean-pkgdir clean-wrksrc clean-mfcdir

.PHONY: license plist
