#include "gdt.h"
#include "idt.h"
#include "shell.h"
#include "terminal.h"
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* -------------------------------------------------------------------------
 * VGA hardware text-mode colour constants
 * ------------------------------------------------------------------------- */
enum vga_color {
  VGA_COLOR_BLACK = 0,
  VGA_COLOR_BLUE = 1,
  VGA_COLOR_GREEN = 2,
  VGA_COLOR_CYAN = 3,
  VGA_COLOR_RED = 4,
  VGA_COLOR_MAGENTA = 5,
  VGA_COLOR_BROWN = 6,
  VGA_COLOR_LIGHT_GREY = 7,
  VGA_COLOR_DARK_GREY = 8,
  VGA_COLOR_LIGHT_BLUE = 9,
  VGA_COLOR_LIGHT_GREEN = 10,
  VGA_COLOR_LIGHT_CYAN = 11,
  VGA_COLOR_LIGHT_RED = 12,
  VGA_COLOR_LIGHT_MAGENTA = 13,
  VGA_COLOR_LIGHT_BROWN = 14,
  VGA_COLOR_WHITE = 15,
};

static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) {
  return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color) {
  return (uint16_t)uc | (uint16_t)color << 8;
}

/* -------------------------------------------------------------------------
 * Terminal state  (exported via terminal.h so shell.c can use them)
 * ------------------------------------------------------------------------- */
size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
uint16_t *terminal_buffer;

/* -------------------------------------------------------------------------
 * terminal_scroll — move every line up by one, blank the last line.
 * Called automatically by terminal_putchar when the cursor reaches the
 * bottom. Without this the screen wraps to row 0 and clobbers existing text.
 * ------------------------------------------------------------------------- */
void terminal_scroll(void) {
  /* Move each row up one position */
  for (size_t y = 1; y < VGA_HEIGHT; y++) {
    for (size_t x = 0; x < VGA_WIDTH; x++) {
      terminal_buffer[(y - 1) * VGA_WIDTH + x] =
          terminal_buffer[y * VGA_WIDTH + x];
    }
  }
  /* Blank the last row */
  for (size_t x = 0; x < VGA_WIDTH; x++) {
    terminal_buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + x] =
        vga_entry(' ', terminal_color);
  }
  /* Keep cursor on the last line */
  terminal_row = VGA_HEIGHT - 1;
}

/* -------------------------------------------------------------------------
 * terminal_initialize — clear the screen and reset cursor position.
 * ------------------------------------------------------------------------- */
void terminal_initialize(void) {
  terminal_row = 0;
  terminal_column = 0;
  terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
  terminal_buffer = (uint16_t *)0xB8000;

  for (size_t y = 0; y < VGA_HEIGHT; y++) {
    for (size_t x = 0; x < VGA_WIDTH; x++) {
      terminal_buffer[y * VGA_WIDTH + x] = vga_entry(' ', terminal_color);
    }
  }
}

void terminal_setcolor(uint8_t color) { terminal_color = color; }

void terminal_putentryat(char c, uint8_t color, size_t x, size_t y) {
  terminal_buffer[y * VGA_WIDTH + x] = vga_entry(c, color);
}

/* -------------------------------------------------------------------------
 * terminal_putchar — write one character, advancing cursor and scrolling.
 * ------------------------------------------------------------------------- */
void terminal_putchar(char c) {
  if (c == '\n') {
    terminal_column = 0;
    terminal_row++;
    if (terminal_row == VGA_HEIGHT)
      terminal_scroll();
    return;
  }

  if (c == '\r') {
    terminal_column = 0;
    return;
  }

  terminal_putentryat(c, terminal_color, terminal_column, terminal_row);

  if (++terminal_column == VGA_WIDTH) {
    terminal_column = 0;
    terminal_row++;
    if (terminal_row == VGA_HEIGHT)
      terminal_scroll();
  }
}

void terminal_write(const char *data, size_t size) {
  for (size_t i = 0; i < size; i++)
    terminal_putchar(data[i]);
}

void terminal_writestring(const char *data) {
  size_t len = 0;
  while (data[len]) len++;
  terminal_write(data, len);
}

/* -------------------------------------------------------------------------
 * kernel_main — entry point called from boot.s after stack setup.
 * Order matters:
 *   1. GDT  — must be first; loads a known-good descriptor table.
 *   2. IDT  — must follow GDT; catches all CPU exceptions safely.
 *   3. UI   — safe to run after GDT+IDT are in place.
 * ------------------------------------------------------------------------- */
void kernel_main(void) {
  /* 1. Install a proper Global Descriptor Table */
  gdt_install();

  /* 2. Install the Interrupt Descriptor Table (catches triple-fault sources) */
  idt_install();

  /* 3. Initialise the VGA text terminal */
  terminal_initialize();

  /* Print welcome banner */
  terminal_setcolor(VGA_COLOR_LIGHT_CYAN);
  terminal_writestring("Welcome to LuusOS!\n");
  terminal_setcolor(VGA_COLOR_LIGHT_GREY);
  terminal_writestring("GDT + IDT installed. All exceptions handled.\n");
  terminal_setcolor(VGA_COLOR_WHITE);
  terminal_writestring("Type 'help' to see available commands.\n\n");

  /* 4. Launch interactive shell */
  shell_loop();
}
