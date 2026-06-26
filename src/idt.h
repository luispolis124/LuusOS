#ifndef IDT_H
#define IDT_H

#include <stdint.h>

/* IDT gate descriptor — 8 bytes */
struct idt_entry {
    uint16_t base_low;   /* Lower 16 bits of handler address */
    uint16_t selector;   /* Kernel segment selector (GDT_KERNEL_CODE) */
    uint8_t  zero;       /* Always 0 */
    uint8_t  flags;      /* Gate type | DPL | Present */
    uint16_t base_high;  /* Upper 16 bits of handler address */
} __attribute__((packed));

/* IDT pointer passed to lidt */
struct idt_ptr {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

/*
 * Registers saved on the stack when an exception fires.
 * Pushed by our ISR stubs before calling the C handler.
 */
struct registers {
    uint32_t ds;                            /* Data segment */
    uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax; /* Pushed by pusha */
    uint32_t int_no, err_code;              /* Interrupt number + error code */
    uint32_t eip, cs, eflags, useresp, ss; /* Pushed by CPU automatically */
};

void idt_install(void);

/* ISR stubs — defined in isr.s, called by the CPU */
extern void isr0(void);
extern void isr1(void);
extern void isr2(void);
extern void isr3(void);
extern void isr4(void);
extern void isr5(void);
extern void isr6(void);
extern void isr7(void);
extern void isr8(void);
extern void isr9(void);
extern void isr10(void);
extern void isr11(void);
extern void isr12(void);
extern void isr13(void);
extern void isr14(void);
extern void isr15(void);
extern void isr16(void);
extern void isr17(void);
extern void isr18(void);
extern void isr19(void);
extern void isr20(void);
extern void isr21(void);
extern void isr22(void);
extern void isr23(void);
extern void isr24(void);
extern void isr25(void);
extern void isr26(void);
extern void isr27(void);
extern void isr28(void);
extern void isr29(void);
extern void isr30(void);
extern void isr31(void);

#endif /* IDT_H */
