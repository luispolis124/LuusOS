#include "shell.h"
#include "terminal.h"
#include "keyboard.h"
#include "string.h"
#include "sound.h"
#include "io.h"
#include "timer.h"

#define MAX_COMMAND_LEN 256

void print_prompt() {
    terminal_setcolor(3); // Cyan
    terminal_writestring("luus@os");
    terminal_setcolor(15); // White
    terminal_writestring("> ");
}

void clear_screen() {
    terminal_initialize();
}

void print_neofetch() {
    terminal_setcolor(9); // Light blue
    terminal_writestring("    __                ____  _____\n");
    terminal_writestring("   / /_  __  _____   / __ \\/ ___/\n");
    terminal_writestring("  / / / / / / / ___ / / / /\\__ \\ \n");
    terminal_writestring(" / / /_/ / /_(__  )/ /_/ /___/ / \n");
    terminal_writestring("/_/\\____/\\__/____/ \\____//____/  \n\n");
    
    terminal_setcolor(15); // White
    terminal_writestring("OS: ");
    terminal_setcolor(7);
    terminal_writestring("LuusOS v1.0 (Bare Metal)\n");
    
    terminal_setcolor(15); // White
    terminal_writestring("Kernel: ");
    terminal_setcolor(7);
    terminal_writestring("Custom 32-bit x86\n");
    
    terminal_setcolor(15); // White
    terminal_writestring("Shell: ");
    terminal_setcolor(7);
    terminal_writestring("LuusShell Expanded\n");
    
    terminal_setcolor(15); // White
    terminal_writestring("Audio: ");
    terminal_setcolor(7);
    terminal_writestring("PC Speaker (PIT)\n");
    
    terminal_writestring("\n");
}

static inline void cpuid(int code, uint32_t *a, uint32_t *d) {
    __asm__ volatile("cpuid":"=a"(*a),"=d"(*d):"a"(code):"ecx","ebx");
}

void print_sysinfo() {
    uint32_t eax, edx;
    cpuid(1, &eax, &edx);
    terminal_writestring("CPU Info:\n");
    terminal_writestring("  Family: ");
    char buf[16];
    itoa((eax >> 8) & 0xF, buf);
    terminal_writestring(buf);
    terminal_writestring("\n  Model: ");
    itoa((eax >> 4) & 0xF, buf);
    terminal_writestring(buf);
    terminal_writestring("\n");
}

void execute_command(char *cmd) {
    if (strcmp(cmd, "help") == 0) {
        terminal_writestring("Available commands:\n");
        terminal_writestring("  help     - Show this message\n");
        terminal_writestring("  clear    - Clear the screen\n");
        terminal_writestring("  neofetch - System information\n");
        terminal_writestring("  echo     - Print text (e.g. echo hello)\n");
        terminal_writestring("  color    - Change color 0-15 (e.g. color 2)\n");
        terminal_writestring("  calc     - Add numbers (e.g. calc 5 + 10)\n");
        terminal_writestring("  sysinfo  - CPU Hardware info\n");
        terminal_writestring("  music    - Play a PC Speaker melody\n");
        terminal_writestring("  shutdown - Turn off QEMU (ACPI)\n");
    } else if (strcmp(cmd, "clear") == 0) {
        clear_screen();
    } else if (strcmp(cmd, "neofetch") == 0) {
        print_neofetch();
    } else if (strcmp(cmd, "sysinfo") == 0) {
        print_sysinfo();
    } else if (strcmp(cmd, "music") == 0) {
        terminal_writestring("Playing melody...\n");
        // Super Mario Coin Sound Approximation
        play_sound(987); // B5
        sleep(80);
        play_sound(1318); // E6
        sleep(400);
        nosound();
    } else if (strcmp(cmd, "shutdown") == 0) {
        terminal_writestring("Shutting down via ACPI...\n");
        outw(0x604, 0x2000); // QEMU specific ACPI shutdown
    } else if (strncmp(cmd, "echo ", 5) == 0) {
        terminal_writestring(cmd + 5);
        terminal_writestring("\n");
    } else if (strncmp(cmd, "color ", 6) == 0) {
        int col = atoi(cmd + 6);
        if (col >= 0 && col <= 15) {
            terminal_setcolor((uint8_t)col);
            terminal_writestring("Color changed!\n");
        } else {
            terminal_writestring("Color must be 0-15.\n");
        }
    } else if (strncmp(cmd, "calc ", 5) == 0) {
        // Very basic mock calculator parser: calc num1 + num2
        int i = 5;
        int num1 = 0;
        int num2 = 0;
        char op = 0;
        
        while (cmd[i] == ' ') i++;
        while (cmd[i] >= '0' && cmd[i] <= '9') {
            num1 = num1 * 10 + (cmd[i] - '0');
            i++;
        }
        while (cmd[i] == ' ') i++;
        if (cmd[i] == '+' || cmd[i] == '-' || cmd[i] == '*') {
            op = cmd[i];
            i++;
        }
        while (cmd[i] == ' ') i++;
        while (cmd[i] >= '0' && cmd[i] <= '9') {
            num2 = num2 * 10 + (cmd[i] - '0');
            i++;
        }
        
        char res_str[32];
        if (op == '+') {
            itoa(num1 + num2, res_str);
            terminal_writestring(res_str);
            terminal_writestring("\n");
        } else if (op == '-') {
            itoa(num1 - num2, res_str);
            terminal_writestring(res_str);
            terminal_writestring("\n");
        } else if (op == '*') {
            itoa(num1 * num2, res_str);
            terminal_writestring(res_str);
            terminal_writestring("\n");
        } else {
            terminal_writestring("Syntax error. Example: calc 5 + 10\n");
        }
    } else if (cmd[0] != '\0') {
        terminal_writestring("Command not found: ");
        terminal_writestring(cmd);
        terminal_writestring("\n");
    }
}

void shell_loop() {
    char cmd_buffer[MAX_COMMAND_LEN];
    int cmd_index = 0;
    
    print_prompt();
    
    while (1) {
        char c = keyboard_read_char();
        
        if (c == '\n') {
            terminal_putchar('\n');
            cmd_buffer[cmd_index] = '\0';
            
            execute_command(cmd_buffer);
            
            cmd_index = 0;
            print_prompt();
        } else if (c == '\b') {
            if (cmd_index > 0) {
                cmd_index--;
                
                // Erase character from screen visually
                if (terminal_column == 0 && terminal_row > 0) {
                    terminal_row--;
                    terminal_column = 79;
                } else {
                    terminal_column--;
                }
                terminal_putentryat(' ', 15, terminal_column, terminal_row);
            }
        } else if (c >= ' ' && c <= '~') { // Printable characters
            if (cmd_index < MAX_COMMAND_LEN - 1) {
                cmd_buffer[cmd_index++] = c;
                terminal_putchar(c);
            }
        }
    }
}
