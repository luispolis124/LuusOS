#ifndef LUUSOS_STRING_H
#define LUUSOS_STRING_H

#include <stddef.h>

size_t strlen(const char *str);
int strcmp(const char *s1, const char *s2);
int strncmp(const char *s1, const char *s2, size_t n);
void memset(void *dest, int val, size_t len);
int atoi(const char *str);
void itoa(int n, char s[]);

#endif /* LUUSOS_STRING_H */
