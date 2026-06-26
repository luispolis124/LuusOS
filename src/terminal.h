#ifndef TERMINAL_H
#define TERMINAL_H

#include <stddef.h>
#include <stdint.h>
#include "string.h"

/* VGA text-mode dimensions */
#define VGA_WIDTH  80
#define VGA_HEIGHT 25

/* Exported state — used by shell.c for cursor manipulation */
extern size_t   terminal_row;
extern size_t   terminal_column;
extern uint8_t  terminal_color;
extern uint16_t *terminal_buffer;

/* Core terminal API */
void terminal_initialize(void);
void terminal_setcolor(uint8_t color);
void terminal_putentryat(char c, uint8_t color, size_t x, size_t y);
void terminal_putchar(char c);
void terminal_write(const char* data, size_t size);
void terminal_writestring(const char* data);
void terminal_scroll(void);

#endif /* TERMINAL_H */
