#include "keyboard.h"
#include "io.h"

/* Basic US QWERTY scancode map (set 1, make codes 0x00–0x7F) */
static const char kbd_us[128] = {
      0,   27, '1', '2', '3', '4', '5', '6', '7', '8',  /* 0x00-0x09 */
    '9',  '0', '-', '=','\b','\t', 'q', 'w', 'e', 'r',  /* 0x0A-0x13 */
    't',  'y', 'u', 'i', 'o', 'p', '[', ']','\n',   0,  /* 0x14-0x1D (0x1D=Ctrl) */
    'a',  's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';',  /* 0x1E-0x27 */
    '\'', '`',   0,'\\', 'z', 'x', 'c', 'v', 'b', 'n',  /* 0x28-0x31 (0x2A=LShift) */
    'm',  ',', '.', '/',   0,  '*',   0, ' ',   0,   0,  /* 0x32-0x3B (0x36=RShift,0x38=Alt) */
      0,    0,   0,   0,   0,   0,   0,   0,   0,   0,   /* 0x3C-0x45 (F1-F10, NumLock, ScrollLk) */
      0,    0,   0,   0, '-',   0,   0,   0, '+',   0,   /* 0x46-0x4F (numpad) */
      0,    0,   0,   0,   0,   0,   0,   0,   0,   0,   /* 0x50-0x59 */
      0,    0,   0,   0,   0,   0,   0,   0,   0,   0,   /* 0x5A-0x63 */
      0,    0,   0,   0,   0,   0,   0,   0               /* 0x64-0x6B */
};

/*
 * keyboard_read_char — blocking read of a single printable character.
 *
 * Improvements over original:
 *  - Extended scancodes (0xE0, 0xE1 prefixes) are consumed and discarded
 *    so the byte that follows is not misinterpreted as a normal key.
 *  - Break-code detection uses the exact make-code for the key that was
 *    pressed (scancode | 0x80) and tolerates interleaved spurious bytes
 *    (e.g. 0xE0 arriving before the break code of an extended key).
 *  - Status-register polling uses bit 0 of port 0x64 (output buffer full).
 */
char keyboard_read_char(void) {
    while (1) {
        /* Wait until the PS/2 output buffer has data */
        if (!(inb(0x64) & 0x01))
            continue;

        uint8_t scancode = inb(0x60);

        /* --- Discard extended prefixes (0xE0 / 0xE1) --- */
        if (scancode == 0xE0 || scancode == 0xE1) {
            /* Consume the next byte(s) belonging to this extended code */
            /* For 0xE1 (Pause key) there are two more bytes; just flush them. */
            uint8_t extra_bytes = (scancode == 0xE1) ? 2 : 1;
            for (uint8_t i = 0; i < extra_bytes; i++) {
                while (!(inb(0x64) & 0x01)) {}
                inb(0x60); /* discard */
            }
            continue;
        }

        /* --- Key release (break code, bit 7 set) — ignore --- */
        if (scancode & 0x80)
            continue;

        /* --- Key press (make code) --- */
        char c = kbd_us[scancode & 0x7F];
        if (c == 0)
            continue; /* unmapped key — ignore */

        /*
         * Wait for the break code of this exact key before returning.
         * This prevents character repetition when the key is held.
         * We accept an interleaved 0xE0 prefix byte without treating it
         * as the break code.
         */
        uint8_t break_code = scancode | 0x80;
        while (1) {
            while (!(inb(0x64) & 0x01)) {}
            uint8_t release = inb(0x60);
            if (release == 0xE0 || release == 0xE1)
                continue; /* skip extended prefix, keep waiting */
            if (release == break_code)
                break;    /* got the release we were waiting for */
            /* Any other byte is discarded (e.g. another key pressed while
               this one is still held — just ignore it). */
        }

        return c;
    }
}
