#include <avr/io.h>
#include <avr/wdt.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <avr/power.h>

ISR(WDT_vect)
{
  // Toggle LED
  PORTB ^= _BV(0);

  // Re-enable watchdog interrupt
  WDTCR |= _BV(WDIE);
}

int __attribute__((noreturn)) main(void)
{

  // LED out
  DDRB = _BV(0);

  // watchdog setup: 8.5.2
  WDTCR |= _BV(WDP3); // 4 hertz timeout
  WDTCR |= _BV(WDIE) | _BV(WDE); // enable watchdog interupt and watchdog

  // save some power - in testing no apparent change in current
  // 7.5.2 PRR – Power Reduction Register
  // disable:timer1       timer0        usi         adc
  //PRR |= _BV(PRTIM1) |_BV(PRTIM0) | _BV(PRUSI)| _BV(PRADC);

  // Turn off brown out detection
  //MCUCR |= _BV(BODS) | _BV(BODSE);
  //MCUCR &= ~_BV(BODSE);

  // Enable interrupts
  sei();

  //Set LED (PORTB.0) high
  PORTB = _BV(0);

  // Use the Power Down sleep mode
  set_sleep_mode(SLEEP_MODE_PWR_DOWN);
  
  for(;;) { // main loop, continue execution in WDT interrupt handler
    sleep_mode();
  }
}