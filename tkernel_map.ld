ENTRY(Reset_Handler)

MEMORY
{
  RAM (xrw)		: ORIGIN = 0x20000000, LENGTH = 96K
  ROM (rx)		: ORIGIN = 0x08000000, LENGTH = 1024K
}

SECTIONS {
	.text : {
		. = ALIGN(8);
		__vector_org = .;
		*(.vector)
		__start = .;
		*(.text)
		*(.text.*)
		*(.rodata)
		*(.rodata.*)
        __rom_end = .;
	} >ROM
	. = ALIGN(8);
	__data_org = .;
	vector 0x20000000 (NOLOAD) : {
		__vector_start = .;
		*(.data_vector)
		__vector_end = .;
	} >RAM
	.data : AT(__data_org) {
		__data_start = .;
		*(.data)
		*(.data.*)
		. = ALIGN(8);
		__data_end = .;
	} >RAM
	.bss ALIGN(8) (NOLOAD) : {
		__bss_start = .;
		PROVIDE (__noinit_start = .);
		*(.noinit)
		PROVIDE (__noinit_end = .);
		*(.bss)
		*(.bss.*)
		*(COMMON)
		. = ALIGN(8);
		__bss_end = .;
		__end = .;
	} >RAM
}

