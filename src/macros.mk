#
# NetLabel Makefile Configuration & Macros
#
# NetLabel Tools are a collection of user space programs and libraries for
# working with the Linux NetLabel subsystem.  The NetLabel subsystem manages
# static and dynamic label mappings for network protocols such as CIPSO and
# RIPSO.
#
# Author: Paul Moore <paul@paul-moore.com>
#

#
# (c) Copyright Hewlett-Packard Development Company, L.P., 2006
# Copyright (c) 2013 Red Hat <pmoore@redhat.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

SHELL = /bin/bash

#
# simple /bin/bash script to find the top of the tree
#

TOPDIR := $(shell \
	ftd() { \
		cd $$1; \
		if [[ -r "macros.mk" ]]; then \
			pwd; \
		else \
			ftd "../"; \
		 fi \
	}; \
	ftd .)

#
# build configuration
#

V ?= 0

CPPFLAGS += -I$(TOPDIR) -I$(TOPDIR)/include
LIBFLAGS =

CFLAGS ?= -Wl,-z,relro -Wall -O0 -g
CFLAGS += -fPIC
LDFLAGS ?= -z relro -g

#
# build tools
#

LN ?= ln
MV ?= mv
CAT ?= cat
ECHO ?= echo
TAR ?= tar
MKDIR ?= mkdir

SED ?= sed
AWK ?= awk

DOXYGEN ?= doxygen

PYTHON ?= /usr/bin/env python

# we require gcc specific functionality
GCC ?= gcc

INSTALL ?= install

ifeq ($(V),0)
	MAKE += --quiet --no-print-directory
	ECHO_INFO ?= $(ECHO) ">> INFO:"
else
	ECHO_INFO ?= /bin/true || $(ECHO) ">> INFO:"
endif

#
# auto dependencies
#

MAKEDEP = @$(GCC) $(CPPFLAGS) -MM -MF $(patsubst %.o,%.d,$@) $<;
MAKEDEP_EXEC = \
	@$(GCC) $(CPPFLAGS) -MM -MT $(patsubst %.d,%,$@) \
		-MF $@ $(patsubst %.d,%.c,$@);

ADDDEP = \
	@adddep_func() { \
		$(MV) $$1 $$1.dtmp; \
		$(CAT) $$1.dtmp | $(SED) -e 's/\([^\]\)$$/\1 \\/' | \
			( $(CAT) - && $(ECHO) " $$2" ) > $$1; \
		$(RM) -f $@.dtmp; \
	}; \
	adddep_func

#
# build constants
#

VERSION_HDR = version.h

#
# documentation macros
#

ifeq ($(V),0)
	DOXYGEN_GEN = @echo " DOXYGEN $<";
endif
DOXYGEN_GEN += $(DOXYGEN) $<;

#
# build macros
#

PY_DISTUTILS = \
	VERSION_RELEASE="$(VERSION_RELEASE)" \
	CFLAGS="$(CFLAGS) $(CPPFLAGS)" LDFLAGS="$(LDFLAGS)" \
	$(PYTHON) ./setup.py

ifeq ($(V),0)
	PY_BUILD = @echo " PYTHON build";
endif
PY_BUILD += $(PY_DISTUTILS)
ifeq ($(V),0)
	PY_BUILD += -q
endif
PY_BUILD += build

ifeq ($(V),0)
	PY_INSTALL = @echo " PYTHON install";
endif
PY_INSTALL += $(PY_DISTUTILS)
ifeq ($(V),0)
	PY_INSTALL += -q
endif
PY_INSTALL += install

ifeq ($(V),0)
	COMPILE = @echo " CC $@";
endif
COMPILE += $(GCC) $(CFLAGS) $(CPPFLAGS) -o $@ -c $<;

ifeq ($(V),0)
	COMPILE_EXEC = @echo " CC $@";
endif
COMPILE_EXEC += $(GCC) $(CFLAGS) $(CPPFLAGS) -o $@ $< $(LDFLAGS);

ifeq ($(V),0)
	ARCHIVE = @echo " AR $@";
endif
ARCHIVE += $(AR) -cru $@ $?;

ifeq ($(V),0)
	LINK_EXEC = @echo " LD $@";
endif
LINK_EXEC += $(GCC) $(LDFLAGS) -o $@ $^ $(LIBFLAGS);

ifeq ($(V),0)
	LINK_LIB = @echo " LD $@" \
	       "($(patsubst %.so.$(VERSION_RELEASE),%.so.$(VERSION_MAJOR),$@))";
endif
LINK_LIB += $(GCC) $(LDFLAGS) -o $@ $^ -shared \
	-Wl,-soname=$(patsubst %.so.$(VERSION_RELEASE),%.so.$(VERSION_MAJOR),$@)

