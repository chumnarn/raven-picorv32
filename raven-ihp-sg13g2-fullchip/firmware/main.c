#include "raven_defs.h"

static void putchar_raven(char c)
{
    if (c == '\n')
        reg_uart_data = '\r';
    reg_uart_data = (uint32_t)c;
}

static void puts_raven(const char *s)
{
    while (*s)
        putchar_raven(*s++);
}

void main(void)
{
    volatile uint32_t delay;
    uint32_t pattern = 1;

    // 100 MHz / 115200 baud, rounded.  simpleuart uses this divider directly.
    reg_uart_clkdiv = 868;
    reg_gpio_ena = 0x0000;       // Raven GPIO enable is active low.
    reg_gpio_pu = 0x0000;
    reg_gpio_pd = 0x0000;
    puts_raven("Raven PicoRV32 on IHP SG13G2\n");

    for (;;) {
        reg_gpio_data = pattern;
        pattern = (pattern == 0x8000) ? 1 : (pattern << 1);
        for (delay = 0; delay < 250000; delay++)
            __asm__ volatile ("nop");
    }
}
