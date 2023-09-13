OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x000000060;
  .text.init : { *(.text.init) }
  . = ALIGN(0x60);
  .tohost : { *(.tohost) }
  . = ALIGN(0x60);
  .text : { *(.text) }
  . = ALIGN(0x60);
  .data : { *(.data) }
  .bss : { *(.bss) }
  _end = .;
}

