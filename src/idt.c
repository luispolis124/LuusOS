#include "idt.h"
#include "gdt.h"
#include "terminal.h"

/* Names for the 32 CPU exception vectors */
static const char *exception_messages[] = {
    "Division By Zero",
    "Debug",
    "Non Maskable Interrupt",
    "Breakpoint",
    "Into Detected Overflow",
    "Out of Bounds",
    "Invalid Opcode",
    "No Coprocessor",
    "Double Fault",
    "Coprocessor Segment Overrun",
    "Bad TSS",
    "Segment Not Present",
    "Stack Fault",
    "General Protection Fault",
    "Page Fault",
    "Unknown Interrupt",
    "Coprocessor Fault",
    "Alignment Check",
    "Machine Check",
    "Reserved",
    "Reserved", "Reserved", "Reserved", "Reserved",
    "Reserved", "Reserved", "Reserved", "Reserved",
    "Reserved", "Reserved", "Reserved", "Reserved"
};

static struct idt_entry idt[256];
static struct idt_ptr   idtp;

/* Defined in isr.s */
extern void idt_flush(uint32_t idt_ptr_addr);

static void idt_set_gate(uint8_t num, uint32_t base, uint16_t sel, uint8_t flags)
{
    idt[num].base_low  = (base & 0xFFFF);
    idt[num].base_high = (base >> 16) & 0xFFFF;
    idt[num].selector  = sel;
    idt[num].zero      = 0;
    idt[num].flags     = flags;
}

/*
 * isr_handler — C-level exception handler.
 * Prints a panic message and halts the machine.
 * Called from the ISR stubs in isr.s after saving registers.
 */
void isr_handler(struct registers regs)
{
    terminal_setcolor(12); /* Light red */
    terminal_writestring("\n*** KERNEL PANIC ***\n");
    terminal_writestring("Exception: ");
    if (regs.int_no < 32)
        terminal_writestring(exception_messages[regs.int_no]);
    else
        terminal_writestring("Unknown");
    terminal_writestring("\nSystem halted.\n");

    /* Halt forever */
    __asm__ __volatile__("cli");
    for (;;)
        __asm__ __volatile__("hlt");
}

void idt_install(void)
{
    idtp.limit = (sizeof(struct idt_entry) * 256) - 1;
    idtp.base  = (uint32_t)(uintptr_t)idt;

    /* Zero-fill the entire IDT */
    for (int i = 0; i < 256; i++)
        idt_set_gate(i, 0, 0, 0);

    /* Install CPU exception handlers (vectors 0–31).
     * Flags: 0x8E = present(1) | DPL=00 | 0 | type=1110 (32-bit interrupt gate) */
    idt_set_gate(0,  (uint32_t)(uintptr_t)isr0,  GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(1,  (uint32_t)(uintptr_t)isr1,  GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(2,  (uint32_t)(uintptr_t)isr2,  GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(3,  (uint32_t)(uintptr_t)isr3,  GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(4,  (uint32_t)(uintptr_t)isr4,  GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(5,  (uint32_t)(uintptr_t)isr5,  GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(6,  (uint32_t)(uintptr_t)isr6,  GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(7,  (uint32_t)(uintptr_t)isr7,  GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(8,  (uint32_t)(uintptr_t)isr8,  GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(9,  (uint32_t)(uintptr_t)isr9,  GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(10, (uint32_t)(uintptr_t)isr10, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(11, (uint32_t)(uintptr_t)isr11, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(12, (uint32_t)(uintptr_t)isr12, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(13, (uint32_t)(uintptr_t)isr13, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(14, (uint32_t)(uintptr_t)isr14, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(15, (uint32_t)(uintptr_t)isr15, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(16, (uint32_t)(uintptr_t)isr16, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(17, (uint32_t)(uintptr_t)isr17, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(18, (uint32_t)(uintptr_t)isr18, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(19, (uint32_t)(uintptr_t)isr19, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(20, (uint32_t)(uintptr_t)isr20, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(21, (uint32_t)(uintptr_t)isr21, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(22, (uint32_t)(uintptr_t)isr22, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(23, (uint32_t)(uintptr_t)isr23, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(24, (uint32_t)(uintptr_t)isr24, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(25, (uint32_t)(uintptr_t)isr25, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(26, (uint32_t)(uintptr_t)isr26, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(27, (uint32_t)(uintptr_t)isr27, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(28, (uint32_t)(uintptr_t)isr28, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(29, (uint32_t)(uintptr_t)isr29, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(30, (uint32_t)(uintptr_t)isr30, GDT_KERNEL_CODE, 0x8E);
    idt_set_gate(31, (uint32_t)(uintptr_t)isr31, GDT_KERNEL_CODE, 0x8E);

    idt_flush((uint32_t)(uintptr_t)&idtp);
}
