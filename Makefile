.PHONY: setup

setup:
	@echo "Configuring Git hooks path..."
	@git config core.hooksPath .githooks
	@echo "Git hooks path configured to use '.githooks'." 