SRC_DIR := src
OUT_DIR := out
SOURCES := $(wildcard $(SRC_DIR)/*.txt)
OUTPUTS := $(patsubst $(SRC_DIR)/%.txt,$(OUT_DIR)/%.txt,$(SOURCES))

.PHONY: all check build test clean ci show

all: test ## build and test everything

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(OUT_DIR)/%.txt: $(SRC_DIR)/%.txt | $(OUT_DIR)
	@echo "  BUILD $< -> $@"
	@tr '[:lower:]' '[:upper:]' < $< > $@

check: ## verify sources exist
	@if [ ! -d "$(SRC_DIR)" ] || [ -z "$(SOURCES)" ]; then \
	  echo "ERROR: no .txt files found in $(SRC_DIR)"; exit 1; \
	fi
	@echo "CHECK OK: $(words $(SOURCES)) source file(s) in $(SRC_DIR)"

build: $(OUTPUTS)

test: build ## fail if lowercase remains
	@if grep -l '[a-z]' $(OUTPUTS) >/dev/null 2>&1; then \
	  echo "TEST FAILED: lowercase characters remain"; exit 1; \
	fi
	@echo "TEST PASSED"

clean: ## remove the output directory
	rm -rf $(OUT_DIR)

ci: clean check test

show:
	@echo "SOURCES = $(SOURCES)"
	@echo "OUTPUTS = $(OUTPUTS)"

.PHONY: help report

help: ## show this help
	@grep -E '^[a-z]+:.*##' Makefile | sed 's/:.*## /  -  /'

report: out/report.txt ## write a summary of line counts

out/report.txt: $(OUTPUTS) | $(OUT_DIR)
	@echo "  REPORT $@"
	@date > $@
	@wc -l $^ >> $@
count: build ## report how many words were built
	@wc -w $(OUTPUTS) | tail -1