#
# install macros
#

ifeq ($(V),0)
	INSTALL_SBIN_MACRO = @echo " INSTALL $^ ($(INSTALL_SBIN_DIR))";
endif
INSTALL_SBIN_MACRO += \
		$(INSTALL) -o $(INSTALL_OWNER) -g $(INSTALL_GROUP) \
			-d "$(INSTALL_SBIN_DIR)"; \
		$(INSTALL) -o $(INSTALL_OWNER) -g $(INSTALL_GROUP) -m 0755 \
			$^ "$(INSTALL_SBIN_DIR)";

ifeq ($(V),0)
	INSTALL_SYSD_MACRO = @echo " INSTALL $^ ($(INSTALL_SYSD_DIR))";
endif
INSTALL_SYSD_MACRO += \
		$(INSTALL) -o $(INSTALL_OWNER) -g $(INSTALL_GROUP) \
			-d "$(INSTALL_SYSD_DIR)"; \
		$(INSTALL) -o $(INSTALL_OWNER) -g $(INSTALL_GROUP) -m 0644 \
			$^ "$(INSTALL_SYSD_DIR)";

ifeq ($(V),0)
	INSTALL_ETC_MACRO = @echo " INSTALL $^ ($(INSTALL_ETC_DIR))";
endif
INSTALL_ETC_MACRO += \
		$(INSTALL) -o $(INSTALL_OWNER) -g $(INSTALL_GROUP) \
			-d "$(INSTALL_ETC_DIR)"; \
		$(INSTALL) -o $(INSTALL_OWNER) -g $(INSTALL_GROUP) -m 0644 \
			$^ "$(INSTALL_ETC_DIR)";

ifeq ($(V),0)
	INSTALL_LIB_MACRO = @echo " INSTALL $^ ($(INSTALL_LIB_DIR)/$^)";
endif
INSTALL_LIB_MACRO += \
		basename=$$(echo $^ | sed -e 's/.so.*$$/.so/'); \
		soname=$$(objdump -p $^ | grep "SONAME" | awk '{print $$2}'); \
		$(INSTALL) -o $(INSTALL_OWNER) -g $(INSTALL_GROUP) \
			-d "$(INSTALL_LIB_DIR)"; \
		$(INSTALL) -o $(INSTALL_OWNER) -g $(INSTALL_GROUP) -m 0755 \
			$^ "$(INSTALL_LIB_DIR)"; \
		(cd "$(INSTALL_LIB_DIR)"; $(RM) $$soname); \
		(cd "$(INSTALL_LIB_DIR)"; $(LN) -s $^ $$soname); \
		(cd "$(INSTALL_LIB_DIR)"; $(RM) $$basname); \
		(cd "$(INSTALL_LIB_DIR)"; $(LN) -s $^ $$basename);

ifeq ($(V),0)
	INSTALL_PC_MACRO = \
	    @echo " INSTALL $$(cat /proc/$$$$/cmdline | awk '{print $$(NF)}')" \
		  " ($(INSTALL_LIB_DIR)/pkgconfig)";
endif
INSTALL_PC_MACRO += \
		$(INSTALL) -o $(INSTALL_OWNER) -g $(INSTALL_GROUP) \
			-d "$(INSTALL_LIB_DIR)/pkgconfig"; \
		$(INSTALL) -o $(INSTALL_OWNER) -g $(INSTALL_GROUP) -m 0644 \
			"$$(cat /proc/$$$$/cmdline | awk '{print $$(NF)}')" \
			"$(INSTALL_LIB_DIR)/pkgconfig"; \#

ifeq ($(V),0)
	INSTALL_INC_MACRO = @echo " INSTALL $^ ($(INSTALL_INC_DIR))";
endif
INSTALL_INC_MACRO += \
		$(INSTALL) -o $(INSTALL_OWNER) -g $(INSTALL_GROUP) \
			-d "$(INSTALL_INC_DIR)"; \
		$(INSTALL) -o $(INSTALL_OWNER) -g $(INSTALL_GROUP) -m 0644 \
			$^ "$(INSTALL_INC_DIR)";

ifeq ($(V),0)
	INSTALL_MAN8_MACRO = \
		@echo " INSTALL manpages ($(INSTALL_MAN_DIR)/man8)";
endif
INSTALL_MAN8_MACRO += \
		$(INSTALL) -o $(INSTALL_OWNER) -g $(INSTALL_GROUP) \
			-d "$(INSTALL_MAN_DIR)/man8"; \
		$(INSTALL) -o $(INSTALL_OWNER) -g $(INSTALL_GROUP) -m 0644 \
			$^ "$(INSTALL_MAN_DIR)/man8";

#
# default build targets
#

%.o: %.c
	$(MAKEDEP)
	$(COMPILE)
