OUTPUT_FORMAT("binary")

SECTIONS {
    . = 0x7C00;
    .boot : {
        *o(.boot)
        . = 510;
        BYTE(0x55)
        BYTE(0xAA)
    }
    . = 0x7E00;
    .other : {
        *o(.text)
    }
}

