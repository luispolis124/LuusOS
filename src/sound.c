#include "sound.h"
#include "io.h"
#include "timer.h"

// Set the PIT to the desired frequency and play sound
void play_sound(uint32_t frequency) {
    if (frequency == 0) return;
    
    uint32_t div = 1193180 / frequency;
    uint8_t tmp;
    
    // Set the PIT (Programmable Interval Timer) to the desired frequency
    outb(0x43, 0xb6);
    outb(0x42, (uint8_t) (div) );
    outb(0x42, (uint8_t) (div >> 8));
    
    // Play the sound using the PC speaker
    tmp = inb(0x61);
    if (tmp != (tmp | 3)) {
        outb(0x61, tmp | 3);
    }
}

// Shut off the PC speaker
void nosound() {
    uint8_t tmp = inb(0x61) & 0xFC;
    outb(0x61, tmp);
}

// Play a short system beep
void beep() {
    play_sound(1000); // 1000 Hz
    sleep(1);         // Sleep for a short duration
    nosound();
}
