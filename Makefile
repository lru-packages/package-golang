NAME=golang
VERSION=1.10
ITERATION=1.lru
PREFIX=/usr/local
LICENSE=BSD
VENDOR="Google"
MAINTAINER="Ryan Parman"
DESCRIPTION="Go is an open source programming language that makes it easy to build simple, reliable, and efficient software."
URL=https://golang.org
RHEL=$(shell rpm -q --queryformat '%{VERSION}' centos-release)

#-------------------------------------------------------------------------------

all: info clean install-deps extract package move

#-------------------------------------------------------------------------------

.PHONY: info
info:
	@ echo "NAME:        $(NAME)"
	@ echo "VERSION:     $(VERSION)"
	@ echo "ITERATION:   $(ITERATION)"
	@ echo "PREFIX:      $(PREFIX)"
	@ echo "LICENSE:     $(LICENSE)"
	@ echo "VENDOR:      $(VENDOR)"
	@ echo "MAINTAINER:  $(MAINTAINER)"
	@ echo "DESCRIPTION: $(DESCRIPTION)"
	@ echo "URL:         $(URL)"
	@ echo "RHEL:        $(RHEL)"
	@ echo " "

#-------------------------------------------------------------------------------

.PHONY: clean
clean:
	rm -Rf /tmp/installdir* go*

#-------------------------------------------------------------------------------

.PHONY: install-deps
install-deps:
	yum -y install \
		gcc \
		gcc-c++ \
		git \
		glibc-devel \
		make \
		mercurial \
		tar \
	;

#-------------------------------------------------------------------------------

.PHONY: extract
extract:
	mkdir -p /tmp/installdir-$(NAME)-$(VERSION);
	wget https://storage.googleapis.com/golang/go$(VERSION).linux-amd64.tar.gz
	tar -C /tmp/installdir-$(NAME)-$(VERSION) -xzf go$(VERSION).linux-amd64.tar.gz
	cd /tmp/installdir-$(NAME)-$(VERSION) && \
		mkdir -p bin && \
		ln -s /usr/local/go/bin/go bin/go && \
		ln -s /usr/local/go/bin/godoc bin/godoc && \
		ln -s /usr/local/go/bin/gofmt bin/gofmt \
	;

#-------------------------------------------------------------------------------

.PHONY: package
package:

	fpm \
		-s dir \
		-d gcc \
		-d gcc-c++ \
		-d git \
		-d glibc-devel \
		-d make \
		-d mercurial \
		-d tar \
		-t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		-C /tmp/installdir-$(NAME)-$(VERSION) \
		-m $(MAINTAINER) \
		--iteration $(ITERATION) \
		--license $(LICENSE) \
		--vendor $(VENDOR) \
		--prefix $(PREFIX) \
		--url $(URL) \
		--description $(DESCRIPTION) \
		--rpm-defattrdir 0755 \
		--rpm-digest md5 \
		--rpm-compression gzip \
		--rpm-os linux \
		--rpm-auto-add-directories \
		go \
		bin \
	;

#-------------------------------------------------------------------------------

.PHONY: move
move:
	mv *.rpm /vagrant/repo/
