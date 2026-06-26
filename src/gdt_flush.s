/*
 * gdt_flush.s — Load the new GDT and far-jump to reload the Code Segment.
 *
 * Called from gdt_install() in gdt.c as:
 *   gdt_flush((uint32_t)&gp);
 *
 * The argument (GDT pointer address) arrives in 4(%esp) per the i386 cdecl ABI.
 */
.global gdt_flush
.type   gdt_flush, @function
gdt_flush:
    mov 4(%esp), %eax     /* Load address of gdt_ptr struct */
    lgdt (%eax)           /* Load the GDT */

    /* Reload all data-segment registers with the kernel data selector (0x10) */
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss

    /* Far-jump to reload the Code Segment register (CS) with selector 0x08 */
    ljmp $0x08, $flush_cs
flush_cs:
    ret
.size gdt_flush, . - gdt_flush
