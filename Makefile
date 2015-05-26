# A makefile for emender-lib, a collection of libraries for Emender
# Copyright (C) 2015 Jaromir Hradilek <jhradilek@redhat.com>

# This program is  free software:  you can redistribute it and/or modify it
# under  the terms  of the  GNU General Public License  as published by the
# Free Software Foundation, version 3 of the License.
#
# This program  is  distributed  in the hope  that it will  be useful,  but
# WITHOUT  ANY WARRANTY;  without  even the implied  warranty of MERCHANTA-
# BILITY  or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.
#
# You should have received a copy of the  GNU General Public License  along
# with this program. If not, see <http://www.gnu.org/licenses/>.

# General information about the project:
NAME     = emender
VERSION  = 0.0.1

# General settings:
SHELL    = /bin/sh
INSTALL  = /usr/bin/install -c
POD2MAN  = /usr/bin/pod2man
SRCS    := $(shell find lib -name '*.lua' -type f -print)
DIRS     = $(addprefix $(datadir)/,$(shell find lib -type d -print))
MANS    := $(patsubst %.pod,%,$(shell find doc -name '*.pod' -type f -print))
DIRS    += $(patsubst doc/man%,$(mandir)%,$(shell find doc/man -type d -print))

# Target directories:
prefix   = /usr/local
datadir := $(prefix)/share/$(NAME)
mandir  := $(prefix)/share/man

# Helper functions. Do not edit these functions unless you really know what
# you are doing::
install_dirs  = $(INSTALL) -m $(2) -d $(1)
install_files = $(foreach file,$(1),$(INSTALL) -m $(3) $(file) $(addprefix $(2)/, $(file));)
install_mans  = $(foreach file,$(1),$(INSTALL) -m $(3) $(file) $(file:doc/man/%=$(2)/%);)
remove_dirs   = -rmdir $(shell printf "%s\n" $(1) | tac)
remove_files  = -rm -f $(addprefix $(2)/,$(1))
remove_mans   = -rm -f $(patsubst doc/man/%,$(2)/%,$(1))

# The following are the make rules. Do not edit the rules unless you really
# know what you are doing:
.PHONY: all
all: $(MANS)

.PHONY: install
install: $(MANS)
	@echo "Creating installation directories:"
	$(call install_dirs,$(DIRS),755)
	@echo "Installing libraries:"
	$(call install_files,$(SRCS),$(datadir),644)
	@echo "Installing manual pages:"
	$(call install_mans,$(MANS),$(mandir),644)

.PHONY: uninstall
uninstall:
	@echo "Removing libraries:"
	$(call remove_files,$(SRCS),$(datadir))
	@echo "Removing manual pages:"
	$(call remove_mans,$(MANS),$(mandir))
	@echo "Removing installation directories:"
	$(call remove_dirs,$(datadir) $(DIRS))

.PHONY: clean
clean:
	-rm -f $(MANS)

%.3: %.3.pod
	$(POD2MAN) --section=3 --center="$(NAME)" \
	                       --name="$(notdir $(basename $@))" \
	                       --release="Version $(VERSION)" $^ $@
