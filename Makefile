SOURCE_DIR := src
OUTPUT_DIR := build
QEMU 	   := qemu-system-x86_64
QEMU_ARGS  := -drive format=raw, file=bin/os.bin
QEMU_ARGS  := -drive format=raw, file=bin/os.bin
BIN_FILE   := pacman.bin


.PHONY: run
run: $(OUTPUT_DIR)/%.bin
	$(QEMU) $(QEMU_ARGS)

$(OUTPUT_DIR)/%.o: $(SOURCE_DIR)/%.asm
	nasm -o $@ $<

.PHONY: clean
clean:
	rm -rf $(OUTPUT_DIR)
