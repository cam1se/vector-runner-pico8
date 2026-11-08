LUA ?= lua
CART := vector_runner_pico8.p8
ARTIFACT := $(CART).png

.PHONY: test runtime-smoke export-png build

test:
	$(LUA) scripts/test_cart.lua $(CART)

# Set PICO8_BIN to the licensed PICO-8 binary to exercise its headless loader.
runtime-smoke:
	@test -n "$(PICO8_BIN)" || (echo "Set PICO8_BIN to the PICO-8 executable"; exit 2)
	$(PICO8_BIN) -x "$(abspath $(CART))"

# Uses the licensed official runtime and deliberately preserves an existing PNG.
export-png:
	@test -n "$(PICO8_BIN)" || (echo "Set PICO8_BIN to the PICO-8 executable"; exit 2)
	@test ! -e "$(ARTIFACT)" || (echo "Refusing to overwrite $(ARTIFACT)"; exit 2)
	$(PICO8_BIN) "$(abspath $(CART))" -export "$(abspath $(ARTIFACT))"
	@test -s "$(ARTIFACT)" || (echo "PICO-8 did not create $(ARTIFACT)"; exit 1)

# Full local release check. The exporter is intentionally explicit because it
# requires the user's licensed PICO-8 runtime.
build: test export-png
