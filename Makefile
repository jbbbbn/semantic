BUILD_DIR = build

BOOT = $(BUILD_DIR)/boot.bin
KERNEL = $(BUILD_DIR)/kernel.bin
IMAGE = $(BUILD_DIR)/semantic.img

all: $(IMAGE)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BOOT): boot.asm | $(BUILD_DIR)
	nasm -f bin boot.asm -o $(BOOT)

$(KERNEL): kernel.asm | $(BUILD_DIR)
	nasm -f bin kernel.asm -o $(KERNEL)

$(IMAGE): $(BOOT) $(KERNEL)
	cat $(BOOT) $(KERNEL) > $(IMAGE)

run: $(IMAGE)
	qemu-system-i386 -drive format=raw,file=$(IMAGE)

clean:
	rm -rf $(BUILD_DIR)

rebuild: clean run

.PHONY: all run clean rebuild
