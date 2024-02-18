OUTPUT_FORMAT("binary")

SECTIONS {
    . = 0x7C00;
    .boot : {
        *o(.boot);
    }
    . = 0x7E00;
    .other : {
        *o(.text);
    }
}

