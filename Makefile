PROJECT ?= mutter
DEBIAN_RULES := debian/rules

.PHONY: all
all:

# Clean
#
.PHONY: distclean
distclean: clean

.PHONY: clean
clean: clean-deb

.PHONY: clean-deb
clean-deb:
	rm -rf debian/.debhelper debian/${PROJECT} debian/debhelper-build-stamp debian/files debian/*.debhelper.log debian/*.postrm.debhelper debian/*.substvars

#
# Release
#
.PHONY: deb
deb: debian pre_debuild debuild post_debuild

.PHONY: pre_debuild
pre_debuild:
	# dh default use Makefile, set meson.build explicitly
	@echo "Checking if debian/rules needs --buildsystem=meson..."
	@if ! grep -q -- '--buildsystem=meson' $(DEBIAN_RULES); then \
		echo "Patching debian/rules to use meson..."; \
		if grep -q 'dh $$@' $(DEBIAN_RULES); then \
			sed -i 's/dh $$@/dh $$@ --buildsystem=meson/' $(DEBIAN_RULES); \
		fi ;\
	fi

.PHONY: debuild
debuild:
	debuild --no-sign -b

.PHONY: post_debuild
post_debuild:

.PHONY: release
release:
	gh workflow run .github/workflows/new_version.yaml --ref $(shell git branch --show-current)
