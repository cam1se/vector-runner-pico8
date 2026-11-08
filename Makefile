LUA ?= lua
CART := vector_runner_pico8.p8

.PHONY: test runtime-smoke export-png

test:
	$(LUA) scripts/test_cart.lua $(CART)

# Set PICO8_BIN to the licensed PICO-8 binary to exercise its headless loader.
runtime-smoke:
	@test -n "$(PICO8_BIN)" || (echo "Set PICO8_BIN to the PICO-8 executable"; exit 2)
	$(PICO8_BIN) -x "$(abspath $(CART))"

# Uses the licensed official runtime and deliberately preserves an existing PNG.
export-png:
	@test -n "$(PICO8_BIN)" || (echo "Set PICO8_BIN to the PICO-8 executable"; exit 2)
	@test ! -e "$(CART).png" || (echo "Refusing to overwrite $(CART).png"; exit 2)
	$(PICO8_BIN) "$(abspath $(CART))" -export "$(abspath $(CART)).png"
