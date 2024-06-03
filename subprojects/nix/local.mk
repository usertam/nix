programs += nix

nix_DIR := $(d)

nix_SOURCES := \
  $(wildcard $(d)/*.cc) \
  $(wildcard subprojects/nix-build/*.cc) \
  $(wildcard subprojects/nix-env/*.cc) \
  $(wildcard subprojects/nix-instantiate/*.cc) \
  $(wildcard subprojects/nix-store/*.cc)

ifdef HOST_UNIX
nix_SOURCES += \
  $(wildcard $(d)/unix/*.cc) \
  $(wildcard subprojects/build-remote/*.cc) \
  $(wildcard subprojects/nix-channel/*.cc) \
  $(wildcard subprojects/nix-collect-garbage/*.cc) \
  $(wildcard subprojects/nix-copy-closure/*.cc) \
  $(wildcard subprojects/nix-daemon/*.cc)
endif

INCLUDE_nix := -I $(d)
ifdef HOST_UNIX
  INCLUDE_nix += -I $(d)/unix
endif

nix_CXXFLAGS += $(INCLUDE_libutil) $(INCLUDE_libstore) $(INCLUDE_libfetchers) $(INCLUDE_libexpr) $(INCLUDE_libmain) -I subprojects/libcmd -I doc/manual $(INCLUDE_nix)

nix_LIBS = libexpr libmain libfetchers libstore libutil libcmd

nix_LDFLAGS = $(THREAD_LDFLAGS) $(SODIUM_LIBS) $(EDITLINE_LIBS) $(BOOST_LDFLAGS) $(LOWDOWN_LIBS)

ifdef HOST_WINDOWS
  # Increase the default reserved stack size to 65 MB so Nix doesn't run out of space
  nix_LDFLAGS += -Wl,--stack,$(shell echo $$((65 * 1024 * 1024)))
endif

$(foreach name, \
  nix-build nix-channel nix-collect-garbage nix-copy-closure nix-daemon nix-env nix-hash nix-instantiate nix-prefetch-url nix-shell nix-store, \
  $(eval $(call install-symlink, nix, $(bindir)/$(name))))
$(eval $(call install-symlink, $(bindir)/nix, $(libexecdir)/nix/build-remote))

subprojects/nix-env/user-env.cc: subprojects/nix-env/buildenv.nix.gen.hh

$(d)/develop.cc: $(d)/get-env.sh.gen.hh

subprojects/nix-channel/nix-channel.cc: subprojects/nix-channel/unpack-channel.nix.gen.hh

$(d)/main.cc: \
  doc/manual/generate-manpage.nix.gen.hh \
  doc/manual/utils.nix.gen.hh doc/manual/generate-settings.nix.gen.hh \
  doc/manual/generate-store-info.nix.gen.hh \
  $(d)/generated-doc/help-stores.md

$(d)/generated-doc/files/%.md: doc/manual/src/command-ref/files/%.md
	@mkdir -p $$(dirname $@)
	@cp $< $@

$(d)/profile.cc: $(d)/profile.md $(d)/generated-doc/files/profiles.md.gen.hh

$(d)/generated-doc/help-stores.md: doc/manual/src/store/types/index.md.in
	@mkdir -p $$(dirname $@)
	@echo 'R"(' >> $@.tmp
	@echo >> $@.tmp
	@cat $^ >> $@.tmp
	@echo >> $@.tmp
	@echo ')"' >> $@.tmp
	@mv $@.tmp $@
