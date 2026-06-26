/*
 * isr.s — CPU exception ISR stubs (vectors 0–31) and IDT flush helper.
 *
 * Each stub:
 *   1. Pushes a dummy error code (for exceptions that don't push one).
 *   2. Pushes the interrupt number.
 *   3. Calls isr_common_stub which saves all registers and calls the C handler.
 *
 * Exceptions that push their own error code (8, 10-14, 17) skip the dummy push.
 */

.global idt_flush
.type   idt_flush, @function
idt_flush:
    mov 4(%esp), %eax
    lidt (%eax)
    ret
.size idt_flush, . - idt_flush

/* Macro for ISRs that do NOT push an error code */
.macro ISR_NOERRCODE num
.global isr\num
.type isr\num, @function
isr\num:
    push $0          /* dummy error code */
    push $\num       /* interrupt number */
    jmp isr_common_stub
.endm

/* Macro for ISRs that DO push an error code (CPU already pushed it) */
.macro ISR_ERRCODE num
.global isr\num
.type isr\num, @function
isr\num:
    push $\num       /* interrupt number (error code already on stack) */
    jmp isr_common_stub
.endm

ISR_NOERRCODE 0   /* Division By Zero          */
ISR_NOERRCODE 1   /* Debug                     */
ISR_NOERRCODE 2   /* Non Maskable Interrupt    */
ISR_NOERRCODE 3   /* Breakpoint                */
ISR_NOERRCODE 4   /* Into Detected Overflow    */
ISR_NOERRCODE 5   /* Out of Bounds             */
ISR_NOERRCODE 6   /* Invalid Opcode            */
ISR_NOERRCODE 7   /* No Coprocessor            */
ISR_ERRCODE   8   /* Double Fault              */
ISR_NOERRCODE 9   /* Coprocessor Segment Over. */
ISR_ERRCODE   10  /* Bad TSS                   */
ISR_ERRCODE   11  /* Segment Not Present       */
ISR_ERRCODE   12  /* Stack Fault               */
ISR_ERRCODE   13  /* General Protection Fault  */
ISR_ERRCODE   14  /* Page Fault                */
ISR_NOERRCODE 15  /* Reserved                  */
ISR_NOERRCODE 16  /* Coprocessor Fault         */
ISR_ERRCODE   17  /* Alignment Check           */
ISR_NOERRCODE 18  /* Machine Check             */
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31

/*
 * isr_common_stub — saves all general-purpose registers and the data segment,
 * calls the C-level isr_handler(), then restores everything.
 *
 * Stack layout on entry (after the two pushes above):
 *   [esp+0]  interrupt number
 *   [esp+4]  error code
 *   [esp+8]  eip  (pushed by CPU)
 *   [esp+12] cs   (pushed by CPU)
 *   [esp+16] eflags (pushed by CPU)
 *   (+ useresp/ss if privilege change — not applicable for ring 0)
 */
.extern isr_handler

isr_common_stub:
    pusha               /* Save edi,esi,ebp,esp,ebx,edx,ecx,eax */

    mov %ds, %ax        /* Save data segment */
    push %eax

    mov $0x10, %ax      /* Load kernel data segment */
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs

    push %esp           /* Pass pointer to saved registers as argument */
    call isr_handler
    add $4, %esp        /* Remove argument */

    pop %eax            /* Restore original data segment */
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs

    popa                /* Restore general-purpose registers */
    add $8, %esp        /* Remove err_code and int_no from stack */
    iret                /* Restore eip, cs, eflags (and ss/esp if needed) */
