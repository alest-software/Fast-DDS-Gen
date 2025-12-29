mkfile_path = $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir = $(dir $(mkfile_path))

PROJECT_PACKAGE_NAME = fastddsgen
PROJECT_BUILD_NUMBER = 1
PROJECT_PREFIX = /opt/fastdds
PROJECT_MAINTAINER = you@example.com
PROJECT_DESCRIPTION = Fast-DDS-Gen

fastddsgen_MODULE_DIR = Fast-DDS-Gen
fastddsgen_VERSION = 4.1.0
fastddsgen_FULL_VERSION = $(fastddsgen_VERSION)-$(PROJECT_BUILD_NUMBER)
fastddsgen_ARCH = all
fastddsgen_BINARY_PACKAGE_NAME = $(PROJECT_PACKAGE_NAME)_$(fastddsgen_FULL_VERSION)_$(fastddsgen_ARCH)
fastddsgen_STAGE_DIR = $(mkfile_dir)/dest
fastddsgen_BINARY_STAGE_DIR = $(fastddsgen_STAGE_DIR)/$(fastddsgen_BINARY_PACKAGE_NAME)
fastddsgen_INSTALL_PATH = $(fastddsgen_BINARY_STAGE_DIR)/$(PROJECT_PREFIX)

project_srcdir = $(mkfile_dir)/$(fastddsgen_MODULE_DIR)
debian_dir = $(fastddsgen_BINARY_STAGE_DIR)/DEBIAN
control_file = $(debian_dir)/control

GRADLE = $(project_srcdir)/gradlew


all: assemble stage control package

assemble:
	$(GRADLE) -p $(project_srcdir) assemble

stage:
	$(GRADLE) -p $(project_srcdir) install --install_path=$(fastddsgen_INSTALL_PATH)

control:
	ARCH=$(dpkg --print-architecture)
	@mkdir -p $(debian_dir)
	@echo "Package: $(PROJECT_PACKAGE_NAME)" > $(control_file)
	@echo "Version: $(fastddsgen_FULL_VERSION)" >> $(control_file)
	@echo "Section: devel" >> $(control_file)
	@echo "Priority: optional" >> $(control_file)
	@echo "Architecture: $(ARCH)" >> $(control_file)
	@echo "Depends: openjdk-17-jre" >> $(control_file)
	@echo "Maintainer: $(PROJECT_MAINTAINER)" >> $(control_file)
	@echo "Description: $(PROJECT_DESCRIPTION)" >> $(control_file)
	@cat $(control_file)

package:
	chmod -R 0755 $(debian_dir)
	cd $(fastddsgen_STAGE_DIR); \
	dpkg-deb --build $(fastddsgen_BINARY_PACKAGE_NAME)

