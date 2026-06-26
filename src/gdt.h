#ifndef GDT_H
#define GDT_H

#include <stdint.h>

/* GDT entry (descriptor) - 8 bytes */
struct gdt_entry {
    uint16_t limit_low;    /* Lower 16 bits of segment limit */
    uint16_t base_low;     /* Lower 16 bits of base address */
    uint8_t  base_middle;  /* Bits 16-23 of base address */
    uint8_t  access;       /* Access flags (ring, type, present) */
    uint8_t  granularity;  /* Granularity + upper 4 bits of limit */
    uint8_t  base_high;    /* Bits 24-31 of base address */
} __attribute__((packed));

/* GDT pointer structure passed to lgdt */
struct gdt_ptr {
    uint16_t limit;  /* Size of GDT - 1 */
    uint32_t base;   /* Linear address of GDT */
} __attribute__((packed));

/* GDT segment selectors */
#define GDT_KERNEL_CODE  0x08
#define GDT_KERNEL_DATA  0x10

void gdt_install(void);

#endif /* GDT_H */
