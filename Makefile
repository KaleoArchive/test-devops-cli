all: binary

help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

.PHONY: binary
binary:		## Build binary
	@go build

.PHONY: test
test:		## Run the test script
	@./scripts/test.sh
