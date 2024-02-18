OUTPUT_FORMAT("binary")

SECTIONS {
    . = 0x7C00;
    .boot : {
        bin/boot.o(.text);
    }
    . = 0x7E00;
    .kernel : {
        bin/io.o(.text);
        bin/kernel.o(.text);
    }
}

