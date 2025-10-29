# Makefile for building VictoriaLogs RPMs
# Supports EL8, EL9, RHEL8, RHEL9

VERSION ?= 0.0.2
RELEASE ?= 1
ARCH ?= x86_64

# RPM build directories
RPMBUILD_DIR := $(HOME)/rpmbuild
SPECS_DIR := $(RPMBUILD_DIR)/SPECS
SOURCES_DIR := $(RPMBUILD_DIR)/SOURCES
RPMS_DIR := $(RPMBUILD_DIR)/RPMS/$(ARCH)

# Distribution targets
DISTS := el8 el9

.PHONY: all clean setup rpm-victorialogs rpm-vlagent rpm-vlogscli rpm help

all: setup rpm

help:
	@echo "VictoriaLogs RPM Build Targets:"
	@echo ""
	@echo "  make rpm VERSION=X.Y.Z          - Build all RPMs for all distributions"
	@echo "  make rpm-victorialogs VERSION=X.Y.Z - Build victorialogs RPM only"
	@echo "  make rpm-vlagent VERSION=X.Y.Z      - Build vlagent RPM only"
	@echo "  make rpm-vlogscli VERSION=X.Y.Z     - Build vlogscli RPM only"
	@echo "  make clean                          - Clean build artifacts"
	@echo ""
	@echo "Current version: $(VERSION)"
	@echo "Supported distributions: $(DISTS)"

# Setup rpmbuild directory structure
setup:
	@echo "Setting up rpmbuild directory structure..."
	@mkdir -p $(RPMBUILD_DIR)/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
	@mkdir -p output

# Build all RPMs
rpm: rpm-victorialogs rpm-vlagent rpm-vlogscli
	@echo "All RPMs built successfully!"
	@echo "Output directory: ./output/"
	@ls -lh output/*.rpm

# Build victorialogs RPM for all distributions
rpm-victorialogs: setup
	@echo "Building victorialogs RPM for version $(VERSION)..."
	@for dist in $(DISTS); do \
		echo "Building for $$dist..."; \
		cp victorialogs.spec $(SPECS_DIR)/; \
		cp victorialogs.service $(SOURCES_DIR)/; \
		cp victorialogs.conf $(SOURCES_DIR)/; \
		rpmbuild -bb \
			--define "_topdir $(RPMBUILD_DIR)" \
			--define "dist .$$dist" \
			--define "version $(VERSION)" \
			--define "release $(RELEASE)" \
			$(SPECS_DIR)/victorialogs.spec; \
		cp $(RPMS_DIR)/victorialogs-$(VERSION)-$(RELEASE).$$dist.$(ARCH).rpm output/; \
	done
	@echo "victorialogs RPMs built successfully!"

# Build vlagent RPM for all distributions
rpm-vlagent: setup
	@echo "Building vlagent RPM for version $(VERSION)..."
	@for dist in $(DISTS); do \
		echo "Building for $$dist..."; \
		cp vlagent.spec $(SPECS_DIR)/; \
		cp vlagent.service $(SOURCES_DIR)/; \
		cp vlagent.conf $(SOURCES_DIR)/; \
		rpmbuild -bb \
			--define "_topdir $(RPMBUILD_DIR)" \
			--define "dist .$$dist" \
			--define "version $(VERSION)" \
			--define "release $(RELEASE)" \
			$(SPECS_DIR)/vlagent.spec; \
		cp $(RPMS_DIR)/vlagent-$(VERSION)-$(RELEASE).$$dist.$(ARCH).rpm output/; \
	done
	@echo "vlagent RPMs built successfully!"

# Build vlogscli RPM for all distributions
rpm-vlogscli: setup
	@echo "Building vlogscli RPM for version $(VERSION)..."
	@for dist in $(DISTS); do \
		echo "Building for $$dist..."; \
		cp vlogscli.spec $(SPECS_DIR)/; \
		rpmbuild -bb \
			--define "_topdir $(RPMBUILD_DIR)" \
			--define "dist .$$dist" \
			--define "version $(VERSION)" \
			--define "release $(RELEASE)" \
			$(SPECS_DIR)/vlogscli.spec; \
		cp $(RPMS_DIR)/vlogscli-$(VERSION)-$(RELEASE).$$dist.$(ARCH).rpm output/; \
	done
	@echo "vlogscli RPMs built successfully!"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(RPMBUILD_DIR)
	@rm -rf output
	@echo "Clean complete!"

