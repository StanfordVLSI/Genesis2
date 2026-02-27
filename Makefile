# Genesis2 targets
#
# Nothing currently needed for building, but targets exist for formatting/test

.PHONY: all

all: format test


.PHONY: format

format:
	@echo "Formatting code with perltidy..."
	shopt -s globstar && \
	perltidy --pro=.perltidyrc -b -bext='/' bin/**/*.p[lm] PerlLibs/Genesis2/**/*.p[lm]


.PHONY: test

test:
	@echo "Running tests..."
	cd test/glctest && ./test.sh -debug 15
