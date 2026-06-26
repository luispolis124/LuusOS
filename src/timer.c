#include "timer.h"

/*
 * sleep — coarse busy-wait delay in approximate milliseconds.
 *
 * Implementation note:
 *   We have no PIT IRQ0 handler yet, so we burn CPU cycles.
 *   The `volatile` loop variable prevents the compiler from optimising
 *   the loop away. The inline `nop` acts as a fence that guarantees
 *   the loop body is never completely elided even at high optimisation
 *   levels, and also gives the CPU something predictable to time.
 *
 *   The multiplier (100000) is tuned for QEMU at default speed.
 *   Real hardware will differ — this is intentional for a bare-metal demo.
 */
void sleep(uint32_t ms) {
    for (uint32_t i = 0; i < ms; i++) {
        /* Inner loop: ~100 000 iterations ≈ 1 ms on QEMU i386 */
        for (volatile uint32_t j = 0; j < 100000; j++) {
            __asm__ __volatile__("nop");
        }
    }
}
