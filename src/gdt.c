#include "gdt.h"

/* The GDT itself: 3 entries (null, kernel code, kernel data) */
static struct gdt_entry gdt[3];
static struct gdt_ptr   gp;

/* Defined in gdt_flush.s — performs lgdt + far-jump to reload CS */
extern void gdt_flush(uint32_t gdt_ptr_addr);

/*
 * gdt_set_gate — fill a GDT entry with a flat 4 GB segment descriptor.
 *
 * num    : index into gdt[]
 * base   : 32-bit linear base address of segment
 * limit  : 20-bit segment limit (in pages if granularity=1, else bytes)
 * access : access byte (present | DPL | type bits)
 * gran   : granularity byte (4K pages | 32-bit | limit high nibble)
 */
static void gdt_set_gate(int num, uint32_t base, uint32_t limit,
                         uint8_t access, uint8_t gran)
{
    gdt[num].base_low    = (base & 0xFFFF);
    gdt[num].base_middle = (base >> 16) & 0xFF;
    gdt[num].base_high   = (base >> 24) & 0xFF;

    gdt[num].limit_low   = (limit & 0xFFFF);
    gdt[num].granularity = ((limit >> 16) & 0x0F) | (gran & 0xF0);

    gdt[num].access      = access;
}

/*
 * gdt_install — set up the three standard flat-model descriptors and
 * load the GDT into the processor.
 *
 * Descriptor layout (Intel SDM Vol. 3A §3.4.5):
 *   access byte  0x9A = present(1) | DPL=00 | S=1 | type=1010 (code, exec/read)
 *   access byte  0x92 = present(1) | DPL=00 | S=1 | type=0010 (data, read/write)
 *   granularity  0xCF = limit high nibble=F | G=1(4K) | D/B=1(32-bit) | L=0 | AVL=0
 */
void gdt_install(void)
{
    /* Set up the GDT pointer */
    gp.limit = (sizeof(struct gdt_entry) * 3) - 1;
    gp.base  = (uint32_t)(uintptr_t)gdt;

    /* Entry 0: Mandatory null descriptor */
    gdt_set_gate(0, 0, 0, 0, 0);

    /* Entry 1: Kernel code segment — base 0, limit 4 GB, ring 0, execute/read */
    gdt_set_gate(1, 0, 0xFFFFFFFF, 0x9A, 0xCF);

    /* Entry 2: Kernel data segment — base 0, limit 4 GB, ring 0, read/write */
    gdt_set_gate(2, 0, 0xFFFFFFFF, 0x92, 0xCF);

    /* Load the new GDT and flush segment registers */
    gdt_flush((uint32_t)(uintptr_t)&gp);
}
