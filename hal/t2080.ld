OUTPUT_ARCH( "powerpc" )

ENTRY( _reset )

/* On initial start, only a limited space(4k) is accessible.
 * Code here bootstraps to enable access to other needed address spaces */
BOOTSTRAP_TLB = 0xEFFFF000;

/* Entry point where RCW directs code to execute from */
BOOTSTRAP_ENTRY = 0xEFFFFFFC;

MEMORY
{
    FLASH (rx) : ORIGIN = ##WOLFBOOT_ORIGIN##, LENGTH = ##WOLFBOOT_PARTITION_BOOT_ADDRESS##
    /* Use L1 memory (DDR is not setup yet) */
    RAM (rwx) : ORIGIN = 0xFDD00000, LENGTH = 0x4000
}

SECTIONS
{
    /* boot code boot_ppc_start.S for _reset */
    .boot BOOTSTRAP_TLB :
    {
        KEEP(*(.boot))
    } = 0xFFFC
    . = ALIGN(4);

    /* entry point branch offset to _reset */
    .reset BOOTSTRAP_ENTRY :
    {
        KEEP(*(.reset))
    } = 0x4
    . = ALIGN(4);

    .text :
    {
        *(.text*)
        *(.rodata*)
        *(.sdata*)
    } > FLASH

    /* Read-only sections, merged into text segment: */
    .interp         : { *(.interp) }
    .hash           : { *(.hash) }
    .dynsym         : { *(.dynsym) }
    .dynstr         : { *(.dynstr) }
    .gnu.version    : { *(.gnu.version) }
    .gnu.version_r  : { *(.gnu.version_r) }
    .gnu.hash       : { *(.gnu.hash) }
    .rela.dyn       : { *(.rela.dyn) }

    _stored_data = .;

    .data : AT (_stored_data)
    {
        _start_data = .;
        KEEP(*(.data*))
        . = ALIGN(4);
        KEEP(*(.ramcode))
        . = ALIGN(4);
        _end_data = .;
    } > RAM

    .bss (NOLOAD) :
    {
        _start_bss = .;
        __bss_start__ = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _end_bss = .;
        __bss_end__ = .;
        _end = .;
    } > RAM

}
